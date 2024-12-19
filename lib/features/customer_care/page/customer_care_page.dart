import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/features/customer_care/bloc/cycle_bloc.dart';
import 'package:mbosswater/features/customer_care/bloc/cycle_event.dart';
import 'package:mbosswater/features/customer_care/bloc/cycle_state.dart';
import 'package:mbosswater/features/customer_care/bloc/fetch_customers_cubit.dart';
import 'package:mbosswater/features/customer_care/bloc/fetch_guarantee_by_id_cubit.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/reminder.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerCarePage extends StatefulWidget {
  const CustomerCarePage({super.key});

  @override
  State<CustomerCarePage> createState() => _CustomerCarePageState();
}

class _CustomerCarePageState extends State<CustomerCarePage> {
  DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));

  late ValueNotifier<DateTime> focusDayNotifier;
  late final ValueNotifier<List<GuaranteeDateModel>> notifyGuaranteeDays;

  final TextEditingController noteController = TextEditingController();

  // Bloc
  late final CycleBloc cycleBloc;
  late final FetchCustomersCubit fetchCustomersCubit;
  late final FetchGuaranteeByIdCubit fetchGuaranteeByIdCubit;

  @override
  void initState() {
    super.initState();
    cycleBloc = BlocProvider.of<CycleBloc>(context);
    fetchCustomersCubit = BlocProvider.of<FetchCustomersCubit>(context);
    fetchGuaranteeByIdCubit = BlocProvider.of<FetchGuaranteeByIdCubit>(context);

    cycleBloc.add(FetchQuarterlyCycles(now.month, now.year));
    focusDayNotifier = ValueNotifier(now);
    notifyGuaranteeDays = ValueNotifier([]);

    notifyGuaranteeDays.addListener(() {
      List<Reminder> reminders = [];
      notifyGuaranteeDays.value.forEach((element) {
        element.reminders.forEach((r) => reminders.add(r));
      });
      // Fetch customers
      fetchCustomersCubit.fetchCustomersByIds(reminders);
    });

    focusDayNotifier.addListener(() {
      List<Reminder> reminders = [];
      if (focusDayNotifier.value != now) {
        notifyGuaranteeDays.value.forEach((element) {
          if (isSameDate(element.dateTime, focusDayNotifier.value)) {
            element.reminders.forEach((r) => reminders.add(r));
          }
        });
        // Fetch customers
        fetchCustomersCubit.fetchCustomersByIds(reminders);
      }
    });
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  onDaySelected(DateTime day, DateTime focusDay) {
    focusDayNotifier.value = day;
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUrl = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      throw 'Không thể thực hiện cuộc gọi đến $phoneNumber';
    }
  }

  @override
  void dispose() {
    focusDayNotifier.dispose();
    notifyGuaranteeDays.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                scrolledUnderElevation: 0,
                title: null,
                snap: true,
                centerTitle: true,
                floating: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                expandedHeight: 455,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 6, right: 16),
                        child: Stack(
                          children: [
                            Container(
                              height: kToolbarHeight - 4,
                              padding: const EdgeInsets.only(left: 16),
                              alignment: Alignment.center,
                              child: Text(
                                "Chăm Sóc Khách Hàng",
                                style: AppStyle.appBarTitle.copyWith(
                                  color: const Color(0xff820a1a),
                                ),
                              ),
                            ),
                            Container(
                              height: kToolbarHeight,
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => context.pop(),
                                icon: ImageHelper.loadAssetImage(
                                  AppAssets.icArrowLeft,
                                  tintColor: const Color(0xff111827),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      // Phần buildSliverAppBarContent
                      _buildTableCalendar(),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: BlocListener<CycleBloc, CycleState>(
            listener: (context, state) {
              if (state is CycleLoaded) {
                setState(() {
                  notifyGuaranteeDays.value = state.remindersDate;
                });
              }
            },
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Danh sách khách hàng",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "BeVietnam",
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<FetchCustomersCubit, FetchCustomersState>(
                    builder: (context, state) {
                      if (state is FetchCustomersLoading) {
                        return Center(
                          child: Lottie.asset(AppAssets.aLoading, height: 60),
                        );
                      }

                      if (state is FetchCustomersLoaded) {
                        final customers = state.customers;
                        return ListView.builder(
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            bool isNotified = false;
                            String? note;

                            final relevantReminders = customers[index]
                                .reminder
                                .reminderDates
                                ?.where((e) {
                              DateTime reminderDate = e.reminderDate.toDate();
                              // Check if the reminder matches the focus day and is notified
                              if (reminderDate.year ==
                                      focusDayNotifier.value.year &&
                                  reminderDate.month ==
                                      focusDayNotifier.value.month) {
                                return true;
                              }
                              return false;
                            }).toList();

                            if (relevantReminders != null &&
                                relevantReminders.isNotEmpty) {
                              isNotified = relevantReminders.first.isNotified;
                              note = relevantReminders.first.note;
                            }

                            return buildCustomerCardItem(
                              phoneNumber:
                                  customers[index].customer.phoneNumber ?? "",
                              fullName:
                                  customers[index].customer.fullName ?? "",
                              isNotified: isNotified,
                              onTap: () async {
                                // Fetch guarantee
                                fetchGuaranteeByIdCubit.fetchGuaranteeById(
                                    customers[index].reminder.guaranteeId);
                                // Show modal
                                await showBottomSheetCustomerInformation(
                                  customerReminder: customers[index],
                                  reminderDate: relevantReminders
                                      ?.first.reminderDate
                                      .toDate() ?? DateTime.now(),
                                  isNotified: isNotified,
                                  node: note,
                                );
                              },
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
        ),
      ),
    );
  }

  Widget buildCustomerCardItem({
    required String phoneNumber,
    required String fullName,
    required VoidCallback onTap,
    bool isNotified = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                !isNotified ? const Color(0xff800000) : const Color(0xffDADADA),
            width: !isNotified ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffFAFAFA),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              fullName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: "BeVietnam",
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phoneNumber,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: "BeVietnam",
              ),
            ),
          ],
        ),
      ),
    );
  }

  ValueListenableBuilder<DateTime> _buildTableCalendar() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: focusDayNotifier,
      builder: (context, value, child) {
        return TableCalendar(
          locale: 'vi_VN',
          focusedDay: value,
          firstDay: DateTime.utc(2023, 01, 01),
          lastDay: now.add(const Duration(days: 365 * 3)),
          rowHeight: 50,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            headerMargin: const EdgeInsets.only(bottom: 6),
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
            titleTextFormatter: (date, locale) =>
                'Tháng ${date.month} - ${date.year}',
          ),
          onHeaderTapped: (focusedDay) async {
            final selectedDate = await showMonthYearPicker(
              context: context,
              initialDate: focusedDay,
              firstDate: DateTime(2023),
              lastDate: DateTime(now.year + 2),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primaryColor,
                      onPrimary: Colors.white, // Header text color
                      onSurface: Colors.black, // Body text color
                    ),
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 0.93,
                    ),
                    child: child!,
                  ),
                );
              },
            );

            if (selectedDate != null) {
              final updatedDate =
                  DateTime(selectedDate.year, selectedDate.month, 1);
              focusDayNotifier.value = updatedDate;
            }
          },
          daysOfWeekHeight: 24,
          calendarStyle: CalendarStyle(
            todayTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueGrey.shade50,
            ),
            selectedDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableGestures: AvailableGestures.all,
          onDaySelected: onDaySelected,
          selectedDayPredicate: (day) => isSameDay(day, focusDayNotifier.value),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, events) {
              // Kiểm tra nếu ngày trong danh sách specialDays thì thêm indicator
              if (notifyGuaranteeDays.value
                  .any((specialDay) => isSameDay(date, specialDay.dateTime))) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return null;
            },
          ),
          onPageChanged: (dayOfMonth) {
            focusDayNotifier.value = dayOfMonth;
            cycleBloc
                .add(FetchQuarterlyCycles(dayOfMonth.month, dayOfMonth.year));
          },
        );
      },
    );
  }

  Future<void> showBottomSheetCustomerInformation({
    required CustomerReminder customerReminder,
    required DateTime reminderDate,
    required bool isNotified,
    String? node,
  }) async {
    final customer = customerReminder.customer;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierLabel: '',
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thông Tin Khách Hàng",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.appBarTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Khách hàng",
                            style: TextStyle(
                              fontFamily: "BeVietnam",
                              color: Color(0xff820a1a),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildCustomerInfoItem(
                            label: "Họ tên",
                            value: customer.fullName ?? "---",
                            isSelectable: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Số điện thoại",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 50),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async => makePhoneCall(
                                        customer.phoneNumber ?? ""),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff97BE5A),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: IgnorePointer(
                                          child: SelectableText(
                                            customer.phoneNumber ?? "",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              overflow: TextOverflow.ellipsis,
                                              height: 1.8,
                                              letterSpacing: 0.23,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          buildCustomerInfoItem(
                            label: "Địa chỉ",
                            maxLine: 2,
                            value: customer.address!.displayAddress(),
                            isSelectable: true,
                          ),
                          customer.email == null || customer.email == ""
                              ? const SizedBox.shrink()
                              : buildCustomerInfoItem(
                                  label: "Email",
                                  value: customer.email!,
                                  isSelectable: true,
                                ),
                          const SizedBox(height: 16),
                          const Text(
                            "Sản phẩm",
                            style: TextStyle(
                              fontFamily: "BeVietnam",
                              color: Color(0xff820a1a),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<FetchGuaranteeByIdCubit,
                              FetchGuaranteeState>(
                            builder: (context, state) {
                              if (state is FetchGuaranteeLoading) {
                                return Center(
                                  child: Lottie.asset(
                                    AppAssets.aLoading,
                                    height: 60,
                                  ),
                                );
                              }

                              if (state is FetchGuaranteeLoaded) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildGuaranteeItem(state.guarantee, reminderDate),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Ghi chú",
                                      style: TextStyle(
                                        fontFamily: "BeVietnam",
                                        color: Color(0xff820a1a),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
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
                                        controller: noteController,
                                        maxLines: null,
                                        minLines: 5,
                                        enabled: !isNotified,
                                        keyboardType: TextInputType.multiline,
                                        onTapOutside: (event) =>
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode()),
                                        decoration: InputDecoration.collapsed(
                                          hintText: isNotified
                                              ? node
                                              : "Yêu cầu của khách",
                                          hintStyle: AppStyle.boxField.copyWith(
                                            fontSize: 15,
                                            color: isNotified
                                                ? Colors.black87
                                                : const Color(0xffB3B3B3),
                                          ),
                                        ),
                                        cursorHeight: 20,
                                        style: AppStyle.boxField.copyWith(
                                          fontSize: 15,
                                          color: Colors.black87,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    if (!isNotified)
                                      CustomButton(
                                        onTap: () async =>
                                            handleCompleteCustomerCare(
                                                customerReminder),
                                        textButton: "HOÀN THÀNH",
                                      ),
                                    const SizedBox(height: 30),
                                  ],
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
          ),
        );
      },
    );
  }

  Widget buildGuaranteeItem(Guarantee guarantee, DateTime reminderDate) {
    final startDate =
        guarantee.createdAt.toDate().toUtc().add(const Duration(hours: 7));
    final startDateFormatted = DateFormat("dd/MM/yyyy").format(startDate);
    final notifyDateFormatted =
        DateFormat("dd/MM/yyyy").format(reminderDate);
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
            label: "Seri màng lọc",
            value: guarantee.product.seriDow ?? "",
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
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Đến hạn bảo hành",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 50),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      notifyDateFormatted,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
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

  handleCompleteCustomerCare(CustomerReminder customerReminder) async {
    // Show Dialog
    DialogUtils.showLoadingDialog(context);
    final firestore = FirebaseFirestore.instance;
    try {
      final reminderRef =
          firestore.collection("reminders").doc(customerReminder.reminder.id);

      final reminderDates = customerReminder.reminder.reminderDates;

      reminderDates?.forEach((r) {
        if (r.reminderDate.toDate().year == focusDayNotifier.value.year &&
            r.reminderDate.toDate().month == focusDayNotifier.value.month) {
          r.isNotified = true;
          r.note = noteController.text.trim();
        }
      });

      // New reminder for update
      final reminderUpdate = customerReminder.reminder;
      reminderUpdate.reminderDates = reminderDates;

      await reminderRef.update(reminderUpdate.toJson());
      List<Reminder> reminders = [];
      notifyGuaranteeDays.value.forEach((element) {
        element.reminders.forEach((r) => reminders.add(r));
      });
      // Fetch customers
      fetchCustomersCubit.fetchCustomersByIds(reminders);
      cycleBloc.add(FetchQuarterlyCycles(
        focusDayNotifier.value.month,
        focusDayNotifier.value.year,
        isFetchNew: true,
      ));
    } catch (e) {
      print("Failed to update customer care status: $e");
    } finally {
      DialogUtils.hide(context);
      DialogUtils.hide(context);
    }
  }
}
