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
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_state.dart';
import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource_impl.dart';
import 'package:mbosswater/features/guarantee/data/model/commune.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/customer_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/step_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/page/guarantee_activate_page.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class CustomerInfoStep extends StatefulWidget {
  final VoidCallback onPreStep;
  final Function(bool isDuplicatePhone) onNextStep;
  final GlobalKey<GuaranteeActivatePageState> guaranteeActiveKey;

  const CustomerInfoStep({
    super.key,
    required this.onPreStep,
    required this.onNextStep,
    required this.guaranteeActiveKey,
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

  final otpController = TextEditingController();

  final emailController = TextEditingController();

  var pageController = PageController();

  // Focus Node
  final focusNodePhone = FocusNode();
  final focusNodeOTP = FocusNode();
  final focusNodeFullName = FocusNode();
  final focusNodeAddress = FocusNode();

  // Step Bloc
  late StepBloc stepBloc;
  late CustomerBloc customerBloc;

  // Address BLOC
  late ProvincesBloc provincesBloc;
  late DistrictsBloc districtsBloc;
  late CommunesBloc communesBloc;

  // Fetch Customer BLOC
  late FetchCustomerBloc fetchCustomerBloc;

  late UserInfoBloc userInfoBloc;

  // OTP VERIFY
  ValueNotifier<bool> isOTPSent = ValueNotifier(false);
  ValueNotifier<bool> isOTPVerified = ValueNotifier(false);
  ValueNotifier<bool?> isOTPCorrected = ValueNotifier(null);

  // Type of customer creation
  ActionType actionType = ActionType.create;

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
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    fetchCustomerBloc = BlocProvider.of<FetchCustomerBloc>(context);
    // Fetch VN province list
    provincesBloc.add(FetchProvinces());
  }

  void forceRebuild() {
    provinceGlobalKey.currentState?.setState(() {});
    districtGlobalKey.currentState?.setState(() {});
    communeGlobalKey.currentState?.setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    focusNodePhone.dispose();
    focusNodeOTP.dispose();
    focusNodeFullName.dispose();
    focusNodeAddress.dispose();
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    pageController.dispose();
    addressController.dispose();
    emailController.dispose();
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
            child: BlocBuilder<FetchCustomerBloc, FetchCustomerState>(
              builder: (context, state) {
                Customer? customer;
                if (state is FetchCustomerSuccess) {
                  customer = state.customer;
                  customerBloc.emitCustomer(customer);

                  nameController.text = customer.fullName ?? "";
                  addressController.text = customer.address?.detail ?? "";

                  provincesBloc.selectProvince(
                      Province(name: customer.address?.province));

                  districtsBloc.emitDistrict(
                    District(
                      name: customer.address?.district,
                      id: '',
                      provinceId: '',
                      type: null,
                      typeText: '',
                    ),
                  );

                  communesBloc.emitCommune(
                    Commune(
                      name: customer.address?.commune,
                      id: '',
                      districtId: "",
                      type: null,
                      typeText: '',
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextFieldVerifyPhoneItem(
                      label: "Số điện thoại",
                      hint: "SĐT",
                      textButton: "GỬI MÃ",
                      isPhoneField: true,
                      onTap: () {
                        isOTPSent.value = true;
                      },
                      onTapOutSide: (phone) async =>
                          handleCheckPhoneNumber(phone),
                      onCompleted: (phone) async =>
                          handleCheckPhoneNumber(phone),
                      isRequired: true,
                      focusNode: focusNodePhone,
                      inputType: TextInputType.number,
                      controller: phoneController,
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder(
                      valueListenable: isOTPSent,
                      builder: (context, value, child) {
                        if (value == false) return const SizedBox.shrink();
                        return Text(
                          "Mã OTP đã được gửi đến số điện thoại",
                          style: AppStyle.boxFieldLabel.copyWith(
                            color: const Color((0xffD81E1E)),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    buildTextFieldVerifyPhoneItem(
                      label: "Nhập mã OTP",
                      hint: "",
                      textButton: "XÁC NHẬN",
                      isPhoneField: false,
                      onTap: () async => verifyOTP(),
                      onTapOutSide: (p0) {},
                      focusNode: focusNodeOTP,
                      onCompleted: (p0) {},
                      isRequired: true,
                      inputType: TextInputType.number,
                      controller: otpController,
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder(
                      valueListenable: isOTPCorrected,
                      builder: (context, value, child) {
                        if (value == true || value == null) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          "Nhập lại mã OTP",
                          style: AppStyle.boxFieldLabel.copyWith(
                            color: const Color((0xffD81E1E)),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    ValueListenableBuilder(
                      valueListenable: isOTPVerified,
                      builder: (context, value, child) {
                        if (value == false) return const SizedBox.shrink();
                        return Column(
                          children: [
                            buildTextFieldItem(
                              isEnable: customer == null,
                              label: "Họ và tên khách hàng",
                              hint: "Nhập họ tên khách hàng",
                              focusNode: focusNodeFullName,
                              controller: nameController,
                            ),
                            const SizedBox(height: 20),
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
                                  isEnable: customer == null,
                                  label: provincesBloc.selectedProvince?.name ??
                                      "Tỉnh/TP",
                                  addressType: AddressType.province,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder(
                              bloc: districtsBloc,
                              builder: (context, state) {
                                return buildAddressItem(
                                  isEnable: customer == null,
                                  label: districtsBloc.selectedDistrict?.name ??
                                      "Quận/Huyện",
                                  addressType: AddressType.district,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder(
                              bloc: communesBloc,
                              builder: (context, state) {
                                return buildAddressItem(
                                  isEnable: customer == null,
                                  label: communesBloc.selectedCommune?.name ??
                                      "Phường/Xã",
                                  addressType: AddressType.commune,
                                );
                              },
                            ),
                            buildTextFieldItem(
                              label: "",
                              hint: "Địa chỉ chi tiết",
                              isEnable: customer == null,
                              controller: addressController,
                              focusNode: focusNodeAddress,
                              isRequired: false,
                            ),
                            const SizedBox(height: 20),
                            buildTextFieldItem(
                              label: "Email",
                              hint: "Email",
                              isEnable: customer == null,
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
                          ],
                        );
                      },
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddressItem({
    required String label,
    required AddressType addressType,
    bool isEnable = true,
  }) {
    return GestureDetector(
      onTap: () {
        if (isEnable) {
          showBottomSheetChooseAddress(context, addressType);
        }
      },
      child: Container(
        height: 38,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: !isEnable ? Colors.grey.shade200 : null,
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

  Widget buildTextFieldVerifyPhoneItem({
    required String label,
    required String hint,
    required String textButton,
    required VoidCallback onTap,
    bool isRequired = true,
    required bool isPhoneField,
    FocusNode? focusNode,
    TextInputType inputType = TextInputType.text,
    required TextEditingController controller,
    required Function(String) onCompleted,
    required Function(String) onTapOutSide,
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
          padding: const EdgeInsets.only(left: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffBDBDBD),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  onEditingComplete: () => onCompleted(controller.text),
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    onTapOutSide(controller.text);
                  },
                  keyboardType: inputType,
                  focusNode: focusNode,
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
              if (isPhoneField)
                SizedBox(
                  width: 90,
                  child: CustomButton(
                    onTap: onTap,
                    textButton: textButton,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ValueListenableBuilder(
                valueListenable: isOTPSent,
                builder: (context, value, child) {
                  if (value == true && !isPhoneField) {
                    return SizedBox(
                      width: 90,
                      child: CustomButton(
                        onTap: onTap,
                        textButton: textButton,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextFieldItem({
    required String label,
    required String hint,
    bool isRequired = true,
    bool isEnable = true,
    FocusNode? focusNode,
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
            color: !isEnable ? Colors.grey.shade200 : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffBDBDBD),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            focusNode: focusNode,
            enabled: isEnable,
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

  handleAndGoToNextStep() async {
    if (phoneController.text.isEmpty) {
      widget.guaranteeActiveKey.currentState?.isCustomerStepCompleted = false;
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập số điện thoại khách hàng!",
        onClickOutSide: () {
          focusNodePhone.requestFocus();
        },
      );
      return;
    }
    if (otpController.text.isEmpty) {
      widget.guaranteeActiveKey.currentState?.isCustomerStepCompleted = false;
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập mã OTP!",
        onClickOutSide: () {
          focusNodeOTP.requestFocus();
        },
      );
      return;
    }
    if (checkInput()) {
      if (customerBloc.customer == null) {
        customerBloc.emitCustomer(Customer(
          id: generateRandomId(8),
          email: emailController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          fullName: nameController.text.trim(),
          agency: userInfoBloc.user?.agency ?? "",
          address: Address(
            province: provincesBloc.selectedProvince?.name,
            district: districtsBloc.selectedDistrict?.name,
            commune: communesBloc.selectedCommune?.name,
            detail: addressController.text.trim(),
          ),
        ));
      }
      widget.guaranteeActiveKey.currentState?.isCustomerStepCompleted = true;
      widget.guaranteeActiveKey.currentState?.pageController.jumpToPage(2);
    } else {
      widget.guaranteeActiveKey.currentState?.isCustomerStepCompleted = false;
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

  handleCheckPhoneNumber(String phone) async {
    // Reset
    fetchCustomerBloc.reset();
    resetController();

    DialogUtils.showLoadingDialog(context);
    final activeGuaranteeBloc = BlocProvider.of<ActiveGuaranteeBloc>(context);
    Customer? oldCustomer =
        await activeGuaranteeBloc.getCustumerExist(phoneController.text.trim());
    if (oldCustomer != null) {
      // Customer existed
      DialogUtils.showConfirmationDialog(
        context: context,
        onClickOutSide: () {
          FocusScope.of(context).unfocus();
          DialogUtils.hide(context);
        },
        title:
            "Thông tin khách hàng đã tồn tại.\nBạn có muốn tự động cập nhật thông tin?",
        textCancelButton: "CẬP NHẬT",
        textAcceptButton: "NHẬP SĐT MỚI",
        acceptPressed: () {
          actionType = ActionType.create;
          DialogUtils.hide(context);
          focusNodePhone.requestFocus();
        },
        cancelPressed: () {
          actionType = ActionType.update;
          // Fetch Customer Info
          fetchCustomerBloc.add(FetchCustomerByPhoneNumber(phone));
          DialogUtils.hide(context);
          return;
        },
      );
    } else {
      DialogUtils.hide(context);
      focusNodeOTP.requestFocus();
    }
  }

  void resetController() {
    nameController.text = "";
    addressController.text = "";
    emailController.text = "";
  }

  Future<void> verifyOTP() async {
    DialogUtils.showLoadingDialog(context);
    await Future.delayed(const Duration(milliseconds: 600));
    if (otpController.text.isEmpty) {
      widget.guaranteeActiveKey.currentState?.isCustomerStepCompleted = false;
      DialogUtils.showWarningDialog(
        context: context,
        title: "Chưa nhập mã OTP!",
        onClickOutSide: () {
          focusNodeOTP.requestFocus();
        },
      );
      DialogUtils.hide(context);
      DialogUtils.hide(context);
      return;
    }
    // Verify
    if (otpController.text == "1234") {
      isOTPVerified.value = true;
      isOTPCorrected.value = true;
    } else {
      isOTPVerified.value = false;
      isOTPCorrected.value = false;
    }
    DialogUtils.hide(context);
  }
}

enum AddressType { province, district, commune }
