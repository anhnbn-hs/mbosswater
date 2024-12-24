import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/encryption_helper.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/utils/storage.dart';
import 'package:mbosswater/core/widgets/feature_grid_item.dart';
import 'package:mbosswater/core/widgets/floating_action_button.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_state.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/login/presentation/page/login_page.dart';
import 'package:mbosswater/features/notification/notification_cubit.dart';
import 'package:mbosswater/features/notification/notification_state.dart';
import 'package:mbosswater/features/qrcode_scanner/presentation/page/qrcode_scanner_page.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_state.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  late CustomerSearchBloc bloc;
  late UserInfoBloc userInfoBloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<CustomerSearchBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: buildCustomFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 190,
                child: ImageHelper.loadAssetImage(
                  AppAssets.imgBgHome,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 10,
                right: 24,
                left: 16,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          DialogUtils.showConfirmationDialog(
                            context: context,
                            title: "Bạn chắc chắc muốn đăng xuất?",
                            labelTitle: "Đăng xuất",
                            textCancelButton: "HỦY",
                            textAcceptButton: "ĐĂNG XUẤT",
                            acceptPressed: () async => handleLogout(context),
                            cancelPressed: () => Navigator.pop(context),
                          );
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push("/notification");
                        },
                        child:
                            BlocBuilder<NotificationCubit, NotificationState>(
                          builder: (context, state) {
                            int notifyUnRead = 0;
                            if (state is NotificationLoaded) {
                              notifyUnRead =
                                  state.notifications.fold(0, (total, noti) {
                                if (!noti.isRead) {
                                  total += 1;
                                }
                                return total;
                              });
                            }
                            return Badge(
                              offset: const Offset(0, -2),
                              isLabelVisible: notifyUnRead != 0,
                              padding: const EdgeInsets.only(bottom: 2),
                              label: Text(
                                notifyUnRead.toString(),
                                style: AppStyle.appBarTitle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                              child: const CircleAvatar(
                                backgroundColor: Color(0xff3F689D),
                                radius: 20,
                                child: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                // top: MediaQuery.of(context).size.height * 0.27,
                top: 190 - 24,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: Color(0xffFAFAFA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      margin: const EdgeInsets.only(bottom: 50),
                      child: Column(
                        children: [
                          BlocBuilder(
                            bloc: userInfoBloc,
                            builder: (context, state) =>
                                buildSearchSection(context),
                          ),
                          BlocBuilder(
                            bloc: userInfoBloc,
                            builder: (context, state) {
                              if (state is UserInfoLoading) {
                                return Center(
                                  child: Lottie.asset(AppAssets.aLoading,
                                      height: 50),
                                );
                              }
                              if (state is UserInfoLoaded) {
                                return buildBodyByRole(state.user);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? buildCustomFloatingActionButton(BuildContext context) {
    // Return null if user is C-S-K-H (Customer care)
    return BlocBuilder(
      bloc: userInfoBloc,
      builder: (context, state) {
        if (state is UserInfoLoaded) {
          if (state.user.role == Roles.MBOSS_CUSTOMERCARE) {
            return const SizedBox.shrink();
          }
          return CustomFloatingActionButton(
            onTap: () {
              context.push(
                '/qrcode-scanner',
                extra: ScanType.activate,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildBodyByRole(UserModel user) {
    Widget body = Container();
    switch (user.role) {
      case Roles.AGENCY_BOSS:
        body = Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Kích hoạt bảo hành",
                    subtitle: "Quét mã sản phẩm\ntại đây",
                    assetIcon: AppAssets.icGuarantee,
                    onTap: () {
                      context.push(
                        '/qrcode-scanner',
                        extra: ScanType.activate,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureGridItem(
                    title: "Khách hàng",
                    subtitle: "Danh sách khách hàng",
                    assetIcon: AppAssets.icCustomer,
                    onTap: () => context.push("/customer-list"),
                  ),
                ),
              ],
            ),

            // Management
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Cài đặt tài khoản",
                    subtitle: "Thông tin tài khoản",
                    assetIcon: AppAssets.icAccount,
                    onTap: () => context.push("/user-profile"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureGridItem(
                    title: "Quản lý nhân viên",
                    subtitle: "Quản lý thông tin\nnhân viên",
                    assetIcon: AppAssets.icTeamManagement,
                    onTap: () {
                      context.push("/agency-staff-management");
                    },
                  ),
                ),
              ],
            ),
          ],
        );
        break;
      case Roles.AGENCY_TECHNICAL ||
            Roles.AGENCY_STAFF ||
            Roles.MBOSS_TECHNICAL:
        body = Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Kích hoạt bảo hành",
                    subtitle: "Quét mã sản phẩm\ntại đây",
                    assetIcon: AppAssets.icGuarantee,
                    onTap: () {
                      context.push(
                        '/qrcode-scanner',
                        extra: ScanType.activate,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureGridItem(
                    title: "Yêu cầu bảo hành",
                    subtitle: "Điền đơn yêu cầu tại đây",
                    assetIcon: AppAssets.icRequest,
                    onTap: () {
                      context.push(
                        '/qrcode-scanner',
                        extra: ScanType.request,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Cài đặt tài khoản",
                    subtitle: "Thông tin tài khoản",
                    assetIcon: AppAssets.icAccount,
                    onTap: () => context.push("/user-profile"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Container(
                  width: double.infinity,
                )),
              ],
            )
          ],
        );
        break;
      case Roles.MBOSS_ADMIN:
        body = Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Kích hoạt bảo hành",
                    subtitle: "Quét mã sản phẩm\ntại đây",
                    assetIcon: AppAssets.icGuarantee,
                    onTap: () {
                      context.push(
                        '/qrcode-scanner',
                        extra: ScanType.activate,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureGridItem(
                    title: "Quản lý đại lý",
                    subtitle: "Quản lý thông tin\nđại lý",
                    assetIcon: AppAssets.icAgencyManagement,
                    onTap: () {
                      context.push('/mboss-agency-management');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Quản lý nhân viên",
                    subtitle: "Quản lý thông tin\nnhân viên",
                    assetIcon: AppAssets.icTeamManagement,
                    onTap: () {
                      context.push('/mboss-staff-management');
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureGridItem(
                    title: "Quản lý khách hàng",
                    subtitle: "Quản lý thông tin\nkhách hàng",
                    assetIcon: AppAssets.icCustomer,
                    onTap: () {
                      context.push('/customer-list');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Cài đặt tài khoản",
                    subtitle: "Thông tin tài khoản",
                    assetIcon: AppAssets.icAccount,
                    onTap: () => context.push("/user-profile"),
                  ),
                ),
                const SizedBox(width: 20),
                const Spacer(),
              ],
            )
          ],
        );
        break;
      case Roles.MBOSS_CUSTOMERCARE:
        body = Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "CSKH",
                    subtitle: "Chăm sóc khách hàng",
                    assetIcon: AppAssets.icCSKH,
                    onTap: () {
                      context.push('/customer-care');
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureGridItem(
                    title: "Yêu cầu bảo hành",
                    subtitle: "Điền đơn yêu cầu tại đây",
                    assetIcon: AppAssets.icRequest,
                    onTap: () {
                      context.push(
                        '/qrcode-scanner',
                        extra: ScanType.request,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Cài đặt tài khoản",
                    subtitle: "Thông tin tài khoản",
                    assetIcon: AppAssets.icAccount,
                    onTap: () => context.push("/user-profile"),
                  ),
                ),
                const SizedBox(width: 20),
                const Spacer(),
              ],
            )
          ],
        );
        break;
      default:
    }
    return body;
  }

  Widget buildSearchSection(BuildContext context) {
    if (userInfoBloc.user?.role == Roles.MBOSS_ADMIN) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          color: const Color(0xffeeeeee),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TypeAheadField<Customer>(
          suggestionsCallback: (search) async {
            if (search.isNotEmpty) {
              if (Roles.LIST_ROLES_AGENCY.contains(userInfoBloc.user?.role)) {
                // Search for Agency user
                String? agencyID = userInfoBloc.user?.agency;
                bloc.add(
                  SearchAgencyCustomersByPhone(
                    search.trim(),
                    agencyID ?? "",
                  ),
                );
              } else {
                bloc.add(SearchAllCustomersByPhone(search.trim()));
              }
              await for (final state in bloc.stream) {
                if (state is CustomerSearchLoaded) {
                  return state.customers;
                } else if (state is CustomerSearchError) {
                  // Handle error case
                  return [];
                }
              }
              return [];
            }
            return null;
          },
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: "BeVietnam",
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              textAlignVertical: TextAlignVertical.center,
              onTapOutside: (event) =>
                  FocusScope.of(context).requestFocus(FocusNode()),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                hintText: "Tìm kiếm theo SĐT",
                hintStyle: TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xffA7A7A7),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                isCollapsed: true,
              ),
            );
          },
          loadingBuilder: (context) {
            return Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Lottie.asset(
                  AppAssets.aLoading,
                  height: 50,
                ),
              ),
            );
          },
          emptyBuilder: (context) {
            return Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: const Center(
                child: Text("Không tìm thấy khách hàng!"),
              ),
            );
          },
          errorBuilder: (context, error) {
            return Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: const Center(
                child: Text("Xảy ra lỗi. Hãy thử lại!"),
              ),
            );
          },
          itemBuilder: (context, customer) {
            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFEEEEEE),
                    width: .3,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.person_outlined,
                      color: Colors.black54,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: FractionalOffset.centerLeft,
                      child: Text(
                        "${customer.fullName} (${customer.phoneNumber})",
                        style: const TextStyle(
                          color: Color(0xff282828),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
          onSelected: (Customer value) {
            context.push(
              "/customer-detail",
              extra: value,
            );
          },
          // Additional customization options
          debounceDuration: const Duration(milliseconds: 800),
          hideOnEmpty: false,
          hideOnLoading: false,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> handleLogout(BuildContext context) async {
    try {
      DialogUtils.showLoadingDialog(context);
      // await FirebaseAuth.instance.signOut();
      await PreferencesUtils.deleteValue(loginSessionKey);
      if (Platform.isAndroid) {
        await FirebaseMessaging.instance.deleteToken();
      }
      await Future.delayed(const Duration(milliseconds: 800));
      userInfoBloc.reset();
      DialogUtils.hide(context);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
