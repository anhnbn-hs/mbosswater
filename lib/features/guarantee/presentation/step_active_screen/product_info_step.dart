// Step 1: Product Information
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
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
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

  void performAction() {
    widget.onNextStep();
  }

  @override
  void initState() {
    super.initState();
    productBloc = BlocProvider.of<ProductBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    agencyBloc = BlocProvider.of<AgencyBloc>(context);
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
            buildBoxItem(
              label: "Tên sản phẩm",
              fieldValue: "Máy Lọc Nước Tạo Kiềm MBossWater",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Model máy",
              fieldValue: widget.product?.model ?? "",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Seri màng lọc Dow",
              fieldValue: widget.product?.seriDow ?? "",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Ngày bắt đầu bảo hành",
              fieldValue: DateFormat("dd/MM/yyyy").format(now),
              icon: Icons.calendar_month,
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Thời gian bảo hành",
              fieldValue: widget.product?.guaranteeDuration ?? "Không xác định",
            ),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Ngày kết thúc bảo hành",
              fieldValue: endDateFormatted,
              icon: Icons.calendar_month,
            ),
            const SizedBox(height: 12),
            buildAgencyBox(),
            const SizedBox(height: 12),
            buildBoxItem(
              label: "Nhân viên bán hàng",
              fieldValue: userInfoBloc.user!.fullName!,
            ),
            const SizedBox(height: 40),
            CustomButton(
              height: 56,
              onTap: () {
                bool isAgency = Roles.LIST_ROLES_AGENCY.contains(userInfoBloc.user?.role);
                if(!isAgency && agencyBloc.selectedAgency == null){
                  DialogUtils.showWarningDialog(
                    context: context,
                    title: "Hãy chọn đại lý để tiếp tục!",
                    onClickOutSide: () {},
                  );
                  return;
                }
                widget.onNextStep();
              },
              textButton: "TIẾP TỤC",
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
          return buildBoxItem(
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
            height: 38,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: const Color(0xffF6F6F6),
              borderRadius: BorderRadius.circular(8),
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
                        style: AppStyle.boxField.copyWith(),
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

  Widget buildBoxItem({
    required String label,
    required String fieldValue,
    IconData? icon,
  }) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: AppStyle.boxFieldLabel,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 38,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xffF6F6F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  fieldValue,
                  style: AppStyle.boxField.copyWith(),
                  maxLines: 2,
                ),
              ),
              icon != null
                  ? Icon(
                      icon,
                      size: 20,
                      color: Colors.grey,
                    )
                  : const SizedBox.shrink()
            ],
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
                const SizedBox(height: 30),
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
}
