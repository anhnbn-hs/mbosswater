import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_state.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_state.dart';
import 'package:mbosswater/features/home/bloc/search_customer_bloc.dart';
import 'package:mbosswater/features/home/bloc/search_customer_event.dart';
import 'package:mbosswater/features/home/bloc/search_customer_state.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class ConfirmPhoneNumberStep extends StatefulWidget {
  final Function({
    required Customer customer,
    required Guarantee guarantee,
  }) onNextStep;

  const ConfirmPhoneNumberStep({
    super.key,
    required this.onNextStep,
  });

  @override
  State<ConfirmPhoneNumberStep> createState() => ConfirmPhoneNumberStepState();
}

class ConfirmPhoneNumberStepState extends State<ConfirmPhoneNumberStep>
    with AutomaticKeepAliveClientMixin {
  late UserInfoBloc userInfoBloc;

  ValueNotifier<String> searchNotifier = ValueNotifier<String>("");
  final TextEditingController _textController = TextEditingController();

  ValueNotifier<Customer?> customerSearched = ValueNotifier(null);
  ValueNotifier<Guarantee?> guaranteeSelected = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    customerSearched.dispose();
    guaranteeSelected.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: FractionalOffset.centerLeft,
            child: Text(
              "Số điện thoại",
              style: AppStyle.boxFieldLabel.copyWith(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 12),
          buildSearchSection(context),
          const SizedBox(height: 20),
          ValueListenableBuilder(
            valueListenable: customerSearched,
            builder: (context, value, child) {
              if (value != null) {
                return Column(
                  children: [
                    buildBoxField(
                      label: "Họ và tên",
                      value: value.fullName ?? "",
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: FractionalOffset.centerLeft,
                      child: Text(
                        "Sản phẩm",
                        style: AppStyle.boxFieldLabel.copyWith(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async => showModalChooseProduct(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xffD9D9D9),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Chọn sản phẩm",
                              style: AppStyle.boxFieldLabel.copyWith(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    ValueListenableBuilder<Guarantee?>(
                      valueListenable: guaranteeSelected,
                      builder: (context, value, child) {
                        if (value != null) {
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              Align(
                                alignment: FractionalOffset.centerLeft,
                                child: Text(
                                  "Sản phẩm đã chọn",
                                  style: AppStyle.boxFieldLabel.copyWith(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              buildGuaranteeItem(value),
                              const SizedBox(height: 40),
                              CustomButton(
                                onTap: () {
                                  widget.onNextStep(
                                    customer: customerSearched.value!,
                                    guarantee: guaranteeSelected.value!,
                                  );
                                },
                                textButton: "XÁC NHẬN",
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xffD9D9D9),
        ),
      ),
      child: TypeAheadField<Customer>(
        suggestionsCallback: (search) async {
          if (search.isNotEmpty) {
            final CustomerSearchBloc bloc =
                BlocProvider.of<CustomerSearchBloc>(context);
            bloc.add(SearchAllCustomersByPhone(search.trim()));
            await for (final state in bloc.stream) {
              if (state is CustomerSearchLoaded) {
                return state.customers;
              } else if (state is CustomerSearchError) {
                // Handle error case
                return [];
              }
            }
            return [];
          }
          return null;
        },
        builder: (context, controller, focusNode) {
          return ValueListenableBuilder<String>(
            valueListenable: searchNotifier,
            builder: (context, value, child) {
              controller.text = value;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: (text) => searchNotifier.value = text,
                keyboardType: TextInputType.number,
                style: AppStyle.boxField.copyWith(
                  color: Colors.black87,
                  fontSize: 15,
                ),
                textAlignVertical: TextAlignVertical.center,
                onTapOutside: (event) =>
                    FocusScope.of(context).requestFocus(FocusNode()),
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Số điện thoại",
                  hintStyle: AppStyle.boxField.copyWith(
                    color: const Color(0xff828282),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  isCollapsed: true,
                ),
                cursorColor: Colors.grey,
              );
            },
          );
        },
        loadingBuilder: (context) {
          return Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Lottie.asset(
                AppAssets.aLoading,
                height: 50,
              ),
            ),
          );
        },
        emptyBuilder: (context) {
          return Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: const Center(
              child: Text("Không tìm thấy khách hàng!"),
            ),
          );
        },
        errorBuilder: (context, error) {
          return Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: const Center(
              child: Text("Xảy ra lỗi. Hãy thử lại!"),
            ),
          );
        },
        itemBuilder: (context, customer) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: .3,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Row(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(
                    Icons.person_outlined,
                    color: Colors.black54,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.centerLeft,
                    child: Text(
                      "${customer.fullName} (${customer.phoneNumber})",
                      style: const TextStyle(
                        color: Color(0xff282828),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
        onSelected: (Customer value) {
          if (searchNotifier.value != value.phoneNumber) {
            searchNotifier.value = value.phoneNumber ?? "";
          }
          customerSearched.value = value;
          if (guaranteeSelected.value != null &&
              guaranteeSelected.value?.customerID != value.id) {
            guaranteeSelected.value = null;
          }
          final customerGuaranteeBloc =
              BlocProvider.of<CustomerGuaranteeBloc>(context);
          customerGuaranteeBloc.add(FetchCustomerGuarantees(value.id ?? ""));
        },
        // Additional customization options
        debounceDuration: const Duration(milliseconds: 800),
        hideOnEmpty: false,
        hideOnLoading: false,
      ),
    );
  }

  Column buildBoxField({
    required String label,
    required String value,
    bool isEnable = true,
  }) {
    return Column(
      children: [
        Align(
          alignment: FractionalOffset.centerLeft,
          child: Text(
            label,
            style: AppStyle.boxFieldLabel.copyWith(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xffF6F6F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffD9D9D9),
            ),
          ),
          child: Text(
            value,
            maxLines: 2,
            style: AppStyle.boxField.copyWith(
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Column buildBoxFieldAreaGuarantee({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: label != ""
              ? Row(
                  children: [
                    Text(
                      label,
                      style: AppStyle.boxFieldLabel.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      " * ",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                      ),
                    )
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffD9D9D9),
            ),
          ),
          child: TextField(
              maxLines: 6,
              controller: controller,
              onTapOutside: (event) =>
                  FocusScope.of(context).requestFocus(FocusNode()),
              decoration: InputDecoration.collapsed(
                hintText: "Mô tả tình trạng sản phẩm",
                hintStyle: AppStyle.boxField.copyWith(
                  fontSize: 15,
                  color: const Color(0xffB3B3B3),
                ),
              ),
              cursorHeight: 20,
              style: AppStyle.boxField.copyWith(
                fontSize: 15,
                color: Colors.grey,
                height: 1,
              )),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  showModalChooseProduct() async {
    await showModalBottomSheet(
      context: context,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height - 70,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Container(
                height: 3,
                margin: const EdgeInsets.only(
                  left: 150,
                  right: 150,
                  top: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                ),
              ),
              Positioned(
                top: 36,
                bottom: 0,
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          "Chọn Sản Phẩm",
                          style: AppStyle.heading2.copyWith(
                            color: AppColors.appBarTitleColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 23),
                        BlocBuilder<CustomerGuaranteeBloc,
                            CustomerGuaranteeState>(
                          builder: (context, state) {
                            if (state is CustomerGuaranteeLoading) {
                              return Center(
                                child: Lottie.asset(AppAssets.aLoading,
                                    height: 60),
                              );
                            }

                            if (state is CustomerGuaranteeLoaded) {
                              final now = DateTime.now()
                                  .toUtc()
                                  .add(const Duration(hours: 7));
                              final guarantees = state.guarantees
                                  .where((g) => g.endDate.isAfter(now))
                                  .toList();
                              return ListView.builder(
                                itemCount: guarantees.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: GestureDetector(
                                      onTap: () {
                                        guaranteeSelected.value =
                                            guarantees[index];
                                        Navigator.pop(context);
                                      },
                                      child:
                                          buildGuaranteeItem(guarantees[index]),
                                    ),
                                  );
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.primaryColor,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildGuaranteeItem(Guarantee guarantee) {
    final startDate =
        guarantee.createdAt.toDate().toUtc().add(const Duration(hours: 7));
    final startDateFormatted = DateFormat("dd/MM/yyyy").format(startDate);
    bool expired = isExpired(guarantee.endDate);
    int remainingMonth = getRemainingMonths(
      guarantee.endDate.toUtc().add(
            const Duration(hours: 7),
          ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xffDADADA),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: FractionalOffset.centerLeft,
            child: Text(
              "#${guarantee.id.toUpperCase()}",
              style: const TextStyle(
                color: Color(0xff820a1a),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 12),
          buildCustomerInfoItem(
            label: "Sản phẩm",
            value: guarantee.product.name ?? "Máy Lọc Nước Tạo Kiềm MBossWater",
          ),
          buildCustomerInfoItem(
            label: "Model máy",
            value: guarantee.product.model ?? "",
          ),
          buildCustomerInfoItem(
            label: "Ngày kích hoạt",
            value: startDateFormatted,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tình trạng",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: CircleAvatar(
                        backgroundColor: expired
                            ? AppColors.primaryColor
                            : const Color(0xff00B81C),
                        radius: 4,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      expired
                          ? "Hết hạn bảo hành"
                          : "Còn $remainingMonth tháng bảo hành",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomerInfoItem({
    required String label,
    required String value,
    int maxLine = 1,
    bool isSelectable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 50),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: isSelectable
                  ? SelectableText(
                      value,
                      maxLines: maxLine,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Text(
                      value,
                      maxLines: maxLine,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
