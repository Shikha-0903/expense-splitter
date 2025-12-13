class ExpenseEvent {}

class AddExpenseRequested extends ExpenseEvent {
  final String eventName;
  final String description;
  final double amount;
  final DateTime date;
  final List<String> tags;
  final List<String> participants;

  AddExpenseRequested(
    this.eventName,
    this.description,
    this.amount,
    this.date,
    this.tags,
    this.participants,
  );
}
