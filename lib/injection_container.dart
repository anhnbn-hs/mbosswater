// injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:mbosswater/features/agency/data/agency_datasource.dart';
import 'package:mbosswater/features/agency/data/agency_datasource_impl.dart';
import 'package:mbosswater/features/agency/presentation/bloc/create_agency_staff_bloc.dart';
import 'package:mbosswater/features/agency/presentation/bloc/delete_agency_staff_bloc.dart';
import 'package:mbosswater/features/agency/presentation/bloc/fetch_agency_staff_bloc.dart';
import 'package:mbosswater/features/agency/presentation/bloc/update_agency_staff_bloc.dart';
import 'package:mbosswater/features/customer/data/datasource/customer_datasource.dart';
import 'package:mbosswater/features/customer/data/datasource/customer_datasource_impl.dart';
import 'package:mbosswater/features/customer/data/repository/customer_repository_impl.dart';
import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';
import 'package:mbosswater/features/customer/domain/usecase/fetch_customers_with_pagination.dart';
import 'package:mbosswater/features/customer/domain/usecase/get_customer_by_phone.dart';
import 'package:mbosswater/features/customer/domain/usecase/get_customer_by_product.dart';
import 'package:mbosswater/features/customer/domain/usecase/get_customer_guarantee.dart';
import 'package:mbosswater/features/customer/domain/usecase/search_customer.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_paginate_bloc.dart';
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
import 'package:mbosswater/features/guarantee/domain/usecase/agency_usecase.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/guarantee_history.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agencies_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';
import 'package:mbosswater/features/login/data/datasource/auth_datasource.dart';
import 'package:mbosswater/features/login/data/datasource/auth_datasource_impl.dart';
import 'package:mbosswater/features/login/presentation/bloc/login_bloc.dart';
import 'package:mbosswater/features/mboss/data/datasource/mboss_manager_datasource.dart';
import 'package:mbosswater/features/mboss/data/datasource/mboss_manager_datasource_impl.dart';
import 'package:mbosswater/features/mboss/data/repository/mboss_manager_repository_impl.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/create_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/delete_agency_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/delete_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_agencies_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/update_agency_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/update_mboss_staff_bloc.dart';
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

  sl.registerLazySingleton<ProvincesAgencyBloc>(
    () => ProvincesAgencyBloc(sl<AddressUseCase>()),
  );
  sl.registerLazySingleton<DistrictsAgencyBloc>(
    () => DistrictsAgencyBloc(sl<AddressUseCase>()),
  );
  sl.registerLazySingleton<CommunesAgencyBloc>(
    () => CommunesAgencyBloc(sl<AddressUseCase>()),
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

  sl.registerLazySingleton<GuaranteeHistoryUseCase>(
    () => GuaranteeHistoryUseCase(sl<GuaranteeRepository>()),
  );

  sl.registerLazySingleton<ActiveGuaranteeBloc>(
    () => ActiveGuaranteeBloc(sl<ActiveGuaranteeUseCase>()),
  );

  sl.registerLazySingleton<GuaranteeHistoryBloc>(
    () => GuaranteeHistoryBloc(sl<GuaranteeHistoryUseCase>()),
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

  sl.registerLazySingleton<GetCustomerByProductUseCase>(
    () => GetCustomerByProductUseCase(sl<CustomerRepository>()),
  );

  sl.registerLazySingleton<FetchCustomersWithPaginationUC>(
    () => FetchCustomersWithPaginationUC(sl<CustomerRepository>()),
  );

  sl.registerLazySingleton<GetCustomerByPhoneUseCase>(
    () => GetCustomerByPhoneUseCase(sl<CustomerRepository>()),
  );

  sl.registerLazySingleton<FetchCustomerBloc>(
    () => FetchCustomerBloc(
        sl<GetCustomerByProductUseCase>(), sl<GetCustomerByPhoneUseCase>()),
  );

  sl.registerLazySingleton<FetchCustomersPaginateBloc>(
        () => FetchCustomersPaginateBloc(sl<FetchCustomersWithPaginationUC>()),
  );

  sl.registerLazySingleton<CustomerGuaranteeBloc>(
    () => CustomerGuaranteeBloc(sl<GetCustomerGuaranteeUseCase>()),
  );

  sl.registerLazySingleton<CustomerSearchBloc>(
    () => CustomerSearchBloc(sl<SearchCustomerUseCase>()),
  );
  // User
  sl.registerLazySingleton<UserDatasource>(() => UserDatasourceImpl());

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<UserDatasource>()),
  );
  sl.registerLazySingleton<FetchUserInfoUseCase>(
    () => FetchUserInfoUseCase(sl<UserRepository>()),
  );

  sl.registerLazySingleton<UserInfoBloc>(
    () => UserInfoBloc(sl<FetchUserInfoUseCase>()),
  );

  // Agency
  sl.registerLazySingleton<AgencyUseCase>(
    () => AgencyUseCase(sl<GuaranteeRepository>()),
  );

  sl.registerLazySingleton<AgencyBloc>(
    () => AgencyBloc(sl<AgencyUseCase>()),
  );

  sl.registerLazySingleton<AgenciesBloc>(
    () => AgenciesBloc(sl<AgencyUseCase>()),
  );

  sl.registerLazySingleton<AgencyDatasource>(
    () => AgencyDatasourceImpl(sl<UserDatasource>()),
  );

  sl.registerLazySingleton<FetchAgencyStaffBloc>(
    () => FetchAgencyStaffBloc(sl<AgencyDatasource>()),
  );

  sl.registerLazySingleton<CreateAgencyStaffBloc>(
    () => CreateAgencyStaffBloc(sl<AgencyDatasource>()),
  );

  sl.registerLazySingleton<UpdateAgencyStaffBloc>(
    () => UpdateAgencyStaffBloc(sl<AgencyDatasource>()),
  );

  sl.registerLazySingleton<DeleteAgencyStaffBloc>(
    () => DeleteAgencyStaffBloc(sl<AgencyDatasource>()),
  );
  // Mboss Management
  sl.registerLazySingleton<MbossManagerDatasource>(
    () => MbossManagerDatasourceImpl(sl<UserDatasource>()),
  );

  sl.registerLazySingleton<MbossManagerRepository>(
    () => MbossManagerRepositoryImpl(sl<MbossManagerDatasource>()),
  );

  sl.registerLazySingleton<FetchMbossStaffBloc>(
    () => FetchMbossStaffBloc(sl<MbossManagerRepository>()),
  );

  sl.registerLazySingleton<CreateMbossStaffBloc>(
    () => CreateMbossStaffBloc(sl<MbossManagerRepository>()),
  );

  sl.registerLazySingleton<UpdateMbossStaffBloc>(
    () => UpdateMbossStaffBloc(sl<MbossManagerRepository>()),
  );

  sl.registerLazySingleton<DeleteMbossStaffBloc>(
    () => DeleteMbossStaffBloc(sl<MbossManagerRepository>()),
  );

  sl.registerLazySingleton<FetchAgenciesBloc>(
    () => FetchAgenciesBloc(sl<MbossManagerRepository>()),
  );

  sl.registerLazySingleton<UpdateAgencyBloc>(
    () => UpdateAgencyBloc(sl<MbossManagerRepository>()),
  );

  sl.registerLazySingleton<DeleteAgencyBloc>(
    () => DeleteAgencyBloc(sl<MbossManagerRepository>()),
  );
}
