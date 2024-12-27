// Step 2: Customer Information
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/text_field_label_item.dart';
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
    customerBloc.reset();
    provincesBloc.selectedProvince = null;
    districtsBloc.selectedDistrict = null;
    communesBloc.selectedCommune = null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
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

                provincesBloc
                    .selectProvince(Province(name: customer.address?.province));

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
                    hint: "Số điện thoại",
                    textButton: "GỬI MÃ",
                    isPhoneField: true,
                    onTap: () {
                      /// Todo Send OTP SMS

                      // Assign flag
                      isOTPSent.value = true;
                    },
                    onTapOutSide: (phone) async =>
                        handleCheckPhoneNumber(phone),
                    onCompleted: (phone) async => handleCheckPhoneNumber(phone),
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
                  ValueListenableBuilder(
                    valueListenable: isOTPSent,
                    builder: (context, value, child) {
                      if (value == false) {
                        return const SizedBox.shrink();
                      }
                      return buildTextFieldVerifyPhoneItem(
                        label: "Nhập mã OTP",
                        hint: "Nhập mã OTP",
                        textButton: "XÁC NHẬN",
                        isPhoneField: false,
                        onTap: () async => verifyOTP(),
                        onTapOutSide: (p0) {},
                        focusNode: focusNodeOTP,
                        onCompleted: (p0) {},
                        isRequired: true,
                        inputType: TextInputType.number,
                        controller: otpController,
                      );
                    },
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

                  const SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: isOTPVerified,
                    builder: (context, value, child) {
                      if (value == false) return const SizedBox.shrink();
                      return Column(
                        children: [
                          TextFieldLabelItem(
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
                                  style: AppStyle.boxFieldLabel
                                      .copyWith(color: const Color(0xff8A0E1E)),
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
                          const SizedBox(height: 12),
                          TextFieldLabelItem(
                            label: "Địa chỉ chi tiết",
                            hint: "Địa chỉ chi tiết",
                            isEnable: customer == null,
                            controller: addressController,
                            focusNode: focusNodeAddress,
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                          TextFieldLabelItem(
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
                ],
              );
            },
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
          showBottomSheetChooseAddress(
            context: context,
            addressType: addressType,
            pageController: pageController,
            provincesBloc: provincesBloc,
            districtsBloc: districtsBloc,
            communesBloc: communesBloc,
          );
        }
      },
      child: Container(
        height: 40,
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
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: AppStyle.boxField.copyWith(
                    color:
                        ["Tỉnh/TP", "Quận/Huyện", "Phường/Xã"].contains(label)
                            ? const Color(0xff828282)
                            : Colors.black87,
                    fontSize:
                        ["Tỉnh/TP", "Quận/Huyện", "Phường/Xã"].contains(label)
                            ? 15
                            : 15,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    if (["Tỉnh/TP", "Quận/Huyện", "Phường/Xã"].contains(label))
                      const TextSpan(
                        text: " * ",
                        style: TextStyle(
                          color: Color(0xff8A0E1E),
                        ),
                      ),
                  ],
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
                              color: const Color(0xff8A0E1E),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        Container(
          height: 40,
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  focusNode: focusNode,
                  style: AppStyle.boxField.copyWith(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: hint,
                    hintStyle: AppStyle.boxField.copyWith(
                      color: const Color(0xff828282),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    isCollapsed: true,
                  ),
                  textAlignVertical: TextAlignVertical.center,
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
        final now = Timestamp.now();
        customerBloc.emitCustomer(
          Customer(
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
            createdAt: now,
            updatedAt: now,
          ),
        );
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
