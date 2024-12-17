abstract class CycleEvent {}

class FetchQuarterlyCycles extends CycleEvent {
  final int month;
  final int year;

  FetchQuarterlyCycles(this.month, this.year);
}
