import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource_impl.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_event.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_state.dart';
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
  // Keys
  final productStepKey = GlobalKey<ProductInfoStepState>();
  final customerStepKey = GlobalKey<CustomerInfoStepState>();
  final additionalStepKey = GlobalKey<AdditionalInfoStepState>();

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
    return WillPopScope(
      onWillPop: () async {
        backToPreviousPage();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: LeadingBackButton(
            onTap: () => backToPreviousPage(),
          ),
        ),
        body: BlocListener(
          bloc: activeGuaranteeBloc,
          listener: (context, state) {
            if (state is ActiveGuaranteeLoaded) {
              DialogUtils.hide(context);
              // Activated
              context.go("/active-success");
            }
            if (state is ActiveGuaranteeError) {
              DialogUtils.hide(context);
              DialogUtils.showWarningDialog(
                context: context,
                title: "Kích hoạt không thành công. Vui lòng thử lại!",
                onClickOutSide: () {},
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlocBuilder<StepBloc, int>(
                bloc: stepBloc,
                builder: (context, state) {
                  String title = "";
                  if (state == 0) {
                    title = "Thông Tin Sản Phẩm";
                  }
                  if (state == 1) {
                    title = "Thông Tin Khách Hàng";
                  }
                  if (state == 2) {
                    title = "Thông Tin Thêm";
                  }
                  return Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "BeVietnam",
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: Color(0xff201E1E),
                    ),
                  );
                },
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
                      changeStep(index);
                    },
                  );
                },
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index) => changeStep(index),
                  children: [
                    ProductInfoStep(
                      key: productStepKey,
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
                      key: customerStepKey,
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
                      key: additionalStepKey,
                      onPreStep: () {
                        stepBloc.goToPreviousStep();
                        _pageController.animateToPage(
                          stepBloc.currentStep,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      onNextStep: () async {
                        handleConfirmAndActiveGuarantee();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  void handleConfirmAndActiveGuarantee() async {
    Product? product = productBloc.product;
    Customer? customer = customerBloc.customer;
    AdditionalInfo? additionalInfo = additionalInfoBloc.additionalInfo;

    if (product != null && customer != null && additionalInfo != null) {
      // Save additional info to customer
      customer.additionalInfo = additionalInfo;
      DialogUtils.showConfirmationDialog(
        context: context,
        title: "",
        labelTitle: "Bạn chắc chắn xác nhận thông tin trên ?",
        textCancelButton: "Hủy",
        textAcceptButton: "Xác nhận",
        acceptPressed: () async {
          // Check customer exist
          DialogUtils.showLoadingDialog(context);
          Customer? oldCustomer = await activeGuaranteeBloc
              .getCustumerExist(customerBloc.customer!.phoneNumber!);
          print(oldCustomer);
          DialogUtils.hide(context);
          if (oldCustomer != null) {
            DialogUtils.showConfirmationDialog(
              context: context,
              title:
                  "Khách hàng đã tồn tại trong hệ thống. Bạn muốn lấy thông tin cũ hay cập nhật thông tin mới?",
              textCancelButton: "Giữ lại thông tin",
              textAcceptButton: "Cập nhật mới",
              acceptPressed: () {
                activeGuarantee(product, customer, ActionType.update);
              },
              cancelPressed: () {
                activeGuarantee(product, oldCustomer, ActionType.update);
              },
            );
          } else {
            activeGuarantee(product, customer, ActionType.create);
          }
        },
        cancelPressed: () => Navigator.pop(context),
      );
    } else {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Chưa hoàn tất các bước!",
        onClickOutSide: () {},
      );
    }
  }

  void activeGuarantee(
      Product product, Customer customer, ActionType actionType) {
    DialogUtils.showLoadingDialog(context);
    // handle active
    final guarantee = Guarantee(
      id: generateRandomId(6),
      createdAt: Timestamp.now(),
      product: product,
      customerID: customer.id!,
      endDate: DateTime.now().toUtc().add(
            const Duration(
              days: 365,
              hours: 7,
            ),
          ),
    );
    if (actionType == ActionType.create) {
      activeGuaranteeBloc
          .add(ActiveGuarantee(guarantee, customer, ActionType.create));
    } else if (actionType == ActionType.update) {
      activeGuaranteeBloc
          .add(ActiveGuarantee(guarantee, customer, ActionType.update));
    }
  }

  void changeStep(int index) {
    if (index == 1) {
      productStepKey.currentState?.widget.onNextStep();
    }
    if (index == 2) {
      customerStepKey.currentState?.handleAndGoToNextStep();
      if (!customerStepKey.currentState!.checkInput()) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }
    }
    stepBloc.changeStep(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void backToPreviousPage() {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Các thông tin bạn đang điền sẽ mất đi\nBạn chắc chắn muốn thoát?",
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
