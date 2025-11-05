class ApiEndpoints  {

  static const Map<String, String> header = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  static const String baseUrl = "https://mobapp.dubailuckystar.com:29624/luckyWinner.asmx";

  static const String currentVersion = "1.0.0+1";

  ///login
  static const String agentLogin = "${baseUrl}/Login";

  ///reports
  static const String ticketSearch = "${baseUrl}/SP_PRIZE_DETAILS";

  static const String stockReport = "${baseUrl}/SP_StockReport";

  static const String agentStockIssueDetails = "${baseUrl}/REPORT_STOCK_ISSUE_FOR_DISTRIBUTOR";

  static const String currentStockByAgent = "${baseUrl}/REPORT_STOCK_BALANCE_OF_DISTRIBUTOR";

  static const String salesDetailsByAgent = "${baseUrl}/REPORT_SALE_ENTRY";

  static const String cashReceivablesByAgent = "${baseUrl}/REPORT_CASH_RECEIVABLE";

  static const String cashCollectionByAgent = "${baseUrl}/REPORT_CASH_RECEIVED";

  ///financial overview
  static const String cashBook = "${baseUrl}/GetCashBook";

  static const String dayBook = "${baseUrl}/sp_DaybookReport";

  static const String profitAndLossStatement = "${baseUrl}/REPORT_PANDL";

  static const String expenseIncomeTracker = "${baseUrl}/USP_GETJOURNALENTRYREPORT";

  ///extra url
  static const String getAgent = "${baseUrl}/USP_GetDistributor_LIST";

  static const String getProducts = "${baseUrl}/USP_Getproducts";

}
