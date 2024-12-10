import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee_history.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_event.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/guarantee_history_state.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/step_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/step_request_screen/guarantee_after_step.dart';
import 'package:mbosswater/features/guarantee/presentation/step_request_screen/guarantee_before_step.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class GuaranteeRequestPage extends StatefulWidget {
  final Product product;

  const GuaranteeRequestPage({super.key, required this.product});

  @override
  State<GuaranteeRequestPage> createState() => _GuaranteeRequestPageState();
}

class _GuaranteeRequestPageState extends State<GuaranteeRequestPage> {
  late StepBloc stepBloc;
  late UserInfoBloc userInfoBloc;
  late GuaranteeHistoryBloc guaranteeHistoryBloc;
  final PageController pageController = PageController();
  final reasonController = TextEditingController();
  final stateAfterController = TextEditingController();

  // Keys
  final beforeStepKey = GlobalKey<GuaranteeBeforeStepState>();

  @override
  void initState() {
    super.initState();
    stepBloc = BlocProvider.of<StepBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    guaranteeHistoryBloc = BlocProvider.of<GuaranteeHistoryBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    stepBloc.reset();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        backToPreviousPage();
        return true;
      },
      child: BlocListener<GuaranteeHistoryBloc, GuaranteeHistoryState>(
        listener: (context, state) async {
          if (state is CreateGuaranteeHistorySuccess) {
            await Future.delayed(const Duration(milliseconds: 800));
            context.go("/home");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(
                "Đã lưu lại lịch sử bảo hành thành công",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "BeVietnam",
                ),
              ),
              backgroundColor: AppColors.primaryColor,
            ));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: LeadingBackButton(
              onTap: backToPreviousPage,
            ),
            title:  Text(
              "Yêu Cầu Bảo Hành",
              style: AppStyle.appBarTitle.copyWith(color: AppColors.appBarTitleColor),
            ),
            centerTitle: true,
            scrolledUnderElevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                buildStepper(),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) => changeStep(index),
                    children: [
                      GuaranteeBeforeStep(
                        key: beforeStepKey,
                        reasonController: reasonController,
                        product: widget.product,
                        onNextStep: () {
                          changeStep(2);
                        },
                      ),
                      GuaranteeAfterStep(
                        stateAfterController: stateAfterController,
                        onConfirm: () {
                          DialogUtils.showConfirmationDialog(
                            context: context,
                            title: "",
                            labelTitle:
                                "Bạn chắc chắn xác nhận\nthông tin trên ?",
                            textCancelButton: "Huỷ",
                            textAcceptButton: "Xác nhận",
                            cancelPressed: () => Navigator.pop(context),
                            acceptPressed: () async {
                              DialogUtils.hide(context);
                              DialogUtils.showLoadingDialog(context);
                              // Get customer
                              final customer =
                                  beforeStepKey.currentState?.customer;

                              // Save History Guarantees
                              final gDocs = await FirebaseFirestore.instance
                                  .collection("guarantees")
                                  .where("customerID",
                                      isEqualTo: customer?.id ?? "")
                                  .limit(1)
                                  .get();

                              final gHistory = GuaranteeHistory(
                                guaranteeID: gDocs.docs.first.id,
                                afterStatus: stateAfterController.text.trim(),
                                beforeStatus: reasonController.text.trim(),
                                technicalID: userInfoBloc.user?.id ?? "",
                                technicalName:
                                    userInfoBloc.user?.fullName ?? "",
                                date: Timestamp.now(),
                              );

                              guaranteeHistoryBloc
                                  .add(CreateGuaranteeHistory(gHistory));
                            },
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  BlocBuilder<StepBloc, int> buildStepper() {
    return BlocBuilder<StepBloc, int>(
      bloc: stepBloc,
      builder: (context, state) {
        return EasyStepper(
          activeStep: state,
          enableStepTapping: true,
          lineStyle: const LineStyle(
            lineType: LineType.normal,
            defaultLineColor: Color(0xffD3DCE6),
            lineThickness: 1.5,
            lineLength: 60,
          ),
          activeStepTextColor: Colors.black87,
          finishedStepTextColor: Colors.black87,
          internalPadding: 100,
          showLoadingAnimation: false,
          stepRadius: 8,
          showStepBorder: false,
          steps: [
            buildEasyStep(title: "Trước khi bảo hành", stepNumber: 1),
            buildEasyStep(title: "Sau khi bảo hành", stepNumber: 2),
          ],
          onStepReached: (index) {
            changeStep(index);
          },
        );
      },
    );
  }

  EasyStep buildEasyStep({
    required int stepNumber,
    required String title,
  }) {
    return EasyStep(
      customStep: Container(
        height: 18,
        width: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getStepColor(stepNumber - 1),
          border: _shouldShowBorder(stepNumber - 1)
              ? Border.all(color: const Color(0xffD3DCE6))
              : null,
        ),
        child: Align(
            alignment: Alignment.center,
            child: _buildStepContent(stepNumber - 1)),
      ),
      title: title,
    );
  }

  Color _getStepColor(int stepIndex) {
    if (stepBloc.currentStep == stepIndex) {
      return AppColors.primaryColor;
    } else if (stepBloc.currentStep > stepIndex) {
      return AppColors.primaryColor;
    } else {
      return Colors.white;
    }
  }

  bool _shouldShowBorder(int stepIndex) {
    return stepBloc.currentStep != stepIndex &&
        stepBloc.currentStep <= stepIndex;
  }

  Widget _buildStepContent(int stepIndex) {
    if (stepBloc.currentStep > stepIndex) {
      return const Icon(
        Icons.check,
        size: 12,
        color: Colors.white,
      );
    } else {
      return Text(
        (stepIndex + 1).toString(),
        style: TextStyle(
          fontFamily: "BeVietnam",
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: stepBloc.currentStep == stepIndex ? Colors.white : Colors.grey,
          height: -.2,
        ),
      );
    }
  }

  changeStep(int index) {
    if (reasonController.text.trim().isEmpty && index == 1) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập nguyên nhân bảo hành tiếp tục!",
        onClickOutSide: () {},
      );
      stepBloc.changeStep(0);
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    stepBloc.changeStep(index);
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void backToPreviousPage() {
    DialogUtils.showConfirmationDialog(
      context: context,
      title:
          "Các thông tin bạn đang điền sẽ mất đi\nBạn chắc chắn muốn quay lại?",
      textCancelButton: "Hủy",
      textAcceptButton: "Xác nhận",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
    );
  }
}


