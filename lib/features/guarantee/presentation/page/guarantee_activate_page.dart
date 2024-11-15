import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_event.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/additional_info_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/customer_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/product_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/step_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/step_screen/additional_info_step.dart';
import 'package:mbosswater/features/guarantee/presentation/step_screen/customer_info_step.dart';
import 'package:mbosswater/features/guarantee/presentation/step_screen/product_info_step.dart';

class GuaranteeActivatePage extends StatefulWidget {
  final Product? product;

  const GuaranteeActivatePage({
    super.key,
    required this.product,
  });

  @override
  State<GuaranteeActivatePage> createState() => _GuaranteeActivatePageState();
}

class _GuaranteeActivatePageState extends State<GuaranteeActivatePage> {
  late StepBloc stepBloc;
  late ProductBloc productBloc;
  late CustomerBloc customerBloc;
  late AdditionalInfoBloc additionalInfoBloc;
  late ActiveGuaranteeBloc activeGuaranteeBloc;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    stepBloc = BlocProvider.of<StepBloc>(context);
    productBloc = BlocProvider.of<ProductBloc>(context);
    customerBloc = BlocProvider.of<CustomerBloc>(context);
    additionalInfoBloc = BlocProvider.of<AdditionalInfoBloc>(context);
    activeGuaranteeBloc = BlocProvider.of<ActiveGuaranteeBloc>(context);
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    stepBloc.reset();
    productBloc.reset();
    customerBloc.reset();
    additionalInfoBloc.reset();
    activeGuaranteeBloc.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const LeadingBackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Thông Tin Sản Phẩm",
            style: TextStyle(
              fontFamily: "BeVietnam",
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: Color(0xff201E1E),
            ),
          ),
          const SizedBox(height: 20),
          BlocBuilder<StepBloc, int>(
            bloc: stepBloc,
            builder: (context, state) {
              return EasyStepper(
                activeStep: state,
                enableStepTapping: false,
                lineStyle: const LineStyle(
                  lineType: LineType.normal,
                  defaultLineColor: Color(0xffD3DCE6),
                  lineThickness: 1.5,
                ),
                activeStepTextColor: Colors.black87,
                finishedStepTextColor: Colors.black87,
                internalPadding: 60,
                showLoadingAnimation: false,
                stepRadius: 8,
                showStepBorder: false,
                steps: [
                  buildEasyStep(title: "Sản phẩm", stepNumber: 1),
                  buildEasyStep(title: "Khách hàng", stepNumber: 2),
                  buildEasyStep(title: "Thông tin thêm", stepNumber: 3),
                ],
                onStepReached: (index) {
                  stepBloc.changeStep(index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              );
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => stepBloc.changeStep(index),
              children: [
                ProductInfoStep(
                  product: widget.product,
                  onNextStep: () {
                    if (widget.product != null) {
                      productBloc.emitProduct(widget.product!);
                    }
                    stepBloc.goToNextStep();
                    _pageController.animateToPage(
                      stepBloc.currentStep,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                CustomerInfoStep(
                  onPreStep: () {
                    stepBloc.goToPreviousStep();
                    _pageController.animateToPage(
                      stepBloc.currentStep,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  onNextStep: () {
                    stepBloc.goToNextStep();
                    _pageController.animateToPage(
                      stepBloc.currentStep,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                AdditionalInfoStep(
                  onPreStep: () {
                    stepBloc.goToPreviousStep();
                    _pageController.animateToPage(
                      stepBloc.currentStep,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  onNextStep: handleConfirmAndActiveGuarantee,
                ),
              ],
            ),
          ),
        ],
      ),
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
          child: _buildStepContent(stepNumber - 1),
        ),
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
      if ((stepIndex == 0 && productBloc.product == null) ||
          (stepIndex == 1 && customerBloc.customer == null)) {
        return const Icon(
          Icons.sync_disabled,
          size: 12,
          color: Colors.white,
        );
      }
      return const Icon(
        Icons.check,
        size: 12,
        color: Colors.white,
      );
    } else {
      return Text(
        (stepIndex + 1).toString(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: stepBloc.currentStep == stepIndex ? Colors.white : Colors.grey,
          height: -.2,
        ),
      );
    }
  }

  void handleConfirmAndActiveGuarantee() {
    Product? product = productBloc.product;
    Customer? customer = customerBloc.customer;
    AdditionalInfo? additionalInfo = additionalInfoBloc.additionalInfo;

    if (product != null && customer != null && additionalInfo != null) {
      // Save additional info to customer
      customer.additionalInfo = additionalInfo;

      DialogUtils.showConfirmationDialog(
        context: context,
        size: MediaQuery.of(context).size,
        title: "",
        labelTitle: "Bạn chắc chắn xác nhận thông tin trên ?",
        textCancelButton: "Hủy",
        textAcceptButton: "Xác nhận",
        acceptPressed: () {
          // handle active

          final guarantee = Guarantee(
            id: generateRandomId(6),
            createdAt: Timestamp.now(),
            product: product,
            customerID: customer.id!,
            endDate: DateTime.now().toUtc().add(
                  const Duration(days: 365),
                ),
          );

          activeGuaranteeBloc.add(ActiveGuarantee(guarantee, customer));
          // activated
          context.go("/active-success");
        },
      );
    } else {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Chưa hoàn tất các bước!",
        onClickOutSide: () {},
      );
    }
  }
}
