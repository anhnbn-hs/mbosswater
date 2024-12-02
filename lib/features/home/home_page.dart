import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/feature_grid_item.dart';
import 'package:mbosswater/core/widgets/floating_action_button.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_state.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 253,
              child: ImageHelper.loadAssetImage(
                AppAssets.imgBgHome,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: 36,
              right: 16,
              left: 10,
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
                          textCancelButton: "Hủy",
                          textAcceptButton: "Đăng xuất",
                          acceptPressed: () => handleLogout(context),
                          cancelPressed: () => Navigator.pop(context),
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                    ),
                    BlocBuilder(
                      bloc: userInfoBloc,
                      builder: (context, state) {
                        if (state is UserInfoLoaded) {
                          return CircleAvatar(
                            backgroundColor: const Color(0xff3F689D),
                            radius: 20,
                            child: Text(
                              state.user.fullName![0],
                              style: const TextStyle(
                                fontFamily: 'BeVietnam',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                height: -.2,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              // top: MediaQuery.of(context).size.height * 0.27,
              top: 253 - 24,
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
                        buildSearchSection(context),
                        const SizedBox(height: 30),
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Dịch vụ",
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xff201E1E),
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FeatureGridItem(
                title: "Kích hoạt bảo hành",
                subtitle: "Quét mã sản phẩm tại đây",
                assetIcon: AppAssets.icGuarantee,
                onTap: () {
                  context.push(
                    '/qrcode-scanner',
                    extra: ScanType.activate,
                  );
                },
              ),
            ),
            // Management
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Quản lý",
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xff201E1E),
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Quản lý nhân viên",
                    subtitle: "Quản lý thông tin\nnhân viên",
                    assetIcon: AppAssets.icTeamManagement,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureGridItem(
                    title: "Mua bán hàng",
                    subtitle: "Mua bán hàng với\nđại lý",
                    assetIcon: AppAssets.icCart,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Cài đặt tài khoản",
                    subtitle: "Thông tin tài khoản",
                    assetIcon: AppAssets.icAccount,
                    onTap: () {},
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
          ],
        );
        break;
      case Roles.AGENCY_TECHNICAL ||
            Roles.AGENCY_STAFF ||
            Roles.MBOSS_TECHNICAL:
        body = Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Dịch vụ",
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xff201E1E),
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Kích hoạt bảo hành",
                    subtitle: "Quét mã sản phẩm tại đây",
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
                    child: Container(
                  width: double.infinity,
                )),
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
                    onTap: () {
                      context.push('/setting-account');
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
            )
          ],
        );
        break;
      case Roles.MBOSS_ADMIN:
        body = Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Dịch vụ",
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xff201E1E),
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Kích hoạt bảo hành",
                    subtitle: "Quét mã sản phẩm",
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
                    subtitle: "Thông tin khách hàng",
                    assetIcon: AppAssets.icCustomer,
                    onTap: () {
                      context.push('/customer-list');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Quản lý",
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xff201E1E),
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureGridItem(
                    title: "Cài đặt tài khoản",
                    subtitle: "Thông tin tài khoản",
                    assetIcon: AppAssets.icAccount,
                    onTap: () {
                      context.push('/setting-account');
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureGridItem(
                    title: "Quản lý nhân viên",
                    subtitle: "Quản lý thông tin nhân viên",
                    assetIcon: AppAssets.icTeamManagement,
                    onTap: () {
                      context.push('/staff-management');
                    },
                  ),
                ),
              ],
            )
          ],
        );
        break;
      case Roles.MBOSS_CUSTOMERCARE:
        body = Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Dịch vụ",
                style: TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xff201E1E),
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                    onTap: () {
                      context.push('/setting-account');
                    },
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

  Container buildSearchSection(BuildContext context) {
    return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xffeeeeee),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 28),
              child: TypeAheadField<Customer>(
                suggestionsCallback: (search) async {
                  if (search.isNotEmpty) {
                    if (Roles.LIST_ROLES_AGENCY
                        .contains(userInfoBloc.user?.role)) {
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
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Tìm kiếm theo SĐT",
                      hintStyle: TextStyle(
                        fontFamily: "BeVietnam",
                        color: Color(0xffA7A7A7),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
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
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.search,
                size: 22,
                color: Colors.grey,
              ),
            ),
          ],
        ));
  }

  handleLogout(BuildContext context) async {
    try {
      DialogUtils.showLoadingDialog(context);
      await FirebaseAuth.instance.signOut();
      await FirebaseMessaging.instance.deleteToken();
      await Future.delayed(const Duration(milliseconds: 1000));
      while (context.canPop()) {
        context.pop();
      }
      context.push("/login");
    } on Exception catch (e) {}
  }
}
