// injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:mbosswater/features/customer/data/datasource/customer_datasource.dart';
import 'package:mbosswater/features/customer/data/datasource/customer_datasource_impl.dart';
import 'package:mbosswater/features/customer/data/repository/customer_repository_impl.dart';
import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';
import 'package:mbosswater/features/customer/domain/usecase/get_customer_guarantee.dart';
import 'package:mbosswater/features/customer/domain/usecase/search_customer.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_bloc.dart';
import 'package:mbosswater/features/guarantee/data/datasource/address_datasource.dart';
import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource.dart';
import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource_impl.dart';
import 'package:mbosswater/features/guarantee/data/repository/address_repository_impl.dart';
import 'package:mbosswater/features/guarantee/data/repository/guarantee_repository_impl.dart';
import 'package:mbosswater/features/guarantee/domain/repository/address_repository.dart';
import 'package:mbosswater/features/guarantee/domain/repository/guarantee_repository.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/active_guarantee.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/address_usecase.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_bloc.dart';
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
import 'package:mbosswater/features/user_info/data/datasource/user_datasource.dart';
import 'package:mbosswater/features/user_info/data/datasource/user_datasource_impl.dart';
import 'package:mbosswater/features/user_info/data/repository/user_repository_impl.dart';
import 'package:mbosswater/features/user_info/domain/repository/user_repository.dart';
import 'package:mbosswater/features/user_info/domain/usecase/fetch_user_info.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

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

  // Address
  sl.registerLazySingleton<AddressDatasource>(
    () => AddressDatasource(),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(sl<AddressDatasource>()),
  );
  sl.registerLazySingleton<AddressUseCase>(
    () => AddressUseCase(sl<AddressRepository>()),
  );

  sl.registerLazySingleton<ProvincesBloc>(
    () => ProvincesBloc(sl<AddressUseCase>()),
  );
  sl.registerLazySingleton<DistrictsBloc>(
    () => DistrictsBloc(sl<AddressUseCase>()),
  );
  sl.registerLazySingleton<CommunesBloc>(
    () => CommunesBloc(sl<AddressUseCase>()),
  );

  // Guarantee
  sl.registerLazySingleton<GuaranteeDatasource>(
    () => GuaranteeDatasourceImpl(),
  );
  sl.registerLazySingleton<GuaranteeRepository>(
    () => GuaranteeRepositoryImpl(sl<GuaranteeDatasource>()),
  );
  sl.registerLazySingleton<ActiveGuaranteeUseCase>(
    () => ActiveGuaranteeUseCase(sl<GuaranteeRepository>()),
  );

  sl.registerLazySingleton<ActiveGuaranteeBloc>(
    () => ActiveGuaranteeBloc(sl<ActiveGuaranteeUseCase>()),
  );
  
  // Customer 
  sl.registerLazySingleton<CustomerDatasource>(
        () => CustomerDatasourceImpl(),
  );
  sl.registerLazySingleton<CustomerRepository>(
        () => CustomerRepositoryImpl(sl<CustomerDatasource>()),
  );
  sl.registerLazySingleton<SearchCustomerUseCase>(
        () => SearchCustomerUseCase(sl<CustomerRepository>()),
  );

  sl.registerLazySingleton<GetCustomerGuaranteeUseCase>(
        () => GetCustomerGuaranteeUseCase(sl<CustomerRepository>()),
  );

  sl.registerLazySingleton<CustomerGuaranteeBloc>(
        () => CustomerGuaranteeBloc(sl<GetCustomerGuaranteeUseCase>()),
  );

  sl.registerLazySingleton<CustomerSearchBloc>(
        () => CustomerSearchBloc(sl<SearchCustomerUseCase>()),
  );

  // User
  sl.registerLazySingleton<UserDatasource>(
        () => UserDatasourceImpl(),
  );
  sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(sl<UserDatasource>()),
  );
  sl.registerLazySingleton<FetchUserInfoUseCase>(
        () => FetchUserInfoUseCase(sl<UserRepository>()),
  );

  sl.registerLazySingleton<UserInfoBloc>(
        () => UserInfoBloc(sl<FetchUserInfoUseCase>()),
  );
}
