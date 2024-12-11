import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/notification/notification_cubit.dart';
import 'package:mbosswater/features/notification/notification_state.dart';
import 'package:mbosswater/features/user_info/presentation/bloc/user_info_bloc.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final UserInfoBloc userInfoBloc;

  @override
  void initState() {
    userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationCubit()..fetchNotifications(userInfoBloc.user?.id ?? ""),
      child: Scaffold(
        appBar: AppBar(
          leading: const LeadingBackButton(),
          title: Text(
            "Thông Báo",
            style: AppStyle.appBarTitle.copyWith(
              color: AppColors.appBarTitleColor,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          scrolledUnderElevation: 0,
        ),
        body: buildListNotification(),
      ),
    );
  }

  Widget buildListNotification() {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if(state is NotificationLoaded){
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return NotificationCard(
                  dateTime: notification.createdAt.toDate(),
                  title: notification.title,
                  body: notification.message,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final DateTime dateTime;
  final String title, body;

  const NotificationCard({
    super.key,
    required this.dateTime,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("hh:mm - dd/MM/yyyy").format(dateTime);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat,
            style: const TextStyle(
              fontFamily: "BeVietnam",
              color: Color(0xff8E8E93),
              fontWeight: FontWeight.w300,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: "BeVietnam",
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontFamily: "BeVietnam",
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
