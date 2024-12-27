// Step 1: Product Information
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/box_label_item.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/text_field_label_item.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/staffs/fetch_staffs_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/product_bloc.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class ProductInfoStep extends StatefulWidget {
  final Product? product;
  final VoidCallback onNextStep;

  const ProductInfoStep({
    super.key,
    this.product,
    required this.onNextStep,
  });

  @override
  State<ProductInfoStep> createState() => ProductInfoStepState();
}

class ProductInfoStepState extends State<ProductInfoStep>
    with AutomaticKeepAliveClientMixin {
  late ProductBloc productBloc;
  late UserInfoBloc userInfoBloc;
  late AgencyBloc agencyBloc;
  late FetchStaffsCubit fetchStaffsCubit;

  late TextEditingController modelController;
  final TextEditingController noteController = TextEditingController();

  final FocusNode modelFocusNode = FocusNode();

  void performAction() {
    widget.onNextStep();
  }

  @override
  void initState() {
    super.initState();
    productBloc = BlocProvider.of<ProductBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    agencyBloc = BlocProvider.of<AgencyBloc>(context);
    fetchStaffsCubit = BlocProvider.of<FetchStaffsCubit>(context);

    if (userInfoBloc.user?.role == Roles.MBOSS_ADMIN) {
      fetchStaffsCubit.fetchAllStaffsForMBoss();
    } else {
      fetchStaffsCubit.fetchAllStaffsForAnyone();
    }

    modelController = TextEditingController(text: widget.product?.model);
  }

  @override
  void dispose() {
    super.dispose();
    agencyBloc.selectedAgency = null;
    fetchStaffsCubit.selectedUser = null;
    modelFocusNode.dispose();
    modelController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    int? guaranteeDuration = widget.product?.duration;
    DateTime endDate = calculateEndDateFromDuration(guaranteeDuration ?? 12);
    String endDateFormatted = DateFormat("dd/MM/yyyy").format(endDate);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoxLabelItem(
              label: "Tên sản phẩm",
              fieldValue:
                  widget.product?.name ?? "Máy Lọc Nước Tạo Kiềm MBossWater",
            ),
            const SizedBox(height: 16),
            TextFieldLabelItem(
              isRequired: true,
              label: "Model máy",
              hint: "Model máy",
              controller: modelController,
              focusNode: modelFocusNode,
            ),
            // userInfoBloc.user?.role == Roles.MBOSS_ADMIN
            //     ? TextFieldLabelItem(
            //         isRequired: false,
            //         label: "Model máy",
            //         hint: "Model máy",
            //         controller: modelController,
            //         focusNode: modelFocusNode,
            //       )
            //     : BoxLabelItem(
            //         label: "Model máy",
            //         fieldValue: widget.product?.model ?? "",
            //       ),
            const SizedBox(height: 16),
            BoxLabelItem(
              label: "Ngày bắt đầu bảo hành",
              fieldValue: DateFormat("dd/MM/yyyy").format(now),
              icon: Icons.calendar_month,
            ),
            const SizedBox(height: 16),
            BoxLabelItem(
              label: "Thời gian bảo hành",
              fieldValue: "${widget.product?.duration} tháng",
            ),
            const SizedBox(height: 16),
            BoxLabelItem(
              label: "Ngày kết thúc bảo hành",
              fieldValue: endDateFormatted,
              icon: Icons.calendar_month,
            ),
            const SizedBox(height: 16),
            buildAgencyBox(),
            const SizedBox(height: 16),
            BoxLabelItem(
              label: "Nhân viên kỹ thuật",
              fieldValue: userInfoBloc.user!.fullName!,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                "Nhân viên hỗ trợ",
                style: AppStyle.boxFieldLabel,
              ),
            ),
            const SizedBox(height: 10),
            buildBoxStaffSelection(),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                "Ghi chú",
                style: AppStyle.boxFieldLabel,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xffD9D9D9),
                ),
              ),
              child: TextField(
                controller: noteController,
                maxLines: null,
                minLines: 5,
                keyboardType: TextInputType.multiline,
                onTapOutside: (event) =>
                    FocusScope.of(context).requestFocus(FocusNode()),
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                cursorHeight: 20,
                cursorColor: Colors.grey,
                style: AppStyle.boxField.copyWith(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              onTap: () {
                if (checkModelTextEditingController()) {
                  if (checkAgencySelected()) {
                    widget.onNextStep();
                  }
                }
              },
              textButton: "TIẾP TỤC",
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget buildBoxStaffSelection() {
    return GestureDetector(
      onTap: () async => await showBottomSheetChooseSupportTechnical(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              child: BlocBuilder(
                bloc: fetchStaffsCubit,
                builder: (context, state) {
                  return Text(
                    fetchStaffsCubit.selectedUser?.fullName ?? "Chọn nhân viên",
                    style: AppStyle.boxField.copyWith(color: Colors.black87),
                    maxLines: 2,
                  );
                },
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  bool checkAgencySelected() {
    bool isAgency = Roles.LIST_ROLES_AGENCY.contains(userInfoBloc.user?.role);
    if (!isAgency && agencyBloc.selectedAgency == null) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy chọn đại lý để tiếp tục!",
        onClickOutSide: () {},
      );
      return false;
    }
    return true;
  }

  bool checkModelTextEditingController() {
    if (modelController.text.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập model sản phẩm để tiếp tục!",
        onClickOutSide: () {},
      );
      modelFocusNode.requestFocus();
      return false;
    }
    return true;
  }

  Widget buildAgencyBox() {
    if (Roles.LIST_ROLES_AGENCY.contains(userInfoBloc.user?.role)) {
      return BlocBuilder(
        bloc: agencyBloc,
        builder: (context, state) {
          String agency = "Đại lý";
          if (state is AgencyLoaded) {
            agency = state.agency.name;
          }
          return BoxLabelItem(
            label: "Đại lý",
            fieldValue: agency,
          );
        },
      );
    }
    agencyBloc.fetchAgencies();
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Đại lý",
            style: AppStyle.boxFieldLabel,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            await showBottomSheetChooseAgency();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  child: BlocBuilder(
                    bloc: agencyBloc,
                    builder: (context, state) {
                      return Text(
                        agencyBloc.selectedAgency?.name ?? "Chọn đại lý",
                        style:
                            AppStyle.boxField.copyWith(color: Colors.black87),
                        maxLines: 2,
                      );
                    },
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  showBottomSheetChooseAgency() async {
    final size = MediaQuery.of(context).size;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: size.height * 0.6,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Chọn đại lý",
                  style: AppStyle.heading2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xffEEEEEE),
                  ),
                  child: Center(
                    child: TextField(
                      style: AppStyle.boxField.copyWith(fontSize: 15),
                      onChanged: (value) {
                        agencyBloc.searchAgency(value);
                      },
                      textAlignVertical: TextAlignVertical.center,
                      onTapOutside: (event) =>
                          FocusScope.of(context).requestFocus(FocusNode()),
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm đại lý",
                        hintStyle: AppStyle.boxField.copyWith(fontSize: 15),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey,
                        ),
                        isCollapsed: true,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder(
                    bloc: agencyBloc,
                    builder: (context, state) {
                      if (state is AgencyLoading) {
                        return Center(
                          child: Lottie.asset(AppAssets.aLoading, height: 50),
                        );
                      }
                      if (state is AgenciesLoaded) {
                        final agencies = state.agencies;
                        return ListView.builder(
                          itemCount: agencies.length,
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
                                  agencyBloc.selectAgency(agencies[index]);
                                  context.pop();
                                },
                                leading: null,
                                minTileHeight: 48,
                                titleAlignment: ListTileTitleAlignment.center,
                                contentPadding: const EdgeInsets.all(0),
                                title: Text(
                                  agencies[index].name,
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showBottomSheetChooseSupportTechnical() async {
    final size = MediaQuery.of(context).size;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: size.height * 0.6,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Chọn nhân viên hỗ trợ",
                  style: AppStyle.heading2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xffEEEEEE),
                  ),
                  child: Center(
                    child: TextField(
                      style: AppStyle.boxField.copyWith(fontSize: 15),
                      onChanged: (value) {
                        fetchStaffsCubit.searchUser(value);
                      },
                      textAlignVertical: TextAlignVertical.center,
                      onTapOutside: (event) =>
                          FocusScope.of(context).requestFocus(FocusNode()),
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm nhân viên",
                        hintStyle: AppStyle.boxField.copyWith(fontSize: 15),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey,
                        ),
                        isCollapsed: true,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder(
                    bloc: fetchStaffsCubit,
                    builder: (context, state) {
                      if (state is FetchStaffsLoading) {
                        return Center(
                          child: Lottie.asset(AppAssets.aLoading, height: 50),
                        );
                      }
                      if (state is FetchStaffsSuccess) {
                        final users = state.users;
                        users.removeWhere(
                          (user) => user.id == userInfoBloc.user?.id,
                        );
                        return ListView.builder(
                          itemCount: users.length,
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
                                  fetchStaffsCubit.selectUser(users[index]);
                                  context.pop();
                                },
                                leading: null,
                                minTileHeight: 48,
                                titleAlignment: ListTileTitleAlignment.center,
                                contentPadding: const EdgeInsets.all(0),
                                title: Text(
                                  "${users[index].fullName} (${users[index].phoneNumber})",
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
