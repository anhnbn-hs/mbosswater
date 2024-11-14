import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/step_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/widgets/additional_info_step.dart';
import 'package:mbosswater/features/guarantee/presentation/widgets/customer_info_step.dart';
import 'package:mbosswater/features/guarantee/presentation/widgets/product_info_step.dart';

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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    stepBloc = BlocProvider.of<StepBloc>(context);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                enableStepTapping: true,
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
                  onNextStep: () {
                    DialogUtils.showConfirmationDialog(
                      context: context,
                      size: MediaQuery.of(context).size,
                      title: "",
                      labelTitle: "Bạn chắc chắn xác nhận thông tin trên ?",
                      textCancelButton: "Hủy",
                      textAcceptButton: "Xác nhận",
                      acceptPressed: () {},
                    );
                  },
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
      customStep: GestureDetector(
        onTap: () {
          stepBloc.changeStep(stepNumber - 1);
          _pageController.animateToPage(
            stepNumber - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
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
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: stepBloc.currentStep == stepIndex ? Colors.white : Colors.grey,
          height: -.2,
        ),
      );
    }
  }
}
