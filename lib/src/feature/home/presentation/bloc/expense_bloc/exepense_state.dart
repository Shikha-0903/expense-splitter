class ExpenseState {}

class ExpenseSuccess extends ExpenseState {
  final String mesg;

  ExpenseSuccess(this.mesg);
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseFailure extends ExpenseState {
  final String mesg;

  ExpenseFailure(this.mesg);
}
