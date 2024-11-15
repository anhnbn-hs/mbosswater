import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

class AdditionalInfoBloc extends Cubit<AdditionalInfo?> {
  AdditionalInfoBloc(super.initialState);

  AdditionalInfo? additionalInfo;

  void emitAdditionalInfo(AdditionalInfo additionalInfo) {
    this.additionalInfo = additionalInfo;
    emit(additionalInfo);
  }

  void reset(){
    additionalInfo = null;
    emit(null);
  }
}
