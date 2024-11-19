// Step 2: Customer Information
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BlocBuilder(
                      key: provinceGlobalKey,
                      bloc: provincesBloc,
                      builder: (context, state) {
                        // List in order to store address
                        List<String> provinces = ["Tỉnh/TP"];
                        if (state is ProvincesLoaded) {
                          state.provinces.forEach((e) {
                            provinces.add(e.name!);
                          });
                        }
                        return Container(
                          height: 38,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffBDBDBD)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<String>(
                            color: Colors.white,
                            style: ButtonStyle(
                              textStyle:
                                  WidgetStatePropertyAll(AppStyle.boxField),
                            ),
                            onSelected: (value) {
                              if (value != provincesBloc.selectedProvince) {
                                provincesBloc.selectedProvince = value;
                                // print(provincesBloc.getProvinceIDByName(value));
                                String provinceID =
                                    provincesBloc.getProvinceIDByName(
                                        provincesBloc.selectedProvince!)!;

                                districtsBloc.add(FetchDistricts(provinceID));
                                districtsBloc.selectedDistrict = null;
                                communesBloc.selectedCommune = null;
                              }

                              forceRebuild();
                            },
                            itemBuilder: (BuildContext context) {
                              // Hide the "Tỉnh/TP" option from being selected
                              return provinces.map((value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  height: 40,
                                  enabled: value != "Tỉnh/TP",
                                  // Disable the "Tỉnh/TP" option
                                  child: Text(
                                    value,
                                    style: AppStyle.boxField,
                                  ),
                                );
                              }).toList();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Text(
                                      provincesBloc.selectedProvince ??
                                          "Tỉnh/TP",
                                      maxLines: 1,
                                      // Show default text
                                      style: AppStyle.boxField,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: BlocBuilder(
                      key: districtGlobalKey,
                      bloc: districtsBloc,
                      builder: (context, state) {
                        // List in order to store address
                        List<String> districts = ["Quận/Huyện"];
                        if (state is DistrictsLoaded) {
                          state.districts.forEach((e) {
                            districts.add(e.name!);
                          });
                        }
                        return Container(
                          height: 38,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffBDBDBD)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<String>(
                            color: Colors.white,
                            style: ButtonStyle(
                              textStyle:
                                  WidgetStatePropertyAll(AppStyle.boxField),
                            ),
                            onSelected: (value) {
                              if (value != districtsBloc.selectedDistrict) {
                                districtsBloc.selectedDistrict = value;
                                String districtID =
                                    districtsBloc.getDistrictIDByName(
                                        districtsBloc.selectedDistrict!)!;

                                communesBloc.add(FetchCommunes(districtID));
                                // Set commune to default
                                communesBloc.selectedCommune = null;
                              }
                              forceRebuild();
                            },
                            itemBuilder: (BuildContext context) {
                              // Hide the "Tỉnh/TP" option from being selected
                              return districts.map((value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  height: 40,
                                  enabled: value != "Quận/Huyện",
                                  child: Text(
                                    value,
                                    style: AppStyle.boxField,
                                  ),
                                );
                              }).toList();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Text(
                                      districtsBloc.selectedDistrict ??
                                          "Quận/Huyện",
                                      maxLines: 1,
                                      style: AppStyle.boxField,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BlocBuilder(
                      key: communeGlobalKey,
                      bloc: communesBloc,
                      builder: (context, state) {
                        // List in order to store address
                        List<String> communes = ["Xã/Phường"];
                        if (state is CommunesLoaded) {
                          state.communes.forEach((e) {
                            communes.add(e.name!);
                          });
                        }
                        return Container(
                          height: 38,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffBDBDBD)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<String>(
                            color: Colors.white,
                            style: ButtonStyle(
                              textStyle:
                                  WidgetStatePropertyAll(AppStyle.boxField),
                            ),
                            onSelected: (value) {
                              communesBloc.selectedCommune = value;
                              forceRebuild();
                            },
                            itemBuilder: (BuildContext context) {
                              return communes.map((value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  height: 40,
                                  enabled: value != "Xã/Phường",
                                  child: Text(
                                    value,
                                    style: AppStyle.boxField,
                                  ),
                                );
                              }).toList();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Text(
                                      communesBloc.selectedCommune ??
                                          "Xã/Phường",
                                      maxLines: 1,
                                      // Show default text
                                      style: AppStyle.boxField,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xffBDBDBD),
                        ),
                      ),
                      child: TextField(
                        controller: addressController,
                        style: AppStyle.boxField.copyWith(),
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Địa chỉ chi tiết",
                          hintStyle: AppStyle.boxField,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        cursorColor: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 12),
              buildTextFieldItem(
                label: "Email",
                hint: "Email",
                controller: emailController,
                isRequired: false,
              ),
              const SizedBox(height: 50),
              const Spacer(),
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
          child: Row(
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
          ),
        ),
        const SizedBox(height: 10),
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
              hintStyle: AppStyle.boxField.copyWith(
                fontStyle: FontStyle.italic,
              ),
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
    String? province = provincesBloc.selectedProvince;
    String? district = districtsBloc.selectedDistrict;
    String? commune = communesBloc.selectedCommune;
    // Some fields

    // bool validate = formKey.currentState!.validate();
    if (name.isEmpty ||
        phone.isEmpty ||
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
            province: provincesBloc.selectedProvince,
            district: districtsBloc.selectedDistrict,
            commune: communesBloc.selectedCommune,
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
}
