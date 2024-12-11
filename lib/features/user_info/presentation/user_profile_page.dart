import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/box_label_item.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
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
    if (Roles.LIST_ROLES_AGENCY.contains(userInfoBloc.user?.role)) {
      agencyBloc.fetchAgency(userInfoBloc.user?.agency ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        title: Text(
          "Thông Tin Tài Khoản",
          style: AppStyle.appBarTitle.copyWith(
            color: AppColors.appBarTitleColor,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<AgencyBloc, AgencyState>(
        bloc: agencyBloc,
        builder: (context, state) {
          Agency? agency;
          if (state is AgencyLoading) {
            return Center(
              child: Lottie.asset(AppAssets.aLoading, height: 70),
            );
          }
          if (state is AgencyLoaded) {
            agency = state.agency;
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder(
                bloc: userInfoBloc,
                builder: (context, state) {
                  if (state is UserInfoLoaded) {
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        BoxLabelItem(
                          label: "Họ và tên",
                          fieldValue: state.user.fullName ?? "",
                        ),
                        const SizedBox(height: 16),
                        BoxLabelItem(
                          label: "Số điện thoại",
                          fieldValue: state.user.phoneNumber ?? "",
                        ),
                        const SizedBox(height: 16),
                        BoxLabelItem(
                          label: "Chức vụ",
                          fieldValue: getRoleName(state.user.role ?? ""),
                        ),
                        const SizedBox(height: 16),
                        if (state.user.agency != null && agency != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: BoxLabelItem(
                              label: "Đại lý",
                              fieldValue: agency.name,
                            ),
                          ),
                        if (state.user.agency != null && agency != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: BoxLabelItem(
                              label: "Địa chỉ",
                              fieldValue: agency.address,
                            ),
                          ),
                        if (state.user.email != null)
                          BoxLabelItem(
                            label: "Email",
                            fieldValue: state.user.email,
                          ),
                        const SizedBox(height: 40),
                        CustomButton(
                          onTap: () {
                            context.push("/forgot-password");
                          },
                          textButton: "ĐỔI MẬT KHẨU",
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  String getRoleName(String role) {
    if (role == Roles.MBOSS_ADMIN) {
      return "Chủ MbossWater";
    }
    if (role == Roles.MBOSS_CUSTOMERCARE) {
      return "Chăm sóc khách hàng";
    }
    if (role == Roles.MBOSS_TECHNICAL || role == Roles.AGENCY_TECHNICAL) {
      return "Nhân viên kỹ thuật";
    }
    if (role == Roles.AGENCY_BOSS) {
      return "Chủ đại lý";
    }
    if (role == Roles.AGENCY_STAFF) {
      return "Nhân viên";
    }
    return "";
  }
}
