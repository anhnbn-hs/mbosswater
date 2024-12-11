import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/services/notification_service.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/utils/storage.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/datasource/guarantee_datasource_impl.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_event.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/guarantee/active_guarantee_state.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/additional_info_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/customer_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/product_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/step_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/step_active_screen/additional_info_step.dart';
import 'package:mbosswater/features/guarantee/presentation/step_active_screen/customer_info_step.dart';
import 'package:mbosswater/features/guarantee/presentation/step_active_screen/product_info_step.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class GuaranteeActivatePage extends StatefulWidget {
  final Product? product;

  const GuaranteeActivatePage({
    super.key,
    required this.product,
  });

  @override
  State<GuaranteeActivatePage> createState() => GuaranteeActivatePageState();
}

class GuaranteeActivatePageState extends State<GuaranteeActivatePage> {
  // Keys
  final productStepKey = GlobalKey<ProductInfoStepState>();
  final customerStepKey = GlobalKey<CustomerInfoStepState>();
  final additionalStepKey = GlobalKey<AdditionalInfoStepState>();

  late StepBloc stepBloc;
  late ProductBloc productBloc;
  late CustomerBloc customerBloc;
  late AdditionalInfoBloc additionalInfoBloc;
  late ActiveGuaranteeBloc activeGuaranteeBloc;
  late UserInfoBloc userInfoBloc;
  late AgencyBloc agencyBloc;

  late PageController pageController;

  // Flag
  bool isCustomerStepCompleted = false;

  @override
  void initState() {
    super.initState();
    stepBloc = BlocProvider.of<StepBloc>(context);
    productBloc = BlocProvider.of<ProductBloc>(context);
    customerBloc = BlocProvider.of<CustomerBloc>(context);
    additionalInfoBloc = BlocProvider.of<AdditionalInfoBloc>(context);
    activeGuaranteeBloc = BlocProvider.of<ActiveGuaranteeBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    agencyBloc = BlocProvider.of<AgencyBloc>(context);
    handleFetchAgencyInitial();
    pageController = PageController();
  }

  handleFetchAgencyInitial() {
    final user = userInfoBloc.user;
    if (Roles.LIST_ROLES_AGENCY.contains(user?.role)) {
      agencyBloc.fetchAgency(user!.agency!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    stepBloc.reset();
    productBloc.reset();
    customerBloc.reset();
    additionalInfoBloc.reset();
    activeGuaranteeBloc.reset();
    agencyBloc.reset();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        backToPreviousPage();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: LeadingBackButton(
            onTap: () => backToPreviousPage(),
          ),
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: BlocBuilder<StepBloc, int>(
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
                style: AppStyle.appBarTitle.copyWith(color: AppColors.appBarTitleColor),
              );
            },
          ),
        ),
        body: BlocListener(
          bloc: activeGuaranteeBloc,
          listener: (context, state) async {
            if (state is ActiveGuaranteeLoaded) {
              DialogUtils.hide(context);
              // Activated
              await NotificationService.showInstantNotification(
                title: "Thông báo kích hoạt bảo hành thành công",
                body: "Bạn đã kích hoạt bảo hành thành công cho khách hàng: ${state.customer.fullName}",
                detail: "Bạn đã kích hoạt bảo hành thành công cho khách hàng: ${state.customer.fullName}",
              );
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
                      animateToPage(index);
                    },
                  );
                },
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index) => animateToPage(index),
                  children: [
                    ProductInfoStep(
                      key: productStepKey,
                      product: widget.product,
                      onNextStep: () {
                        if (widget.product != null) {
                          productBloc.emitProduct(widget.product!);
                        }
                        stepBloc.goToNextStep();
                        pageController.animateToPage(
                          stepBloc.currentStep,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    CustomerInfoStep(
                      key: customerStepKey,
                      guaranteeActiveKey:
                          widget.key as GlobalKey<GuaranteeActivatePageState>,
                      onPreStep: () {
                        stepBloc.goToPreviousStep();
                        pageController.animateToPage(
                          stepBloc.currentStep,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      onNextStep: (isHandleDuplicatePhone) {
                        stepBloc.goToNextStep();
                        pageController.animateToPage(
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
                        pageController.animateToPage(
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
      if (Roles.LIST_ROLES_AGENCY.contains(userInfoBloc.user?.role)) {
        customer.agency = userInfoBloc.user?.agency;
      } else {
        customer.agency = agencyBloc.selectedAgency?.id;
      }
      // Save additional info to customer
      customer.additionalInfo = additionalInfo;
      DialogUtils.showConfirmationDialog(
        context: context,
        title: "Bạn chắc chắn xác nhận\nthông tin trên ?",
        textCancelButton: "Hủy",
        textAcceptButton: "Xác nhận",
        acceptPressed: () async {
          // Check customer exist

          DialogUtils.showLoadingDialog(context);
          await Future.delayed(const Duration(milliseconds: 800));
          switch (customerStepKey.currentState?.actionType) {
            case ActionType.create:
              await activeGuarantee(product, customer, ActionType.create);
            case ActionType.update:
              await activeGuarantee(product, customer, ActionType.create);
            case null:
            // TODO: Handle this case.
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

  activeGuarantee(
      Product product, Customer customer, ActionType actionType) async {
    DialogUtils.showLoadingDialog(context);
    // handle active
    final userID = await PreferencesUtils.getString(loginSessionKey);
    final guarantee = Guarantee(
      id: generateRandomId(6),
      createdAt: Timestamp.now(),
      product: product,
      customerID: customer.id!,
      technicalID: userID ?? "",
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

  void animateToPage(int index, {bool isOnlyJump = false}) {
    if (index == 1) {
      productStepKey.currentState?.widget.onNextStep();
      isCustomerStepCompleted = false;
    }
    if (index == 2) {
      print(isCustomerStepCompleted);
      if (!isCustomerStepCompleted) {
        customerStepKey.currentState?.handleAndGoToNextStep();
        stepBloc.changeStep(1);
        pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      } else {}
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
