import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt', // Default
  preferRelativeImports: true, // Default
  asExtension: false, // Default
)
Future<void> configureDependencies() async => $initGetIt(getIt);
