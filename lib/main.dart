import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mbosswater/core/services/firebase_cloud_message.dart';
import 'package:mbosswater/core/services/notification_service.dart';
import 'package:mbosswater/core/styles/app_theme.dart';
import 'package:mbosswater/features/agency/presentation/bloc/create_agency_staff_bloc.dart';
import 'package:mbosswater/features/agency/presentation/bloc/delete_agency_staff_bloc.dart';
import 'package:mbosswater/features/agency/presentation/bloc/fetch_agency_staff_bloc.dart';
import 'package:mbosswater/features/agency/presentation/bloc/update_agency_staff_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_stats_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_paginate_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/provinces_metadata_bloc.dart';
import 'package:mbosswater/features/home/bloc/search_customer_bloc.dart';
import 'package:mbosswater/features/customer_care/bloc/cycle_bloc.dart';
import 'package:mbosswater/features/customer_care/bloc/fetch_customers_cubit.dart';
import 'package:mbosswater/features/customer_care/bloc/fetch_guarantee_by_id_cubit.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/staffs/fetch_staffs_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/additional_info_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agencies_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/customer_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/product_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/step_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/upload/upload_image_cubit.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/create_agency_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/create_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/delete_agency_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/delete_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_agencies_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_agency_admin_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_mboss_staff_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/update_agency_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/update_mboss_staff_bloc.dart';
import 'package:mbosswater/features/notification/notification_cubit.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/change_password_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';
import 'package:mbosswater/go_router.dart';
import 'features/login/presentation/bloc/login_bloc.dart';
import 'injection_container.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  // Initialize .env
  await dotenv.load();

  // Initialize NotificationService
  await NotificationService.init();

  // Initialize FirebaseCloudMessaging
  final FirebaseCloudMessage fcm = FirebaseCloudMessage();

  await fcm.initialize();

  // Initialize Service Locator - GetIt Dependency Injection
  initServiceLocator();

  // Restricts the app's orientation to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LoginBloc>()),
        BlocProvider(create: (_) => sl<UserInfoBloc>()),
        BlocProvider(create: (_) => sl<VerifyOtpBloc>()),
        BlocProvider(create: (_) => sl<ChangePasswordBloc>()),
        BlocProvider(create: (_) => sl<ProvincesBloc>()),
        BlocProvider(create: (_) => ProvincesMetadataBloc()),
        BlocProvider(create: (_) => sl<DistrictsBloc>()),
        BlocProvider(create: (_) => sl<CommunesBloc>()),
        BlocProvider(create: (_) => sl<ProvincesAgencyBloc>()),
        BlocProvider(create: (_) => sl<DistrictsAgencyBloc>()),
        BlocProvider(create: (_) => sl<CommunesAgencyBloc>()),
        BlocProvider(create: (_) => sl<ActiveGuaranteeBloc>()),
        BlocProvider(create: (_) => sl<CustomerSearchBloc>()),
        BlocProvider(create: (_) => sl<FetchCustomersPaginateBloc>()),
        BlocProvider(create: (_) => CustomerStatsBloc()),
        BlocProvider(create: (_) => sl<CustomerGuaranteeBloc>()),
        BlocProvider(create: (_) => sl<FetchCustomerBloc>()),
        BlocProvider(create: (_) => sl<AgencyBloc>()),
        BlocProvider(create: (_) => sl<AgenciesBloc>()),
        BlocProvider(create: (_) => sl<GuaranteeHistoryBloc>()),
        BlocProvider(create: (_) => UploadCubit()),
        BlocProvider(create: (_) => FetchStaffsCubit()),

        // Management for MBoss
        BlocProvider(create: (_) => sl<FetchMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<CreateMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<UpdateMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<DeleteMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<FetchAgenciesBloc>()),
        // Management for Agency
        BlocProvider(create: (_) => sl<CreateAgencyStaffBloc>()),
        BlocProvider(create: (_) => sl<FetchAgencyStaffBloc>()),
        BlocProvider(create: (_) => sl<UpdateAgencyStaffBloc>()),
        BlocProvider(create: (_) => sl<DeleteAgencyStaffBloc>()),

        BlocProvider(create: (_) => FetchAgencyAdminCubit()),
        BlocProvider(create: (_) => CreateAgencyBloc()),
        BlocProvider(create: (_) => sl<UpdateAgencyBloc>()),
        BlocProvider(create: (_) => sl<DeleteAgencyBloc>()),
        BlocProvider(create: (_) => NotificationCubit()),
        // For step handling
        BlocProvider(create: (_) => StepBloc(0)),
        BlocProvider(create: (_) => ProductBloc(null)),
        BlocProvider(create: (_) => CustomerBloc(null)),
        BlocProvider(create: (_) => AdditionalInfoBloc(null)),
        // Customer Care - CSKH
        BlocProvider(create: (_) => CycleBloc()),
        BlocProvider(create: (_) => FetchCustomersCubit()),
        BlocProvider(create: (_) => FetchGuaranteeByIdCubit()),
      ],
      child: DevicePreview(
        // enabled: !kReleaseMode,
        enabled: false,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MBossWater',
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('vi', 'VN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1),
          ),
          child: child!,
        );
      },
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
