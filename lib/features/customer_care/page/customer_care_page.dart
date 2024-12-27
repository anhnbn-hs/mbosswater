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
import 'package:mbosswater/features/customer/presentation/bloc/provinces_metadata_bloc.dart';
import 'package:mbosswater/features/customer_care/bloc/cycle_bloc.dart';
import 'package:mbosswater/features/customer_care/bloc/cycle_event.dart';
import 'package:mbosswater/features/customer_care/bloc/cycle_state.dart';
import 'package:mbosswater/features/customer_care/bloc/fetch_customers_cubit.dart';
import 'package:mbosswater/features/customer_care/bloc/fetch_guarantee_by_id_cubit.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/reminder.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
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

  late ValueNotifier<int> needCallNotifier;
  late ValueNotifier<int> incompleteNotifier;
  late ValueNotifier<String?> selectedProvinceFilter;
  final TextEditingController noteController = TextEditingController();

  // Bloc
  late final CycleBloc cycleBloc;
  late final FetchCustomersCubit fetchCustomersCubit;
  late final FetchGuaranteeByIdCubit fetchGuaranteeByIdCubit;
  late final ProvincesMetadataBloc provincesBloc;
  final GlobalKey _sliverAppBarContentKey = GlobalKey();
  double _sliverAppBarHeight = kToolbarHeight;

  @override
  void initState() {
    super.initState();
    cycleBloc = BlocProvider.of<CycleBloc>(context);
    fetchCustomersCubit = BlocProvider.of<FetchCustomersCubit>(context);
    fetchGuaranteeByIdCubit = BlocProvider.of<FetchGuaranteeByIdCubit>(context);
    provincesBloc = BlocProvider.of<ProvincesMetadataBloc>(context);

    cycleBloc.add(FetchQuarterlyCycles(now.month, now.year));
    focusDayNotifier = ValueNotifier(now);
    notifyGuaranteeDays = ValueNotifier([]);
    needCallNotifier = ValueNotifier(0);
    incompleteNotifier = ValueNotifier(0);
    selectedProvinceFilter = ValueNotifier(null);

    notifyGuaranteeDays.addListener(() {
      List<Reminder> reminders = [];
      notifyGuaranteeDays.value.forEach((element) {
        if (element.dateTime.month == focusDayNotifier.value.month) {
          element.reminders.forEach((r) => reminders.add(r));
        }
      });
      // Fetch customers
      // fetchCustomersCubit.fetchCustomersByIds(reminders);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateSliverAppBarHeight();
    });
  }

  void _calculateSliverAppBarHeight() {
    final RenderBox? renderBox = _sliverAppBarContentKey.currentContext
        ?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _sliverAppBarHeight = renderBox.size.height + kToolbarHeight;
        });
      });
    }
  }

  // Add new method to handle page changes
  _handlePageChanged(DateTime dayOfMonth) async {
    focusDayNotifier.value = dayOfMonth;
    cycleBloc.add(FetchQuarterlyCycles(dayOfMonth.month, dayOfMonth.year));
    needCallNotifier.value = 0;
    incompleteNotifier.value = 0;
    // Add slight delay to ensure the new page is rendered
    await Future.delayed(const Duration(milliseconds: 300), () {
      _calculateSliverAppBarHeight();
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
    fetchCustomersCubit.reset();
    selectedProvinceFilter.dispose();
    needCallNotifier.dispose();
    incompleteNotifier.dispose();
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
                expandedHeight: _sliverAppBarHeight,
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
                final reminders = state.remindersDate;
                setState(() {
                  notifyGuaranteeDays.value = reminders;
                });
              }
            },
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Danh sách khách hàng",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "BeVietnam",
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: needCallNotifier,
                        builder: (context, value, child) => buildRowInfoItem(
                          label: "Cần gọi",
                          value: value.toString(),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: incompleteNotifier,
                        builder: (context, value, child) => buildRowInfoItem(
                          label: "Đã hoàn thành",
                          value: value.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async => await showBottomSheetChooseProvinces(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable: selectedProvinceFilter,
                            builder: (context, value, child) => Text(
                              value ?? "Tỉnh/Thành phố",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'BeVietnam',
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: BlocConsumer<FetchCustomersCubit, FetchCustomersState>(
                    listener: (context, state) {
                      if (state is FetchCustomersLoaded) {
                        final customers = state.customers;
                        int needCall = 0;
                        int inComplete = 0;

                        DateTime nextMonth = DateTime(
                          focusDayNotifier.value.year,
                          focusDayNotifier.value.month + 1,
                          focusDayNotifier.value.day,
                        );

                        customers.forEach((c) {
                          c.reminder.reminderDates?.forEach((r) {
                            if (isInLastThreeDaysOfMonth(
                                    focusDayNotifier.value) &&
                                focusDayNotifier.value.month != 12) {
                              if (r.reminderDate.toDate().month ==
                                      nextMonth.month &&
                                  r.reminderDate.toDate().year ==
                                      focusDayNotifier.value.year) {
                                if (!r.isNotified) {
                                  needCall++;
                                } else {
                                  inComplete++;
                                }
                              }
                            } else if (isInLastThreeDaysOfMonth(
                                    focusDayNotifier.value) &&
                                focusDayNotifier.value.month == 12) {
                              if (r.reminderDate.toDate().month ==
                                      nextMonth.month &&
                                  r.reminderDate.toDate().year ==
                                      nextMonth.year) {
                                if (!r.isNotified) {
                                  needCall++;
                                } else {
                                  inComplete++;
                                }
                              }
                            } else {
                              if (r.reminderDate.toDate().month ==
                                      focusDayNotifier.value.month &&
                                  r.reminderDate.toDate().year ==
                                      focusDayNotifier.value.year) {
                                if (!r.isNotified) {
                                  needCall++;
                                } else {
                                  inComplete++;
                                }
                              }
                            }
                          });
                        });
                        needCallNotifier.value = needCall;
                        incompleteNotifier.value = inComplete;
                      }
                    },
                    builder: (context, state) {
                      if (state is FetchCustomersLoading) {
                        return Center(
                          child: Lottie.asset(AppAssets.aLoading, height: 60),
                        );
                      }
                      if (state is FetchCustomersLoaded) {
                        List<CustomerReminder> customers = state.customers;
                        if (selectedProvinceFilter.value != null &&
                            selectedProvinceFilter.value != "Tất cả") {
                          customers = customers.where((c) {
                            if (c.customer.address?.province ==
                                selectedProvinceFilter.value) {
                              return true;
                            }
                            return false;
                          }).toList();
                        }
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

                              DateTime nextMonth = DateTime(
                                focusDayNotifier.value.year,
                                focusDayNotifier.value.month + 1,
                                focusDayNotifier.value.day,
                              );

                              if (isInLastThreeDaysOfMonth(
                                      focusDayNotifier.value) &&
                                  focusDayNotifier.value.month != 12) {
                                // Check if the reminder matches the focus day and is notified
                                if (reminderDate.year ==
                                        focusDayNotifier.value.year &&
                                    reminderDate.month == nextMonth.month) {
                                  return true;
                                }
                              } else if (isInLastThreeDaysOfMonth(
                                      focusDayNotifier.value) &&
                                  focusDayNotifier.value.month == 12) {
                                if (reminderDate.year ==
                                        focusDayNotifier.value.year + 1 &&
                                    reminderDate.month == nextMonth.month) {
                                  return true;
                                }
                              } else {
                                if (reminderDate.year ==
                                        focusDayNotifier.value.year &&
                                    reminderDate.month ==
                                        focusDayNotifier.value.month) {
                                  return true;
                                }
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
                              province:
                                  customers[index].customer.address?.province ??
                                      "",
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
                                          .toDate() ??
                                      DateTime.now(),
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

  bool isInLastThreeDaysOfMonth(DateTime date) {
    // Tìm ngày cuối cùng của tháng
    DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    // Tính khoảng 3 ngày cuối tháng
    DateTime threeDaysBeforeLast = lastDayOfMonth.subtract(Duration(days: 2));

    // Kiểm tra nếu date nằm trong khoảng này
    return date.isAfter(threeDaysBeforeLast) ||
        date.isAtSameMomentAs(threeDaysBeforeLast);
  }

  Widget buildRowInfoItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppStyle.titleItem.copyWith(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: AppStyle.titleItem.copyWith(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomerCardItem({
    required String phoneNumber,
    required String fullName,
    required String province,
    required VoidCallback onTap,
    bool isNotified = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              province,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: "BeVietnam",
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: !isNotified
                      ? const Color(0xff800000)
                      : const Color(0xffDADADA),
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
          ),
        ],
      ),
    );
  }

  ValueListenableBuilder<DateTime> _buildTableCalendar() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: focusDayNotifier,
      builder: (context, value, child) {
        return TableCalendar(
          key: _sliverAppBarContentKey,
          locale: 'vi_VN',
          focusedDay: value,
          firstDay: DateTime.utc(2023, 01, 01),
          lastDay: now.add(const Duration(days: 365 * 3)),
          rowHeight: 50,
          pageAnimationCurve: Curves.easeInExpo,
          headerStyle: HeaderStyle(
            headerPadding: const EdgeInsets.all(0),
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
            final selectedDate = await showMonthPicker(
              context: context,
              initialDate: focusedDay,
              firstDate: DateTime(2023),
              lastDate: DateTime(now.year + 2),
              cancelWidget: const Text(
                "Hủy",
                style: TextStyle(color: Colors.black87),
              ),
              confirmWidget: Text(
                "Chọn",
                style: TextStyle(color: AppColors.primaryColor),
              ),
              monthPickerDialogSettings: MonthPickerDialogSettings(
                buttonsSettings: PickerButtonsSettings(
                  selectedDateRadius: 1,
                  unselectedMonthsTextColor: Colors.black87,
                  unselectedYearsTextColor: Colors.black87,
                  buttonBorder: const CircleBorder(),
                  selectedMonthBackgroundColor: AppColors.primaryColor,
                ),
                headerSettings: PickerHeaderSettings(
                  headerBackgroundColor: AppColors.primaryColor,
                  headerCurrentPageTextStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              headerTitle: const Text(
                "Chọn tháng/năm",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
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
          onPageChanged: (dayOfMonth) async =>
              await _handlePageChanged(dayOfMonth),
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
                                    GestureDetector(
                                      onTap: () {
                                        context.push(
                                          '/guarantee-history',
                                          extra: [state.guarantee, customer],
                                        );
                                      },
                                      child: buildGuaranteeItem(
                                          state.guarantee, reminderDate),
                                    ),
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
    noteController.text = "";
  }

  Widget buildGuaranteeItem(Guarantee guarantee, DateTime reminderDate) {
    final startDate =
        guarantee.createdAt.toDate().toUtc().add(const Duration(hours: 7));
    final startDateFormatted = DateFormat("dd/MM/yyyy").format(startDate);
    final notifyDateFormatted = DateFormat("dd/MM/yyyy").format(reminderDate);
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
      noteController.text = "";
      List<Reminder> reminders = [];
      notifyGuaranteeDays.value.forEach((element) {
        if (element.dateTime.day == focusDayNotifier.value.day) {
          element.reminders.forEach((r) => reminders.add(r));
        }
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

  showBottomSheetChooseProvinces() async {
    final size = MediaQuery.of(context).size;
    provincesBloc.add(FetchProvincesMetaData());
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: size.height * 0.6,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Chọn tỉnh thành",
                  style: AppStyle.heading2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xffEEEEEE),
                  ),
                  child: Center(
                    child: TextField(
                      style: AppStyle.boxField.copyWith(fontSize: 15),
                      onChanged: (value) {
                        provincesBloc.add(SearchProvincesMetaData(value));
                      },
                      textAlignVertical: TextAlignVertical.center,
                      onTapOutside: (event) =>
                          FocusScope.of(context).requestFocus(FocusNode()),
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm tỉnh thành",
                        hintStyle: AppStyle.boxField.copyWith(fontSize: 15),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey,
                        ),
                        isCollapsed: true,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder(
                    bloc: provincesBloc,
                    builder: (context, state) {
                      if (state is ProvincesMetaDataLoading) {
                        return Center(
                          child: Lottie.asset(AppAssets.aLoading, height: 50),
                        );
                      }
                      if (state is ProvincesMetaDataLoaded) {
                        final provinces = List<String>.from(state.provinces);
                        provinces.insert(0, "Tất cả");
                        return ListView.builder(
                          itemCount: provinces.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: .2,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  selectedProvinceFilter.value =
                                      provinces[index];
                                  // Rebuild List Customer
                                  fetchCustomersCubit.rebuildWhenLoaded();
                                  context.pop();
                                },
                                leading: null,
                                minTileHeight: 48,
                                titleAlignment: ListTileTitleAlignment.center,
                                contentPadding: const EdgeInsets.all(0),
                                title: Text(
                                  provinces[index],
                                  style: AppStyle.boxField.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
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
        );
      },
    );
    provincesBloc.emitProvincesFullList();
  }
}
