class LossProfitModel {
  final List<IncomeSummaryModel>? incomeSummary;
  final List<ExpenseSummaryModel>? expenseSummary;
  final num? grossSalProfit;
  final num? grossIncomeProfit;
  final num? totalExpenses;
  final num? netProfit;
  final num? cartGrossProfit;
  final num? totalCardExpense;
  final num? cardNetProfit;

  LossProfitModel({
    this.incomeSummary,
    this.expenseSummary,
    this.grossSalProfit,
    this.grossIncomeProfit,
    this.totalExpenses,
    this.netProfit,
    this.cartGrossProfit,
    this.totalCardExpense,
    this.cardNetProfit,
  });

  factory LossProfitModel.fromJson(Map<String, dynamic> json) {
    return LossProfitModel(
      incomeSummary: json["mergedIncomeSaleData"] == null
          ? []
          : List<IncomeSummaryModel>.from(json["mergedIncomeSaleData"]!.map((x) => IncomeSummaryModel.fromJson(x))),
      expenseSummary: json["mergedExpenseData"] == null
          ? []
          : List<ExpenseSummaryModel>.from(json["mergedExpenseData"]!.map((x) => ExpenseSummaryModel.fromJson(x))),
      grossSalProfit: json["grossSaleProfit"],
      grossIncomeProfit: json['grossIncomeProfit'],
      totalExpenses: json['totalExpenses'],
      netProfit: json['netProfit'],
      cartGrossProfit: json['cardGrossProfit'],
      totalCardExpense: json['totalCardExpenses'],
      cardNetProfit: json['cardNetProfit'],
    );
  }
}

class IncomeSummaryModel {
  final String? type;
  final String? date;
  final num? totalIncome;

  IncomeSummaryModel({this.type, this.date, this.totalIncome});

  factory IncomeSummaryModel.fromJson(Map<String, dynamic> json) {
    return IncomeSummaryModel(
      type: json["type"],
      date: json["date"],
      totalIncome: json["total_incomes"],
    );
  }
}

class ExpenseSummaryModel {
  final String? type;
  final String? date;
  final num? totalExpense;

  ExpenseSummaryModel({this.type, this.date, this.totalExpense});

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryModel(
      type: json["type"],
      date: json["date"],
      totalExpense: json["total_expenses"],
    );
  }
}
