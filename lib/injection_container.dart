// injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:mbosswater/features/login/data/datasource/auth_datasource.dart';
import 'package:mbosswater/features/login/data/datasource/auth_datasource_impl.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_bloc.dart';
import 'package:mbosswater/features/recovery/data/datasource/recovery_datasource.dart';
import 'package:mbosswater/features/recovery/data/datasource/recovery_datasource_impl.dart';
import 'package:mbosswater/features/recovery/data/repository/recovery_repository_impl.dart';
import 'package:mbosswater/features/recovery/domain/repository/recovery_repository.dart';
import 'package:mbosswater/features/recovery/domain/usecase/change_password.dart';
import 'package:mbosswater/features/recovery/domain/usecase/verify_email.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/change_password_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_bloc.dart';

final sl = GetIt.instance;

void initServiceLocator() {
  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDatasourceImpl(),
  );

  sl.registerLazySingleton<LoginBloc>(
    () => LoginBloc(sl<AuthDatasource>()),
  );

  // Forgot password
  sl.registerLazySingleton<RecoveryDatasource>(
        () => RecoveryDatasourceImpl(),
  );

  sl.registerLazySingleton<RecoveryRepository>(
        () => RecoveryRepositoryImpl(sl<RecoveryDatasource>()),
  );

  sl.registerLazySingleton<VerifyEmailUseCase>(
        () => VerifyEmailUseCase(sl<RecoveryRepository>()),
  );

  sl.registerLazySingleton<VerifyEmailBloc>(
        () => VerifyEmailBloc(sl<VerifyEmailUseCase>()),
  );

  sl.registerLazySingleton<VerifyOtpBloc>(
        () => VerifyOtpBloc(sl<VerifyEmailUseCase>()),
  );

  sl.registerLazySingleton<ChangePasswordUseCase>(
        () => ChangePasswordUseCase(sl<RecoveryRepository>()),
  );

  sl.registerLazySingleton<ChangePasswordBloc>(
        () => ChangePasswordBloc(sl<ChangePasswordUseCase>()),
  );

}
