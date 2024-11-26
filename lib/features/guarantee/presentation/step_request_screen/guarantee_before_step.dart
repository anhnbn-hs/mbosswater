import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_bloc.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_event.dart';
import 'package:mbosswater/features/customer/presentation/bloc/search_customer_state.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class GuaranteeBeforeStep extends StatefulWidget {
  const GuaranteeBeforeStep({super.key});

  @override
  State<GuaranteeBeforeStep> createState() => _GuaranteeBeforeStepState();
}

class _GuaranteeBeforeStepState extends State<GuaranteeBeforeStep> {
  late CustomerSearchBloc customerSearchBloc;
  late UserInfoBloc userInfoBloc;

  ValueNotifier<Customer?> selectedCustomer = ValueNotifier(null);
  final reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    customerSearchBloc = BlocProvider.of<CustomerSearchBloc>(context);
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return SingleChildScrollView(
      child: Column(
        children: [
          buildSearchCustomerFieldItem(
            label: "Khách hàng",
            hint: "Số điện thoại khách hàng",
          ),
          const SizedBox(height: 20),
          buildSelectProductBox(),
          const SizedBox(height: 20),
          buildBoxFieldCannotEdit(
            label: "Kỹ thuật viên phụ trách",
            value: userInfoBloc.user!.fullName!,
          ),
          const SizedBox(height: 20),
          buildBoxFieldCannotEdit(
            label: "Thời gian",
            value: DateFormat("dd/MM/yyyy").format(now),
          ),
          const SizedBox(height: 20),
          buildBoxFieldAreaGuarantee(
            label: "Nguyên nhân bảo hành",
            hint: "Mô tả tình trạng sản phẩm",
            controller: reasonController,
          ),
          const SizedBox(height: 40),
          CustomButton(
            onTap: () {},
            textButton: "TIẾP TỤC",
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Column buildBoxFieldCannotEdit({
    required String label,
    required String value,
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
          height: 40,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xffF6F6F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xffD9D9D9),
            ),
          ),
          child: Text(
            value,
            style: AppStyle.boxField.copyWith(
              fontSize: 15,
              color: Colors.grey,
              height: 1,
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

  Widget buildSearchCustomerFieldItem({
    required String label,
    required String hint,
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
                        fontSize: 16,
                        color: Colors.black87,
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
        ValueListenableBuilder(
          valueListenable: selectedCustomer,
          builder: (context, value, child) {
            if (value == null) return const SizedBox.shrink();
            return Container(
              height: 40,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xffF6F6F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xffD9D9D9),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.phoneNumber!,
                      style: AppStyle.boxField.copyWith(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      selectedCustomer.value = null;
                    },
                    icon: const Icon(
                      Icons.clear,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: selectedCustomer,
          builder: (context, value, child) {
            if (value == null) {
              return Container(
                height: 40,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xffD9D9D9),
                  ),
                ),
                child: TypeAheadField<Customer>(
                  suggestionsCallback: (search) async {
                    if (search.isNotEmpty) {
                      customerSearchBloc
                          .add(SearchAllCustomersByPhone(search.trim()));
                      await for (final state in customerSearchBloc.stream) {
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
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: TextInputType.number,
                      style: AppStyle.boxField.copyWith(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: hint,
                        hintStyle: AppStyle.boxField.copyWith(
                          fontSize: 15,
                          color: const Color(0xffB3B3B3),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      cursorColor: Colors.grey,
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
                    selectedCustomer.value = value;
                  },
                  // Additional customization options
                  debounceDuration: const Duration(milliseconds: 800),
                  hideOnEmpty: false,
                  hideOnLoading: false,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget buildSelectProductBox() {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              Text(
                "Sản phẩm",
                style: AppStyle.boxFieldLabel.copyWith(
                  fontSize: 16,
                  color: Colors.black87,
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
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            showBottomSheetChooseProduct();
          },
          child: Container(
            height: 40,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xffD9D9D9),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Chọn sản phẩm",
                    style: AppStyle.boxField.copyWith(
                      fontSize: 15,
                      color: const Color(0xffB3B3B3),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  showBottomSheetChooseProduct() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          width: double.infinity,
        );
      },
    );
  }
}
