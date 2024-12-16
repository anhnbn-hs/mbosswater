import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/step_active_screen/customer_info_step.dart';

String generateRandomId(int length) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => characters.codeUnitAt(
        random.nextInt(characters.length),
      ),
    ),
  );
}

bool isExpired(DateTime endDate) {
  final now = DateTime.now();
  return endDate.isBefore(now);
}

int getRemainingMonths(DateTime endDate) {
  final now = DateTime.now().toUtc().add(const Duration(hours: 7));

  if (endDate.isBefore(now)) {
    return 0;
  }

  int remainingYears = endDate.year - now.year;
  int remainingMonths = endDate.month - now.month;

  return (remainingYears * 12) + remainingMonths;
}

// Duration unit = month
DateTime calculateEndDateFromDuration(int duration) {
  DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
  int newMonth = now.month + duration;
  int yearAdjustment =
      (newMonth - 1) ~/ 12; // Handle overflow of months into the next year
  int finalMonth = ((newMonth - 1) % 12) + 1;

  // Return the adjusted DateTime
  return DateTime(
    now.year + yearAdjustment,
    finalMonth,
    now.day,
    now.hour,
    now.minute,
    now.second,
  );
}

showBottomSheetChooseAddressAgency({
  required BuildContext context,
  required AddressType addressType,
  required PageController pageController,
  required ProvincesAgencyBloc? provincesAgencyBloc,
  required DistrictsAgencyBloc? districtsAgencyBloc,
  required CommunesAgencyBloc? communesAgencyBloc,
}) {
  // Fetch init
  final size = MediaQuery.of(context).size;

  if (addressType == AddressType.province) {
    pageController = PageController(initialPage: 0);
    provincesAgencyBloc?.emitProvincesFullList();
  }
  if (addressType == AddressType.district) {
    if (provincesAgencyBloc?.selectedProvince == null) {
      return;
    }
    pageController = PageController(initialPage: 1);
  }
  if (addressType == AddressType.commune) {
    if (districtsAgencyBloc?.selectedDistrict == null) {
      return;
    }
    pageController = PageController(initialPage: 2);
  }

  Widget buildProvinceBlocBuilder() {
    return BlocBuilder(
      bloc: provincesAgencyBloc,
      builder: (context, state) {
        if (state is ProvincesLoading) {
          return Center(
            child: Lottie.asset(AppAssets.aLoading, height: 50),
          );
        }
        if (state is ProvincesLoaded) {
          final provinces = state.provinces;
          return ListView.builder(
            itemCount: provinces.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade400,
                      width: .2,
                    ),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    // Reset
                    districtsAgencyBloc?.selectedDistrict = null;
                    communesAgencyBloc?.selectedCommune = null;

                    provincesAgencyBloc?.selectProvince(provinces[index]);

                    // Fetch districts
                    Province? province = provincesAgencyBloc?.selectedProvince;

                    districtsAgencyBloc
                        ?.add(FetchDistricts(province!.id ?? ""));
                    // Change page view
                    pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.bounceIn,
                    );
                  },
                  leading: null,
                  minTileHeight: 48,
                  titleAlignment: ListTileTitleAlignment.center,
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    provinces[index].name ?? "",
                    style: AppStyle.boxField.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildDistrictBlocBuilder() {
    return BlocBuilder(
      bloc: districtsAgencyBloc,
      builder: (context, state) {
        if (state is DistrictsLoading) {
          return Center(
            child: Lottie.asset(AppAssets.aLoading, height: 50),
          );
        }
        if (state is DistrictsLoaded) {
          final districts = state.districts;
          return ListView.builder(
            itemCount: districts.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade400,
                      width: .2,
                    ),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    districtsAgencyBloc?.selectDistrict(districts[index]);
                    // Fetch commune
                    District? district = districtsAgencyBloc?.selectedDistrict;
                    communesAgencyBloc?.add(FetchCommunes(district!.id ?? ""));
                    // Change page view
                    pageController.animateToPage(
                      2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.bounceIn,
                    );
                  },
                  leading: null,
                  minTileHeight: 48,
                  titleAlignment: ListTileTitleAlignment.center,
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    districts[index].name ?? "",
                    style: AppStyle.boxField.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildCommuneBlocBuilder() {
    return BlocBuilder(
      bloc: communesAgencyBloc,
      builder: (context, state) {
        if (state is CommunesLoading) {
          return Center(
            child: Lottie.asset(AppAssets.aLoading, height: 50),
          );
        }
        if (state is CommunesLoaded) {
          final communes = state.communes;
          return ListView.builder(
            itemCount: communes.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade400,
                      width: .2,
                    ),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    communesAgencyBloc?.selectCommune(communes[index]);
                    context.pop();
                  },
                  leading: null,
                  minTileHeight: 48,
                  titleAlignment: ListTileTitleAlignment.center,
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    communes[index].name ?? "",
                    style: AppStyle.boxField.copyWith(
                        color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  showModalBottomSheet(
    elevation: 1,
    isDismissible: true,
    barrierLabel: '',
    isScrollControlled: true,
    backgroundColor: Colors.white,
    context: context,
    builder: (context) {
      return SizedBox(
        height: size.height * 0.85,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 46),
                    child: Text(
                      "Chọn",
                      style: AppStyle.heading2.copyWith(fontSize: 18),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (addressType == AddressType.province)
                          Text(
                            "Tỉnh thành",
                            style: AppStyle.heading2.copyWith(fontSize: 16),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: const Color(0xffEEEEEE),
                          ),
                          child: Center(
                            child: TextField(
                              style: AppStyle.boxField.copyWith(fontSize: 15),
                              onChanged: (value) {
                                provincesAgencyBloc
                                    ?.add(SearchProvinces(value));
                              },
                              onTapOutside: (event) =>  FocusScope.of(context).requestFocus(FocusNode()),
                              decoration: InputDecoration(
                                hintText: "Tìm kiếm tỉnh thành",
                                hintStyle:
                                    AppStyle.boxField.copyWith(fontSize: 15),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: buildProvinceBlocBuilder(),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder(
                          bloc: provincesAgencyBloc,
                          builder: (context, state) {
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    pageController.animateToPage(
                                      0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    provincesAgencyBloc
                                            ?.selectedProvince!.name ??
                                        "",
                                    style: AppStyle.heading2.copyWith(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "Quận/Huyện",
                                  style:
                                      AppStyle.heading2.copyWith(fontSize: 16),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: const Color(0xffEEEEEE),
                          ),
                          child: Center(
                            child: BlocBuilder(
                              bloc: provincesAgencyBloc,
                              builder: (context, state) {
                                return TextField(
                                  style:
                                      AppStyle.boxField.copyWith(fontSize: 15),
                                  onChanged: (value) {
                                    districtsAgencyBloc
                                        ?.add(SearchDistrict(value));
                                  },
                                  onTapOutside: (event) =>  FocusScope.of(context).requestFocus(FocusNode()),
                                  decoration: InputDecoration(
                                    hintText: "Tìm kiếm quận huyện",
                                    hintStyle: AppStyle.boxField
                                        .copyWith(fontSize: 15),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    border: const UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: buildDistrictBlocBuilder(),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder(
                          bloc: districtsAgencyBloc,
                          builder: (context, state) {
                            return Wrap(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    pageController.animateToPage(
                                      0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    provincesAgencyBloc
                                            ?.selectedProvince!.name! ??
                                        "",
                                    style: AppStyle.heading2.copyWith(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    pageController.animateToPage(
                                      1,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    districtsAgencyBloc
                                            ?.selectedDistrict!.name! ??
                                        "",
                                    style: AppStyle.heading2.copyWith(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "Phường/Xã",
                                  style:
                                      AppStyle.heading2.copyWith(fontSize: 16),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: const Color(0xffEEEEEE)),
                          child: Center(
                            child: TextField(
                              style: AppStyle.boxField.copyWith(fontSize: 15),
                              onChanged: (value) {
                                communesAgencyBloc?.add(SearchCommunes(value));
                              },
                              onTapOutside: (event) =>  FocusScope.of(context).requestFocus(FocusNode()),
                              decoration: InputDecoration(
                                hintText: "Tìm kiếm phường xã",
                                hintStyle:
                                    AppStyle.boxField.copyWith(fontSize: 15),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: buildCommuneBlocBuilder(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

showBottomSheetChooseAddress({
  required BuildContext context,
  required AddressType addressType,
  required PageController pageController,
  required ProvincesBloc? provincesBloc,
  required DistrictsBloc? districtsBloc,
  required CommunesBloc? communesBloc,
}) {
  // Fetch init
  final size = MediaQuery.of(context).size;

  if (addressType == AddressType.province) {
    pageController = PageController(initialPage: 0);
    provincesBloc?.emitProvincesFullList();
  }
  if (addressType == AddressType.district) {
    if (provincesBloc?.selectedProvince == null) {
      return;
    }
    pageController = PageController(initialPage: 1);
  }
  if (addressType == AddressType.commune) {
    if (districtsBloc?.selectedDistrict == null) {
      return;
    }
    pageController = PageController(initialPage: 2);
  }

  Widget buildProvinceBlocBuilder() {
    return BlocBuilder(
      bloc: provincesBloc,
      builder: (context, state) {
        if (state is ProvincesLoading) {
          return Center(
            child: Lottie.asset(AppAssets.aLoading, height: 50),
          );
        }
        if (state is ProvincesLoaded) {
          final provinces = state.provinces;
          return ListView.builder(
            itemCount: provinces.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade400,
                      width: .2,
                    ),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    // Reset
                    districtsBloc?.selectedDistrict = null;
                    communesBloc?.selectedCommune = null;

                    provincesBloc?.selectProvince(provinces[index]);

                    // Fetch districts
                    Province? province = provincesBloc?.selectedProvince;

                    districtsBloc?.add(FetchDistricts(province!.id!));
                    // Change page view
                    pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.bounceIn,
                    );
                  },
                  leading: null,
                  minTileHeight: 48,
                  titleAlignment: ListTileTitleAlignment.center,
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    provinces[index].name!,
                    style: AppStyle.boxField.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildDistrictBlocBuilder() {
    return BlocBuilder(
      bloc: districtsBloc,
      builder: (context, state) {
        if (state is DistrictsLoading) {
          return Center(
            child: Lottie.asset(AppAssets.aLoading, height: 50),
          );
        }
        if (state is DistrictsLoaded) {
          final districts = state.districts;
          return ListView.builder(
            itemCount: districts.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade400,
                      width: .2,
                    ),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    districtsBloc?.selectDistrict(districts[index]);

                    // Fetch commune
                    District? district = districtsBloc?.selectedDistrict;
                    communesBloc?.add(FetchCommunes(district!.id!));
                    // Change page view
                    pageController.animateToPage(
                      2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.bounceIn,
                    );
                  },
                  leading: null,
                  minTileHeight: 48,
                  titleAlignment: ListTileTitleAlignment.center,
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    districts[index].name!,
                    style: AppStyle.boxField.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildCommuneBlocBuilder() {
    return BlocBuilder(
      bloc: communesBloc,
      builder: (context, state) {
        if (state is CommunesLoading) {
          return Center(
            child: Lottie.asset(AppAssets.aLoading, height: 50),
          );
        }
        if (state is CommunesLoaded) {
          final communes = state.communes;
          return ListView.builder(
            itemCount: communes.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade400,
                      width: .2,
                    ),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    communesBloc?.selectCommune(communes[index]);

                    context.pop();
                  },
                  leading: null,
                  minTileHeight: 48,
                  titleAlignment: ListTileTitleAlignment.center,
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    communes[index].name!,
                    style: AppStyle.boxField.copyWith(
                        color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  showModalBottomSheet(
    elevation: 1,
    isDismissible: true,
    barrierLabel: '',
    isScrollControlled: true,
    backgroundColor: Colors.white,
    context: context,
    builder: (context) {
      return SizedBox(
        height: size.height * 0.85,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 46),
                    child: Text(
                      "Chọn",
                      style: AppStyle.heading2.copyWith(fontSize: 18),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (addressType == AddressType.province)
                          Text(
                            "Tỉnh thành",
                            style: AppStyle.heading2.copyWith(fontSize: 16),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: const Color(0xffEEEEEE),
                          ),
                          child: Center(
                            child: TextField(
                              style: AppStyle.boxField.copyWith(fontSize: 15),
                              onChanged: (value) {
                                provincesBloc?.add(SearchProvinces(value));
                              },
                              onTapOutside: (event) =>  FocusScope.of(context).requestFocus(FocusNode()),
                              decoration: InputDecoration(
                                hintText: "Tìm kiếm tỉnh thành",
                                hintStyle:
                                    AppStyle.boxField.copyWith(fontSize: 15),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: buildProvinceBlocBuilder(),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder(
                          bloc: provincesBloc,
                          builder: (context, state) {
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    pageController.animateToPage(
                                      0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    provincesBloc?.selectedProvince!.name ?? "",
                                    style: AppStyle.heading2.copyWith(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "Quận/Huyện",
                                  style:
                                      AppStyle.heading2.copyWith(fontSize: 16),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: const Color(0xffEEEEEE),
                          ),
                          child: Center(
                            child: BlocBuilder(
                              bloc: provincesBloc,
                              builder: (context, state) {
                                return TextField(
                                  style:
                                      AppStyle.boxField.copyWith(fontSize: 15),
                                  onChanged: (value) {
                                    districtsBloc?.add(SearchDistrict(value));
                                  },
                                  onTapOutside: (event) =>  FocusScope.of(context).requestFocus(FocusNode()),
                                  decoration: InputDecoration(
                                    hintText: "Tìm kiếm quận huyện",
                                    hintStyle: AppStyle.boxField
                                        .copyWith(fontSize: 15),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    border: const UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: buildDistrictBlocBuilder(),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder(
                          bloc: districtsBloc,
                          builder: (context, state) {
                            return Wrap(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    pageController.animateToPage(
                                      0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    provincesBloc?.selectedProvince!.name! ??
                                        "",
                                    style: AppStyle.heading2.copyWith(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    pageController.animateToPage(
                                      1,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    districtsBloc?.selectedDistrict!.name! ??
                                        "",
                                    style: AppStyle.heading2.copyWith(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "Phường/Xã",
                                  style:
                                      AppStyle.heading2.copyWith(fontSize: 16),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: const Color(0xffEEEEEE)),
                          child: Center(
                            child: TextField(
                              style: AppStyle.boxField.copyWith(fontSize: 15),
                              onChanged: (value) {
                                communesBloc?.add(SearchCommunes(value));
                              },
                              onTapOutside: (event) =>  FocusScope.of(context).requestFocus(FocusNode()),
                              decoration: InputDecoration(
                                hintText: "Tìm kiếm phường xã",
                                hintStyle:
                                    AppStyle.boxField.copyWith(fontSize: 15),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: buildCommuneBlocBuilder(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
