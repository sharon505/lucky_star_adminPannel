class ApiEndpoints {
  // ---- Base ----
  static const String _base = 'https://mobapp.dubailuckystar.com:29624/luckyWinner.asmx';

  // Use Uri so you don't need Uri.parse everywhere.
  static Uri _u(String path) => Uri.parse('$_base/$path');

  // ---- Headers ----
  static const Map<String, String> formHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
  };

  // Handy if you add JSON endpoints later
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
  };

  // ---- App meta ----
  static const String appVersion = '1.0.0+1';

  // ---- Auth ----
  static final Uri agentLogin = _u('Login');

  // ---- Reports ----
  static final Uri ticketSearch            = _u('SP_PRIZE_DETAILS');///finish

  static final Uri stockReport             = _u('SP_StockReport');///finish
  static final Uri agentStockIssueDetails  = _u('REPORT_STOCK_ISSUE_FOR_DISTRIBUTOR');///finish
  static final Uri currentStockByAgent     = _u('REPORT_STOCK_BALANCE_OF_DISTRIBUTOR');

  static final Uri salesDetailsByAgent     = _u('REPORT_SALE_ENTRY');
  static final Uri cashReceivablesByAgent  = _u('REPORT_CASH_RECEIVABLE');
  static final Uri cashCollectionByAgent   = _u('REPORT_CASH_RECEIVED');

  // ---- Financial overview ----
  static final Uri cashBook                = _u('GetCashBook');
  static final Uri dayBook                 = _u('sp_DaybookReport'); // check case on server
  static final Uri profitAndLossStatement  = _u('REPORT_PANDL');
  static final Uri expenseIncomeTracker    = _u('USP_GETJOURNALENTRYREPORT');

  // ---- Extra ----
  static final Uri getAgent                = _u('USP_GetDistributor_LIST');///finish
  static final Uri getProducts             = _u('USP_Getproducts'); ///finish
}
