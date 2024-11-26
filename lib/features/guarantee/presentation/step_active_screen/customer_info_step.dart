// Step 2: Customer Information
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/customer_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/step_bloc.dart';

class CustomerInfoStep extends StatefulWidget {
  final VoidCallback onNextStep, onPreStep;

  const CustomerInfoStep({
    super.key,
    required this.onPreStep,
    required this.onNextStep,
  });

  @override
  State<CustomerInfoStep> createState() => CustomerInfoStepState();
}

class CustomerInfoStepState extends State<CustomerInfoStep>
    with AutomaticKeepAliveClientMixin {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  final addressController = TextEditingController();

  final phoneController = TextEditingController();

  final emailController = TextEditingController();

  var pageController = PageController();

  // Step Bloc
  late StepBloc stepBloc;
  late CustomerBloc customerBloc;

  // Address BLOC
  late ProvincesBloc provincesBloc;
  late DistrictsBloc districtsBloc;
  late CommunesBloc communesBloc;

  final provinceGlobalKey = GlobalKey();
  final districtGlobalKey = GlobalKey();
  final communeGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    stepBloc = BlocProvider.of<StepBloc>(context);
    customerBloc = BlocProvider.of<CustomerBloc>(context);
    provincesBloc = BlocProvider.of<ProvincesBloc>(context);
    districtsBloc = BlocProvider.of<DistrictsBloc>(context);
    communesBloc = BlocProvider.of<CommunesBloc>(context);
    // Fetch VN province list
    provincesBloc.add(FetchProvinces());
  }

  void forceRebuild() {
    provinceGlobalKey.currentState?.setState(() {});
    districtGlobalKey.currentState?.setState(() {});
    communeGlobalKey.currentState?.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener(
      bloc: provincesBloc,
      listener: (context, state) {
        // if (state is ProvincesLoading) {
        //   DialogUtils.showLoadingDialog(context);
        // }
        // if (state is ProvincesLoaded) {
        //   DialogUtils.hide(context);
        // }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextFieldItem(
                  label: "Họ và tên khách hàng",
                  hint: "Nhập họ tên khách hàng",
                  controller: nameController,
                ),
                const SizedBox(height: 12),
                buildTextFieldItem(
                  label: "Số điện thoại",
                  hint: "SĐT",
                  inputType: TextInputType.number,
                  controller: phoneController,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    children: [
                      Text(
                        "Địa chỉ",
                        style: AppStyle.boxFieldLabel,
                      ),
                      Text(
                        " * ",
                        style: AppStyle.boxFieldLabel.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                BlocBuilder(
                  bloc: provincesBloc,
                  builder: (context, state) {
                    return buildAddressItem(
                      label: provincesBloc.selectedProvince?.name ?? "Tỉnh/TP",
                      addressType: AddressType.province,
                    );
                  },
                ),

                const SizedBox(height: 12),

                BlocBuilder(
                  bloc: districtsBloc,
                  builder: (context, state) {
                    return buildAddressItem(
                      label:
                          districtsBloc.selectedDistrict?.name ?? "Quận/Huyện",
                      addressType: AddressType.district,
                    );
                  },
                ),

                const SizedBox(height: 12),

                BlocBuilder(
                  bloc: communesBloc,
                  builder: (context, state) {
                    return buildAddressItem(
                      label: communesBloc.selectedCommune?.name ?? "Phường/Xã",
                      addressType: AddressType.commune,
                    );
                  },
                ),

                buildTextFieldItem(
                  label: "",
                  hint: "Địa chỉ chi tiết",
                  controller: addressController,
                  isRequired: false,
                ),

                const SizedBox(height: 12),
                buildTextFieldItem(
                  label: "Email",
                  hint: "Email",
                  controller: emailController,
                  isRequired: false,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  onTap: () {
                    handleAndGoToNextStep();
                  },
                  textButton: "TIẾP TỤC",
                ),
                const SizedBox(height: 24),
                // Handle Listener
                // BlocListener<StepBloc, int>(
                //   bloc: stepBloc,
                //   listener: (context, state) {
                //     if (state == 2) {
                //       if (!checkInput()) {
                //         DialogUtils.showWarningDialog(
                //           context: context,
                //           title: "Vui lòng hoàn thành bước trước đó!",
                //           canDismissible: false,
                //           onClickOutSide: () {},
                //         );
                //       }
                //     }
                //   },
                //   child: const SizedBox.shrink(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddressItem(
      {required String label, required AddressType addressType}) {
    return GestureDetector(
      onTap: () => showBottomSheetChooseAddress(context, addressType),
      child: Container(
        height: 38,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xffBDBDBD),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppStyle.boxField.copyWith(
                    // fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }

  Widget buildTextFieldItem({
    required String label,
    required String hint,
    bool isRequired = true,
    TextInputType inputType = TextInputType.text,
    required TextEditingController controller,
  }) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: label != ""
              ? Row(
                  children: [
                    Text(
                      label,
                      style: AppStyle.boxFieldLabel,
                    ),
                    isRequired
                        ? Text(
                            " * ",
                            style: AppStyle.boxFieldLabel.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        Container(
          height: 38,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffBDBDBD),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            style: AppStyle.boxField.copyWith(),
            decoration: InputDecoration(
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              hintText: hint,
              hintStyle: AppStyle.boxField
                  .copyWith(fontStyle: FontStyle.italic, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            cursorColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  bool checkInput() {
    String name = nameController.text;
    String phone = phoneController.text;
    String detailAddress = addressController.text;
    final province = provincesBloc.selectedProvince;
    final district = districtsBloc.selectedDistrict;
    final commune = communesBloc.selectedCommune;
    // Some fields

    // bool validate = formKey.currentState!.validate();
    if (name.isEmpty ||
        phone.isEmpty ||
        detailAddress.isEmpty ||
        province == null ||
        district == null ||
        commune == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  bool get wantKeepAlive => true;

  void handleAndGoToNextStep() {
    if (checkInput()) {
      customerBloc.emitCustomer(
        Customer(
          id: generateRandomId(6),
          fullName: nameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          address: Address(
            province: provincesBloc.selectedProvince?.name,
            district: districtsBloc.selectedDistrict?.name,
            commune: communesBloc.selectedCommune?.name,
            detail: addressController.text,
          ),
        ),
      );
      widget.onNextStep();
    } else {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập đầy đủ thông tin khách hàng!",
        onClickOutSide: () {},
      );
    }
  }

  showBottomSheetChooseAddress(BuildContext context, AddressType addressType) {
    final size = MediaQuery.of(context).size;

    if (addressType == AddressType.province) {
      pageController = PageController(initialPage: 0);
      provincesBloc.emitProvincesFullList();
    }
    if (addressType == AddressType.district) {
      if (provincesBloc.selectedProvince == null) {
        return;
      }
      pageController = PageController(initialPage: 1);
    }
    if (addressType == AddressType.commune) {
      if (districtsBloc.selectedDistrict == null) {
        return;
      }
      pageController = PageController(initialPage: 2);
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
                                  provincesBloc.add(SearchProvinces(value));
                                },
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
                                      provincesBloc.selectedProvince!.name!,
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
                                    style: AppStyle.heading2
                                        .copyWith(fontSize: 16),
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
                                    style: AppStyle.boxField
                                        .copyWith(fontSize: 15),
                                    onChanged: (value) {
                                      districtsBloc.add(SearchDistrict(value));
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Tìm kiếm quận huyện",
                                      hintStyle: AppStyle.boxField
                                          .copyWith(fontSize: 15),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                      provincesBloc.selectedProvince!.name!,
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
                                      districtsBloc.selectedDistrict!.name!,
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
                                    style: AppStyle.heading2
                                        .copyWith(fontSize: 16),
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
                                  communesBloc.add(SearchCommunes(value));
                                },
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
                    districtsBloc.selectedDistrict = null;
                    communesBloc.selectedCommune = null;
                    //

                    provincesBloc.selectProvince(provinces[index]);
                    // Fetch districts
                    Province? province = provincesBloc.selectedProvince;
                    districtsBloc.add(FetchDistricts(province!.id!));
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
                    districtsBloc.selectDistrict(districts[index]);
                    // Fetch commune
                    District? district = districtsBloc.selectedDistrict;
                    communesBloc.add(FetchCommunes(district!.id!));
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
                    communesBloc.selectCommune(communes[index]);
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

}

enum AddressType { province, district, commune }
