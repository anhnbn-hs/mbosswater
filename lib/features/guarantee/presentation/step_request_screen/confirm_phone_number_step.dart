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
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/customer_guarantee_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/fetch_customer_state.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_state.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class ConfirmPhoneNumberStep extends StatefulWidget {
  final VoidCallback onNextStep;

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

  @override
  void initState() {
    super.initState();
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    customerSearched.dispose();
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
                    const SizedBox(height: 40),
                    CustomButton(
                      onTap: () {
                        widget.onNextStep();
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
          searchNotifier.value = value.phoneNumber ?? "";
          customerSearched.value = value;
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
                    child: Container(),
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
}
