abstract class CycleEvent {}

class FetchQuarterlyCycles extends CycleEvent {
  final int month;
  final int year;
  bool? isFetchNew;

  FetchQuarterlyCycles(this.month, this.year, {this.isFetchNew});
}
