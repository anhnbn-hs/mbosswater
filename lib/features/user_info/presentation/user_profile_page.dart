import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_state.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late UserInfoBloc userInfoBloc;
  late AgencyBloc agencyBloc;

  @override
  void initState() {
    super.initState();
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    agencyBloc = BlocProvider.of<AgencyBloc>(context);
    agencyBloc.fetchAgency(userInfoBloc.user?.agency ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
      ),
      body: BlocBuilder<AgencyBloc, AgencyState>(
        bloc: agencyBloc,
        builder: (context, state) {
          if (state is AgencyLoading) {
            return Center(
              child: Lottie.asset(AppAssets.aLoading, height: 70),
            );
          }
          if (state is AgencyLoaded) {
            final agency = state;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder(
                bloc: userInfoBloc,
                builder: (context, state) {
                  if (state is UserInfoLoaded) {
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Thông Tin Tài Khoản",
                            style: TextStyle(
                              color: Color(0xff820A1A),
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        buildBoxInfoItem(value: state.user.fullName ?? ""),
                        buildBoxInfoItem(value: state.user.phoneNumber ?? ""),
                        buildBoxInfoItem(value: state.user.role ?? ""),
                        buildBoxInfoItem(value: agency.agency.name),
                        buildBoxInfoItem(value: state.user.address ?? ""),
                        buildBoxInfoItem(value: state.user.email),
                        const SizedBox(height: 56),
                        CustomButton(
                          onTap: () {},
                          textButton: "ĐỔI MẬT KHẨU",
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Container buildBoxInfoItem({required String value}) {
    return Container(
      height: 42,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xffD9D9D9),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: AppStyle.boxField.copyWith(
            color: const Color((0xffB3B3B3)),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
