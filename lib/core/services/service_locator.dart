import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_initialization_service.dart';
import 'user_provisioning_service.dart';
import '../theme/theme_cubit.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Organizations
import '../../features/organizations/data/datasources/organization_remote_data_source.dart';
import '../../features/organizations/data/repositories/organization_repository_impl.dart';
import '../../features/organizations/domain/repositories/organization_repository.dart';
import '../../features/organizations/presentation/cubit/organization_cubit.dart';

// Services
import '../../features/services/data/datasources/service_remote_data_source.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/services/presentation/cubit/service_cubit.dart';

// Tickets
import '../../features/tickets/data/datasources/ticket_remote_data_source.dart';
import '../../features/tickets/data/repositories/ticket_repository_impl.dart';
import '../../features/tickets/domain/repositories/ticket_repository.dart';
import '../../features/tickets/presentation/bloc/ticket_bloc.dart';

// Staff
import '../../features/staff/data/datasources/staff_remote_data_source.dart';
import '../../features/staff/data/repositories/staff_repository_impl.dart';
import '../../features/staff/domain/repositories/staff_repository.dart';
import '../../features/staff/presentation/bloc/staff_queue_bloc.dart';

// Organization Admin
import '../../features/organization_admin/data/datasources/admin_remote_data_source.dart';
import '../../features/organization_admin/data/repositories/admin_repository_impl.dart';
import '../../features/organization_admin/domain/repositories/admin_repository.dart';
import '../../features/organization_admin/presentation/cubit/admin_cubit.dart';

// Super Admin
import '../../features/super_admin/data/datasources/super_admin_remote_data_source.dart';
import '../../features/super_admin/data/repositories/super_admin_repository_impl.dart';
import '../../features/super_admin/domain/repositories/super_admin_repository.dart';
import '../../features/super_admin/presentation/cubit/super_admin_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Theme
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sharedPreferences));

  // Firebase External Dependencies
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      clientId: kIsWeb ? '1097516457844-h6a32fu2gkngr5kl6iqo0rcvgos0ol3s.apps.googleusercontent.com' : null,
    ),
  );

  // Core Services
  sl.registerLazySingleton<AdminInitializationService>(
    () => AdminInitializationService(
      auth: sl(),
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<UserProvisioningService>(
    () => UserProvisioningService(firestore: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton<OrganizationRemoteDataSource>(
    () => OrganizationRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<TicketRemoteDataSource>(
    () => TicketRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(firestore: sl(), provisioningService: sl()),
  );
  sl.registerLazySingleton<SuperAdminRemoteDataSource>(
    () => SuperAdminRemoteDataSourceImpl(firestore: sl(), provisioningService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrganizationRepository>(
    () => OrganizationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TicketRepository>(
    () => TicketRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SuperAdminRepository>(
    () => SuperAdminRepositoryImpl(remoteDataSource: sl()),
  );

  // BLoCs & Cubits
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl()),
  );
  sl.registerFactory<OrganizationCubit>(
    () => OrganizationCubit(repository: sl()),
  );
  sl.registerFactory<ServiceCubit>(
    () => ServiceCubit(repository: sl()),
  );
  sl.registerFactory<TicketBloc>(
    () => TicketBloc(ticketRepository: sl()),
  );
  sl.registerFactory<StaffQueueBloc>(
    () => StaffQueueBloc(staffRepository: sl()),
  );
  sl.registerFactory<AdminCubit>(
    () => AdminCubit(repository: sl()),
  );
  sl.registerFactory<SuperAdminCubit>(
    () => SuperAdminCubit(repository: sl()),
  );

  // Initialize Default Super Admin Account asynchronously (non-blocking)
  sl<AdminInitializationService>().initializeDefaultSuperAdmin().catchError((_) {});
}
