import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/course_provider.dart';
import '../../common/app_button.dart';

class MaterialsScreen extends StatefulWidget {
  final String courseId;
  
  const MaterialsScreen({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load course materials
      Provider.of<CourseProvider>(context, listen: false).getCourseMaterials(widget.courseId);
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final course = courseProvider.currentCourse;
    final isLoading = courseProvider.isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(course?.title ?? 'Course Materials'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Documents'),
            Tab(text: 'Videos'),
            Tab(text: 'Downloads'),
          ],
        ),
      ),
      body: isLoading || course == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Documents tab
                _buildDocumentsTab(context, courseProvider),
                
                // Videos tab
                _buildVideosTab(context, courseProvider),
                
                // Downloads tab
                _buildDownloadsTab(context, courseProvider),
              ],
            ),
    );
  }
  
  Widget _buildDocumentsTab(BuildContext context, CourseProvider courseProvider) {
    final documents = courseProvider.courseMaterials
        ?.where((material) => material.type == 'document' || material.type == 'pdf')
        .toList();
    
    if (documents == null || documents.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.description,
        message: 'No documents available for this course',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return _buildMaterialCard(
          context,
          title: document.title ?? 'Document',
          description: document.description ?? 'No description',
          icon: Icons.insert_drive_file,
          date: document.uploadDate ?? 'Unknown date',
          fileSize: document.fileSize ?? 'Unknown size',
          onViewPressed: () {
            // View document
          },
          onDownloadPressed: () {
            // Download document
          },
        );
      },
    );
  }
  
  Widget _buildVideosTab(BuildContext context, CourseProvider courseProvider) {
    final videos = courseProvider.courseMaterials
        ?.where((material) => material.type == 'video')
        .toList();
    
    if (videos == null || videos.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.videocam,
        message: 'No videos available for this course',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoCard(
          context,
          title: video.title ?? 'Video',
          description: video.description ?? 'No description',
          thumbnail: video.thumbnailUrl,
          duration: video.duration ?? 'Unknown duration',
          onPressed: () {
            // Play video
          },
        );
      },
    );
  }
  
  Widget _buildDownloadsTab(BuildContext context, CourseProvider courseProvider) {
    final downloads = courseProvider.courseMaterials
        ?.where((material) => material.type == 'other' || material.type == 'archive')
        .toList();
    
    if (downloads == null || downloads.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.download,
        message: 'No downloadable materials available',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return _buildMaterialCard(
          context,
          title: download.title ?? 'Download',
          description: download.description ?? 'No description',
          icon: Icons.download_rounded,
          date: download.uploadDate ?? 'Unknown date',
          fileSize: download.fileSize ?? 'Unknown size',
          onViewPressed: null, // No view option for downloads
          onDownloadPressed: () {
            // Download file
          },
        );
      },
    );
  }
  
  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMaterialCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String date,
    required String fileSize,
    required VoidCallback? onViewPressed,
    required VoidCallback onDownloadPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded on $date · $fileSize',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onViewPressed != null) ...[
                  AppButton(
                    text: 'View',
                    type: ButtonType.outline,
                    icon: Icons.remove_red_eye,
                    onPressed: onViewPressed,
                  ),
                  const SizedBox(width: 8),
                ],
                AppButton(
                  text: 'Download',
                  type: ButtonType.primary,
                  icon: Icons.download,
                  onPressed: onDownloadPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVideoCard(
    BuildContext context, {
    required String title,
    required String description,
    String? thumbnail,
    required String duration,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: thumbnail != null
                    ? Image.network(
                        thumbnail,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: AppColors.primaryLight.withOpacity(0.3),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 180,
                        color: AppColors.primaryLight.withOpacity(0.3),
                        child: const Center(
                          child: Icon(
                            Icons.videocam,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
              
              // Play button
              Positioned.fill(
                child: Center(
                  child: InkWell(
                    onTap: onPressed,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Duration badge
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Video details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}