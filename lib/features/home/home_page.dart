import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/utils/image_helper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Center(
                                  child: TextField(
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      hintText: "Tìm kiếm theo SĐT",
                                      hintStyle: GoogleFonts.beVietnamPro(
                                        color: const Color(0xffA7A7A7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Dịch vụ",
                            style: GoogleFonts.beVietnamPro(
                              color: const Color(0xff201E1E),
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ServiceGridItem(
                            title: "Kích hoạt bảo hành",
                            subtitle: "Quét mã sản phẩm tại đây",
                            assetIcon: AppAssets.icGuarantee,
                            onTap: () {},
                          ),
                        ),
                        // Management
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Quản lý",
                            style: GoogleFonts.beVietnamPro(
                              color: const Color(0xff201E1E),
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
                              child: ServiceGridItem(
                                title: "Quản lý nhân viên",
                                subtitle: "Quản lý thông tin nhân viên",
                                assetIcon: AppAssets.icTeamManagement,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ServiceGridItem(
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
}

class ServiceGridItem extends StatelessWidget {
  final String title, subtitle, assetIcon;
  final VoidCallback onTap;

  const ServiceGridItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffE5E5E5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImageHelper.loadAssetImage(
              assetIcon,
              width: 26,
              height: 26,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xff313131),
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xff828282),
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
