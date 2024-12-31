import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/core/widgets/text_field_label_item.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/guarantee/data/model/commune.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/step_active_screen/customer_info_step.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/delete_agency_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_agencies_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_agency_admin_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/update_agency_bloc.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class MbossEditAgencyPage extends StatefulWidget {
  const MbossEditAgencyPage({super.key, required this.agency});

  final Agency agency;

  @override
  State<MbossEditAgencyPage> createState() => _MbossEditAgencyPageState();
}

class _MbossEditAgencyPageState extends State<MbossEditAgencyPage> {
  // Text editing controller
  late final TextEditingController agencyNameController;
  late final TextEditingController agencyAddressController;
  TextEditingController agencyBossNameController = TextEditingController();
  TextEditingController agencyBossPhoneController = TextEditingController();
  TextEditingController agencyBossAddressController = TextEditingController();
  TextEditingController agencyBossEmailController = TextEditingController();
  TextEditingController agencyBossCCCDController = TextEditingController();

  PageController pageController = PageController();

  // FocusNode
  final agencyNameFocusNode = FocusNode();
  final agencyAddressFocusNode = FocusNode();
  final agencyBossNameFocusNode = FocusNode();
  final agencyBossPhoneFocusNode = FocusNode();

  // Bloc
  late FetchAgenciesBloc fetchAgenciesBloc;
  late FetchAgencyAdminCubit fetchAgencyAdminCubit;
  late UpdateAgencyBloc updateAgencyBloc;
  late DeleteAgencyBloc deleteAgencyBloc;

  // Address BLOC
  late ProvincesAgencyBloc provincesAgencyBloc;
  late DistrictsAgencyBloc districtsAgencyBloc;
  late CommunesAgencyBloc communesAgencyBloc;

  late ProvincesBloc provincesUserBloc;
  late DistrictsBloc districtsUserBloc;
  late CommunesBloc communesUserBloc;

  // Variable store Agency and User (Agency Admin)
  late Agency agency;
  UserModel? agencyAdmin;

  ValueNotifier<bool> isDistrictsFetched = ValueNotifier(false);
  ValueNotifier<bool> isCommunesFetched = ValueNotifier(false);

  ValueNotifier<bool> isDistrictsUserFetched = ValueNotifier(false);
  ValueNotifier<bool> isCommunesUserFetched = ValueNotifier(false);

  bool isValueAssigned = false;
  @override
  void initState() {
    super.initState();
    agency = widget.agency;
    fetchAgencyAdminCubit = BlocProvider.of<FetchAgencyAdminCubit>(context);
    fetchAgencyAdminCubit.fetchAdminOfAgency(widget.agency.id);
    fetchAgenciesBloc = BlocProvider.of<FetchAgenciesBloc>(context);
    updateAgencyBloc = BlocProvider.of<UpdateAgencyBloc>(context);
    deleteAgencyBloc = BlocProvider.of<DeleteAgencyBloc>(context);

    provincesAgencyBloc = BlocProvider.of<ProvincesAgencyBloc>(context);
    districtsAgencyBloc = BlocProvider.of<DistrictsAgencyBloc>(context);
    communesAgencyBloc = BlocProvider.of<CommunesAgencyBloc>(context);

    provincesUserBloc = BlocProvider.of<ProvincesBloc>(context);
    districtsUserBloc = BlocProvider.of<DistrictsBloc>(context);
    communesUserBloc = BlocProvider.of<CommunesBloc>(context);
    if (provincesAgencyBloc.state is! ProvincesLoaded) {
      provincesAgencyBloc.add(FetchProvinces());
    }
    if (provincesUserBloc.state is! ProvincesLoaded) {
      provincesUserBloc.add(FetchProvinces());
    }

    // Init data
    agencyNameController = TextEditingController(text: widget.agency.name);
    agencyAddressController =
        TextEditingController(text: widget.agency.address?.detail);
  }

