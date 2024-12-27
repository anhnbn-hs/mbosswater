
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/utils/storage.dart';
import 'package:mbosswater/features/notification/notification_cubit.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_event.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late UserInfoBloc userInfoBloc;
  late NotificationCubit notificationCubit;

  @override
  void initState() {
    super.initState();
    notificationCubit = BlocProvider.of<NotificationCubit>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    navigate();
  }

  Future<void> navigate() async {
    String? currentUserID = await PreferencesUtils.getString(loginSessionKey);
    if (currentUserID != null) {
      // Fetch user data
      userInfoBloc.add(FetchUserInfo(currentUserID));
      notificationCubit.fetchNotifications(currentUserID);
    } else {
      print("Don't have any users in session. Continue navigate to Login Page");
      await Future.delayed(
        const Duration(milliseconds: 500),
        () => context.go("/login"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: userInfoBloc,
      listener: (context, state) {
        if (state is UserInfoLoaded) {
          context.go("/home");
        }
        if (state is UserInfoError) {
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Có lỗi xảy ra!. Hãy đăng nhập lại"),
                ),
              );
              context.go("/login");
            },
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageHelper.loadAssetImage(AppAssets.imgLogo),
              const SizedBox(height: 10),
              Text(
                "MBossWater",
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
