import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/step_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/step_request_screen/guarantee_after_step.dart';
import 'package:mbosswater/features/guarantee/presentation/step_request_screen/guarantee_before_step.dart';

class GuaranteeRequestPage extends StatefulWidget {
  const GuaranteeRequestPage({super.key});

  @override
  State<GuaranteeRequestPage> createState() => _GuaranteeRequestPageState();
}

class _GuaranteeRequestPageState extends State<GuaranteeRequestPage> {
  late StepBloc stepBloc;
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    stepBloc = BlocProvider.of<StepBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        backToPreviousPage();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: LeadingBackButton(
            onTap: backToPreviousPage,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const buildHeading(),
              const SizedBox(height: 24),
              buildStepper(),
              Expanded(
                child: PageView(
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index) => changeStep(index),
                  children: const [
                    GuaranteeBeforeStep(),
                    GuaranteeAfterStep(),
                  ],
                ),
              )
            ],
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
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: stepBloc.currentStep == stepIndex ? Colors.white : Colors.grey,
          height: -.2,
        ),
      );
    }
  }

  changeStep(int index) {
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
          "Các thông tin bạn đang điền sẽ mất đi\nBạn chắc chắn muốn quay lại trang chủ?",
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

class buildHeading extends StatelessWidget {
  const buildHeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Text(
        "Yêu Cầu Bảo Hành",
        style: TextStyle(
          color: Color(0xff820a1a),
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
      ),
    );
  }
}