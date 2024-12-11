// Step 3: Additional Information
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/text_field_label_item.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/additional_info_bloc.dart';
import 'package:mbosswater/features/guarantee/presentation/widgets/box_select_number.dart';
import 'package:mbosswater/features/guarantee/presentation/widgets/water_quantity_rating.dart';

class AdditionalInfoStep extends StatefulWidget {
  const AdditionalInfoStep({
    super.key,
    required this.onNextStep,
    required this.onPreStep,
  });

  final VoidCallback onNextStep, onPreStep;

  @override
  State<AdditionalInfoStep> createState() => AdditionalInfoStepState();
}

class AdditionalInfoStepState extends State<AdditionalInfoStep>
    with AutomaticKeepAliveClientMixin {
  late AdditionalInfoBloc additionalInfoBloc;

  final TextEditingController phController = TextEditingController();

  // Value notifier
  ValueNotifier<int?> adultNumber = ValueNotifier(null);
  ValueNotifier<int?> childNumber = ValueNotifier(null);
  ValueNotifier<int> waterQuantityNumber = ValueNotifier(5);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    additionalInfoBloc = BlocProvider.of<AdditionalInfoBloc>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                Text(
                  "Số lượng thành viên",
                  style: AppStyle.boxFieldLabel,
                ),
                // Text(
                //   " * ",
                //   style: AppStyle.boxFieldLabel.copyWith(
                //     color: AppColors.primaryColor,
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BoxSelectNumber(
                  hint: "Người lớn",
                  numberNotifier: adultNumber,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: BoxSelectNumber(
                  hint: "Trẻ em",
                  numberNotifier: childNumber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Chất lượng nước",
            style: AppStyle.boxFieldLabel,
          ),
          const SizedBox(height: 20),
          WaterQualityRating(
            selectedNumber: waterQuantityNumber,
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "1 là chất lượng nước rất thấp\n5 là chất lượng nước rất tốt",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: "BeVietnam",
                color: Color(0xff828282),
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFieldLabelItem(
            label: "Độ pH",
            hint: "Độ pH",
            isRequired: false,
            controller: phController,
            inputType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 50),
          const Spacer(),
          CustomButton(
            onTap: () {
              // Validate pH input
              double? pH;
              try {
                if (phController.text.isNotEmpty) {
                  pH = double.parse(phController.text);
                }
              } on Exception {
                DialogUtils.showWarningDialog(
                  context: context,
                  title: "Độ pH nhập vào chưa hợp lệ!",
                  onClickOutSide: () {},
                );
                return;
              }

              additionalInfoBloc.emitAdditionalInfo(AdditionalInfo(
                adultNumber: adultNumber.value ?? 0,
                childNumber: childNumber.value ?? 0,
                pH: pH,
                waterQuantity: waterQuantityNumber.value,
              ));
              widget.onNextStep();
            },
            textButton: "XÁC NHẬN BẢO HÀNH",
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