  @override
  void dispose() {
    super.dispose();
    agencyNameController.dispose();
    agencyAddressController.dispose();
    agencyBossNameController.dispose();
    agencyBossPhoneController.dispose();
    agencyBossEmailController.dispose();
    agencyBossCCCDController.dispose();
    agencyNameFocusNode.dispose();
    agencyAddressFocusNode.dispose();
    agencyBossNameFocusNode.dispose();
    agencyBossPhoneFocusNode.dispose();

    provincesAgencyBloc.selectedProvince = null;
    districtsAgencyBloc.selectedDistrict = null;
    communesAgencyBloc.selectedCommune = null;

    provincesUserBloc.selectedProvince = null;
    districtsUserBloc.selectedDistrict = null;
    communesUserBloc.selectedCommune = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: const LeadingBackButton(),
        centerTitle: true,
        title: Text(
          maxLines: 2,
          widget.agency.name,
          style: AppStyle.appBarTitle.copyWith(
            color: AppColors.appBarTitleColor,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Thông tin đại lý",
                    style: AppStyle.titleItem.copyWith(
                      color: const Color(0xff820a1a),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFieldLabelItem(
                  label: "Mã đại lý",
                  hint: "Mã đại lý",
                  isRequired: false,
                  isEnable: false,
                  controller: TextEditingController(text: agency.code),
                ),
                const SizedBox(height: 12),
                TextFieldLabelItem(
                  label: "Tên đại lý",
                  hint: "Tên đại lý",
                  isRequired: true,
                  controller: agencyNameController,
                  focusNode: agencyNameFocusNode,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    children: [
                      Text(
                        "Địa chỉ",
                        style: AppStyle.boxFieldLabel.copyWith(fontSize: 15),
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
                  bloc: provincesAgencyBloc,
                  builder: (context, state) {
                    if (provincesAgencyBloc.selectedProvince == null) {
                      provincesAgencyBloc.selectProvince(
                        provincesAgencyBloc.getProvinceByName(
                                widget.agency.address!.province!) ??
                            Province(),
                      );
                      districtsAgencyBloc.add(FetchDistricts(
                          provincesAgencyBloc.selectedProvince?.id ?? ""));
                    }
                    return buildAddressItem(
                      label: provincesAgencyBloc.selectedProvince?.name ??
                          "Tỉnh/TP",
                      addressType: AddressType.province,
                    );
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder(
                  valueListenable: isDistrictsFetched,
                  builder: (context, value, child) {
                    return BlocConsumer(
                      bloc: districtsAgencyBloc,
                      listener: (context, state) {
                        if (state is DistrictsLoaded) {
                          isDistrictsFetched.value = true;
                          if (districtsAgencyBloc.selectedDistrict == null) {
                            districtsAgencyBloc.selectDistrict(
                              districtsAgencyBloc.getDistrictByName(
                                      widget.agency.address!.district!) ??
                                  District(),
                            );
                            communesAgencyBloc.add(FetchCommunes(
                                districtsAgencyBloc.selectedDistrict?.id ??
                                    ""));
                          }
                        }
                      },
                      builder: (context, state) {
                        return buildAddressItem(
                          label: districtsAgencyBloc.selectedDistrict?.name ??
                              "Quận/Huyện",
                          addressType: AddressType.district,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder(
                  valueListenable: isDistrictsFetched,
                  builder: (context, value, child) {
                    return BlocConsumer(
                      bloc: communesAgencyBloc,
                      listener: (context, state) {
                        if (state is CommunesLoaded) {
                          if (communesAgencyBloc.selectedCommune == null) {
                            communesAgencyBloc.selectCommune(
                              communesAgencyBloc.getCommuneByName(
                                      widget.agency.address!.commune!) ??
                                  Commune(),
                            );
                          }
                        }
                      },
                      builder: (context, state) {
                        return buildAddressItem(
                          label: communesAgencyBloc.selectedCommune?.name ??
                              "Phường/Xã",
                          addressType: AddressType.commune,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFieldLabelItem(
                  label: "Địa chỉ chi tiết",
                  hint: "Địa chỉ chi tiết",
                  controller: agencyAddressController,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Thông tin chủ đại lý",
                    style: AppStyle.titleItem.copyWith(
                      color: const Color(0xff820a1a),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<FetchAgencyAdminCubit, UserModel?>(
                  bloc: fetchAgencyAdminCubit,
                  builder: (context, state) {
                    if (fetchAgencyAdminCubit.isLoading) {
                      return Center(
                        child: Lottie.asset(AppAssets.aLoading, height: 50),
                      );
                    }
                    if (state != null) {
                        agencyAdmin = state;
                        agencyBossNameController.text =
                            agencyAdmin?.fullName ?? "";
                        agencyBossPhoneController.text =
                            agencyAdmin?.phoneNumber ?? "";
                        agencyBossEmailController.text = agencyAdmin?.email ?? "";
                        agencyBossAddressController.text =
                            agencyAdmin?.address?.detail ?? "";
                        agencyBossCCCDController.text =
                            agencyAdmin?.cccd ?? "";
                        isValueAssigned = true;

                      return Column(
                        children: [
                          TextFieldLabelItem(
                            label: "Họ và tên",
                            hint: "Họ và tên",
                            isRequired: true,
                            controller: agencyBossNameController,
                            focusNode: agencyBossNameFocusNode,
                            formatter: [
                              FilteringTextInputFormatter.deny(RegExp(r'\d'))
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFieldLabelItem(
                            label: "Số điện thoại",
                            hint: "Số điện thoại",
                            isRequired: true,
                            controller: agencyBossPhoneController,
                            focusNode: agencyBossPhoneFocusNode,
                            formatter: [FilteringTextInputFormatter.digitsOnly],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Row(
                              children: [
                                Text(
                                  "Địa chỉ",
                                  style: AppStyle.boxFieldLabel
                                      .copyWith(fontSize: 15),
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
                              bloc: provincesUserBloc,
                              builder: (context, state) {
                                if (provincesUserBloc.selectedProvince ==
                                    null) {
                                  provincesUserBloc.selectProvince(
                                    provincesUserBloc.getProvinceByName(
                                            agencyAdmin?.address?.province ??
                                                "") ??
                                        Province(),
                                  );
                                  districtsUserBloc.add(FetchDistricts(
                                      provincesUserBloc.selectedProvince?.id ??
                                          ""));
                                }
                                return buildAddressItem(
                                  isAgency: false,
                                  label: provincesUserBloc
                                          .selectedProvince?.name ??
                                      "",
                                  addressType: AddressType.province,
                                );
                              }),
                          const SizedBox(height: 12),
                          ValueListenableBuilder(
                            valueListenable: isDistrictsUserFetched,
                            builder: (context, value, child) {
                              return BlocConsumer(
                                bloc: districtsUserBloc,
                                listener: (context, state) {
                                  if (state is DistrictsLoaded) {
                                    isDistrictsUserFetched.value = true;
                                    if (districtsUserBloc.selectedDistrict ==
                                        null) {
                                      districtsUserBloc.selectDistrict(
                                        districtsUserBloc.getDistrictByName(
                                                agencyAdmin
                                                        ?.address?.district ??
                                                    "") ??
                                            District(),
                                      );
                                      communesUserBloc.add(FetchCommunes(
                                          districtsUserBloc
                                                  .selectedDistrict?.id ??
                                              ""));
                                    }
                                  }
                                },
                                builder: (context, state) => buildAddressItem(
                                  isAgency: false,
                                  label: districtsUserBloc
                                          .selectedDistrict?.name ??
                                      "Quận/Huyện",
                                  addressType: AddressType.district,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder(
                            valueListenable: isDistrictsUserFetched,
                            builder: (context, value, child) {
                              return BlocConsumer(
                                bloc: communesUserBloc,
                                listener: (context, state) {
                                  if (state is CommunesLoaded) {
                                    if (communesUserBloc.selectedCommune ==
                                        null) {
                                      communesUserBloc.selectCommune(
                                        communesUserBloc.getCommuneByName(
                                                agencyAdmin?.address?.commune ??
                                                    "") ??
                                            Commune(),
                                      );
                                    }
                                  }
                                },
                                builder: (context, state) => buildAddressItem(
                                  isAgency: false,
                                  label: communesUserBloc
                                          .selectedCommune?.name ??
                                      "Phường/Xã",
                                  addressType: AddressType.commune,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFieldLabelItem(
                            label: "Địa chỉ chi tiết",
                            hint: "Địa chỉ chi tiết",
                            controller: agencyBossAddressController,
                          ),
                          const SizedBox(height: 20),
                          TextFieldLabelItem(
                            label: "Căn cước công dân",
                            hint: "Số CMT/CCCD",
                            isRequired: false,
                            controller: agencyBossCCCDController,
                          ),
                          const SizedBox(height: 20),
                          TextFieldLabelItem(
                            label: "Email",
                            hint: "Email",
                            isRequired: false,
                            controller: agencyBossEmailController,
                          ),
                        ],
                      );
                    } else {
                      return const Text("Không có chủ đại lý cho đại lý này.");
                    }
                  },
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: handleDeleteStaff,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: const Color(0xffC2C2C2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              "XÓA",
                              style: TextStyle(
                                fontFamily: "BeVietnam",
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    Expanded(
                      child: InkWell(
                        onTap: () async => handleUpdateAgency(),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              "CẬP NHẬT",
                              style: TextStyle(
                                fontFamily: "BeVietnam",
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                height: 1,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 30),
                BlocListener<UpdateAgencyBloc, bool>(
                  listener: (context, state) async {
                    if (updateAgencyBloc.isLoading == false && state == true) {
                      DialogUtils.hide(context);
                      fetchAgenciesBloc.fetchAllAgencies();
                    }
                  },
                  child: const SizedBox.shrink(),
                ),
                BlocListener<DeleteAgencyBloc, bool>(
                  listener: (context, state) async {
                    if (deleteAgencyBloc.isLoading == false && state == true) {
                      DialogUtils.hide(context);
                      DialogUtils.hide(context);
                      await fetchAgenciesBloc.fetchAllAgencies();
                    }
                  },
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddressItem({
    required String label,
    required AddressType addressType,
    bool isAgency = true,
    bool isEnable = true,
  }) {
    return GestureDetector(
      onTap: () {
        if (isEnable && isAgency) {
          showBottomSheetChooseAddressAgency(
            context: context,
            addressType: addressType,
            pageController: pageController,
            provincesAgencyBloc: provincesAgencyBloc,
            districtsAgencyBloc: districtsAgencyBloc,
            communesAgencyBloc: communesAgencyBloc,
          );
        } else {
          showBottomSheetChooseAddress(
            context: context,
            addressType: addressType,
            pageController: pageController,
            provincesBloc: provincesUserBloc,
            districtsBloc: districtsUserBloc,
            communesBloc: communesUserBloc,
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
                    fontSize: 15,
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

  handleUpdateAgency() async {
    String agencyName = agencyNameController.text.trim();
    String agencyAddress = agencyAddressController.text.trim();

    String bossName = agencyBossNameController.text.trim();
    String bossPhone = agencyBossPhoneController.text.trim();
    String bossEmail = agencyBossEmailController.text.trim();
    String bossCCCD = agencyBossCCCDController.text.trim();
    String bossAddress = agencyBossAddressController.text.trim();

    if (agencyName.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập tên đại lý",
        onClickOutSide: () {},
      );
      agencyNameFocusNode.requestFocus();
      return;
    }

    if (agencyAddress.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập đầy đủ địa chỉ đại lý",
        onClickOutSide: () {},
      );
      agencyAddressFocusNode.requestFocus();
      return;
    }

    if (bossName.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập họ tên chủ đại lý",
        onClickOutSide: () {},
      );
      agencyBossNameFocusNode.requestFocus();
      return;
    }

    if (bossPhone.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập số điện thoại chủ đại lý",
        onClickOutSide: () {},
      );
      agencyBossPhoneFocusNode.requestFocus();
      return;
    }

    // Assign value
    agency.name = agencyName;
    agency.address = Address(
      detail: agencyAddress,
      commune: communesAgencyBloc.selectedCommune?.name ?? "",
      district: districtsAgencyBloc.selectedDistrict?.name ?? "",
      province: provincesAgencyBloc.selectedProvince?.name ?? "",
    );

    agencyAdmin?.fullName = bossName;
    agencyAdmin?.phoneNumber = bossPhone;
    agencyAdmin?.email = bossEmail;
    agencyAdmin?.cccd = bossCCCD;
    agencyAdmin?.address = Address(
      province: provincesUserBloc.selectedProvince?.name,
      district: districtsUserBloc.selectedDistrict?.name,
      commune: communesUserBloc.selectedCommune?.name,
      detail: bossAddress,
    );

    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xác nhận cập nhật thông tin đại lý này?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);

        // Check phoneNumber of agency boss
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .where("phoneNumber", isEqualTo: bossPhone)
            .where(FieldPath.documentId, isNotEqualTo: agencyAdmin?.id)
            .limit(1)
            .get();

        bool isPhoneExisted = userDoc.docs.isNotEmpty;

        if (!isPhoneExisted) {
          await updateAgencyBloc.updateAgency(
            agency: agency,
            user: agencyAdmin!,
          );
        } else {
          DialogUtils.hide(context);
          agencyBossPhoneFocusNode.requestFocus();
          DialogUtils.showWarningDialog(
            context: context,
            title: "Số điện thoại đã được đăng ký!",
            onClickOutSide: () {},
          );
        }
      },
    );
  }

  handleDeleteStaff() async {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Bạn chắc chắn muốn xoá đại lý này?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);
        await deleteAgencyBloc.deleteAgency(
          agency: agency,
          agencyAdmin: agencyAdmin!,
        );
      },
    );
  }
}

class BoxFieldItem extends StatefulWidget {
  final String hintValue;
  final bool isRequired;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final List<TextInputFormatter> formatter;

  const BoxFieldItem({
    Key? key,
    required this.hintValue,
    this.isRequired = false,
    required this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.formatter = const [],
  }) : super(key: key);

  @override
  _BoxFieldItemState createState() => _BoxFieldItemState();
}

class _BoxFieldItemState extends State<BoxFieldItem> {
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffD9D9D9)),
      ),
      child: Stack(
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.formatter,
            style: AppStyle.bodyText.copyWith(
              color: const Color(0xff303030),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            onTapOutside: (event) =>  FocusScope.of(context).requestFocus(FocusNode()),
            decoration: InputDecoration(
              border: const UnderlineInputBorder(borderSide: BorderSide.none),
              hintText: widget.isRequired ? "" : widget.hintValue,
              hintStyle: widget.isRequired
                  ? null
                  : AppStyle.bodyText.copyWith(
                      color: const Color(0xffB3B3B3),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          if (widget.isRequired && widget.controller.text.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: RichText(
                    text: TextSpan(
                      text: widget.hintValue,
                      style: AppStyle.bodyText.copyWith(
                        color: const Color(0xffB3B3B3),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      children: const [
                        TextSpan(
                          text: ' * ',
                          style: TextStyle(
                            fontFamily: "BeVietnam",
                            color: Color(0xff820a1a),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
