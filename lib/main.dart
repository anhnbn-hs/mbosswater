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
import 'package:mbosswater/core/utils/encryption_helper.dart';
import 'package:mbosswater/features/agency/presentation/bloc/fetch_agency_staff_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customers_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/additional_info_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agencies_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/customer_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/product_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/step_bloc.dart';
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
import 'package:mbosswater/features/recovery/presentation/bloc/verify_email_bloc.dart';
import 'package:mbosswater/features/recovery/presentation/bloc/verify_otp_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';
import 'package:mbosswater/go_router.dart';
import 'features/login/presentation/bloc/login_bloc.dart';
import 'injection_container.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  // Initialize NotificationService
  await NotificationService.init();

  // Initialize FirebaseCloudMessage
  final FirebaseCloudMessage fcm = FirebaseCloudMessage();

  await fcm.initialize();

  // Initialize Service Locator - GetIt Dependency Injection
  initServiceLocator();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  //
  // String data =
    //     '{"code":"mbosswater","product":{"id":"MLN10019","name":"Máy Lọc Nước Tạo Kiềm MBossWater","model":"Model11","seriDow":"SRD09","guaranteeDuration":"12 tháng"}}';
  //
  // String dataEncri = EncryptionHelper.decryptData("3X5d+/h+c+UWnqdYupqb1w==T4gFG2afauSMqIcC2dd6+FUa4/nbSS6Tk/c8X8FvgQbyB1ArH2VfhrxkkDwuisXnXCXf4l84cSu4Z4KL4AdI6t5yyFC0aGT2QpZ1QIpAWcNqooEgBDPDCXz8zhnmLO2eSNuNMQm5IdLoLo3i1Gkn1TnVe4VILn6fUxgSUp9IP34/1AnAAv0cIOlU1iuUqn5wKYZq+K5Ijpqir7vC+Yuaf7N9DfSMMKrFw+7lzOVRAz8=", dotenv.env["SECRET_KEY_QR_CODE"]!);
  //
  // print(dataEncri);
  // await updateAllAgencyAddresses();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LoginBloc>()),
        BlocProvider(create: (_) => sl<UserInfoBloc>()),
        BlocProvider(create: (_) => sl<VerifyEmailBloc>()),
        BlocProvider(create: (_) => sl<VerifyOtpBloc>()),
        BlocProvider(create: (_) => sl<ChangePasswordBloc>()),
        BlocProvider(create: (_) => sl<ProvincesBloc>()),
        BlocProvider(create: (_) => sl<DistrictsBloc>()),
        BlocProvider(create: (_) => sl<CommunesBloc>()),
        BlocProvider(create: (_) => sl<ProvincesAgencyBloc>()),
        BlocProvider(create: (_) => sl<DistrictsAgencyBloc>()),
        BlocProvider(create: (_) => sl<CommunesAgencyBloc>()),
        BlocProvider(create: (_) => sl<ActiveGuaranteeBloc>()),
        BlocProvider(create: (_) => sl<CustomerSearchBloc>()),
        BlocProvider(create: (_) => sl<CustomerGuaranteeBloc>()),
        BlocProvider(create: (_) => sl<FetchCustomersBloc>()),
        BlocProvider(create: (_) => sl<FetchCustomerBloc>()),
        BlocProvider(create: (_) => sl<AgencyBloc>()),
        BlocProvider(create: (_) => sl<AgenciesBloc>()),
        BlocProvider(create: (_) => sl<GuaranteeHistoryBloc>()),
        BlocProvider(create: (_) => sl<FetchMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<CreateMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<UpdateMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<DeleteMbossStaffBloc>()),
        BlocProvider(create: (_) => sl<FetchAgencyStaffBloc>()),
        BlocProvider(create: (_) => sl<FetchAgenciesBloc>()),
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
      ],
      child: DevicePreview(
        // enabled: !kReleaseMode,
        enabled: false,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

Future<void> updateAllAgencyAddresses() async {
  try {
    // Reference to the 'agencies' collection
    final CollectionReference usersRef =
    FirebaseFirestore.instance.collection('users');

    // Fetch all agencies
    final QuerySnapshot snapshot = await usersRef.get();

    // Loop through each document and update its address
    for (final doc in snapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;

      // Construct the new address (modify this logic as needed)
      final Address newAddress = Address(
        province: "Bắc Ninh",
        district: "Quế Võ",
        commune: "Yên Giả",
        detail: "36 Ngô Gia Tự",
      );

      // Update the Firestore document with the new address
      await usersRef.doc(doc.id).update({
        'address': newAddress.toJson(),
      });

      print("Updated user ${doc.id}");
    }

    print("All agencies updated successfully!");
  } catch (e) {
    print("Error updating agencies: $e");
  }
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
      ],
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
