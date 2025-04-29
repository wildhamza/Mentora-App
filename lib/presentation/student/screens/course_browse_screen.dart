import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentora/app_router.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_text_field.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/presentation/common/widgets/course_card.dart';
import 'package:mentora/presentation/common/widgets/error_widget.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_bloc.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_event.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_state.dart';

@RoutePage()
class CourseBrowseScreen extends StatefulWidget {
  const CourseBrowseScreen({Key? key}) : super(key: key);

  @override
  _CourseBrowseScreenState createState() => _CourseBrowseScreenState();
}

class _CourseBrowseScreenState extends State<CourseBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late StudentDashboardBloc _dashboardBloc;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<StudentDashboardBloc>();
    _dashboardBloc.add(const LoadAvailableCoursesEvent());
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = _dashboardBloc.state;
      if (state is AvailableCoursesLoaded && state.hasMorePages) {
        _dashboardBloc.add(LoadAvailableCoursesEvent(
          page: state.currentPage + 1,
          searchQuery: state.searchQuery,
          statusFilter: state.statusFilter,
        ));
      }
    }
  }

  void _search() {
    _dashboardBloc.add(LoadAvailableCoursesEvent(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      statusFilter: _selectedStatus,
    ));
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _dashboardBloc.add(LoadAvailableCoursesEvent(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      statusFilter: status,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Browse Courses'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppTextField(
                label: 'Search Courses',
                hint: 'Enter course name or keyword',
                controller: _searchController,
                prefixIcon: Icons.search,
                onSubmitted: (_) => _search(),
                suffixIcon: Icons.clear,
                onSuffixIconPressed: () {
                  _searchController.clear();
                  _search();
                },
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedStatus == null,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByStatus(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Active'),
                    selected: _selectedStatus == AppConstants.courseStatusActive,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByStatus(AppConstants.courseStatusActive);
                      } else {
                        _filterByStatus(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Upcoming'),
                    selected: _selectedStatus == AppConstants.courseStatusUpcoming,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByStatus(AppConstants.courseStatusUpcoming);
                      } else {
                        _filterByStatus(null);
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Course list
            Expanded(
              child: BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
                builder: (context, state) {
                  if (state is StudentDashboardLoading) {
                    return const LoadingIndicator(
                      message: 'Loading courses...',
                    );
                  } else if (state is AvailableCoursesLoaded) {
                    if (state.courses.isEmpty) {
                      return EmptyStateView(
                        title: 'No Courses Found',
                        message: 'Try adjusting your search or filters to find courses.',
                        icon: Icons.search_off,
                      );
                    }
                    
                    return RefreshIndicator(
                      onRefresh: () async {
                        _dashboardBloc.add(LoadAvailableCoursesEvent(
                          searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
                          statusFilter: _selectedStatus,
                        ));
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.hasMorePages 
                            ? state.courses.length + 1 
                            : state.courses.length,
                        itemBuilder: (context, index) {
                          if (index >= state.courses.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          
                          final course = state.courses[index];
                          return CourseCard(
                            course: course,
                            onTap: () {
                              context.router.push(CourseDetailRoute(courseId: course.id));
                            },
                            showEnrollButton: true,
                            onEnrollTap: () {
                              if (course.isFull) {
                                _dashboardBloc.add(JoinWaitlistEvent(course.id));
                              } else {
                                context.router.push(
                                  PaymentRoute(courseId: course.id, courseFee: course.fee)
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
                  } else if (state is StudentDashboardError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () {
                        _dashboardBloc.add(const LoadAvailableCoursesEvent());
                      },
                    );
                  }
                  
                  return const LoadingIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
