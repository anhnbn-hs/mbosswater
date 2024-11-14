import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/feature_grid_item.dart';
import 'package:mbosswater/core/widgets/floating_action_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CustomFloatingActionButton(
        onTap: () {
          context.push('/qrcode-scanner');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
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
                          size: MediaQuery.of(context).size,
                          title: "Bạn chắc chắc muốn đăng xuất?",
                          labelTitle: "Đăng xuất",
                          textCancelButton: "Hủy",
                          textAcceptButton: "Đăng xuất",
                          acceptPressed: () => handleLogout(context),
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Color(0xff3F689D),
                      radius: 20,
                      child: Text(
                        "T",
                        style: TextStyle(
                          fontFamily: 'BeVietnam',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          height: -.2,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 250,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xffeeeeee),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 22,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Center(
                                  child: TextField(
                                    style: TextStyle(
                                      fontFamily: "BeVietnam",
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
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
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
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
                            onTap: () {},
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
                                subtitle: "Quản lý thông tin nhân viên",
                                assetIcon: AppAssets.icTeamManagement,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: FeatureGridItem(
                                title: "Mua bán hàng",
                                subtitle: "Mua bán hàng với đại lý",
                                assetIcon: AppAssets.icTeamManagement,
                                onTap: () {},
                              ),
                            ),
                          ],
                        )
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

  handleLogout(BuildContext context) async {
    try {
      DialogUtils.showLoadingDialog(context);
      await Future.delayed(const Duration(milliseconds: 1000));
      await FirebaseAuth.instance.signOut();
      while (context.canPop()) {
        context.pop();
      }
      context.push("/login");
    } on Exception catch (e) {}
  }
}
