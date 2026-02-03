import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ============================================
  // AUTHENTICATION EVENTS
  // ============================================

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignOut() async {
    await _analytics.logEvent(name: 'sign_out');
    await _analytics.setUserId(id: null);
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Log authentication-related errors
  Future<void> logAuthError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'auth_error',
      parameters: {'error_type': errorType, 'error_message': errorMessage},
    );
  }

  /// Log when OTP is sent
  Future<void> logOtpSent(String otpType) async {
    await _analytics.logEvent(
      name: 'otp_sent',
      parameters: {
        'otp_type': otpType, // 'signup', 'password_reset', 'login'
      },
    );
  }

  /// Log OTP verification attempts
  Future<void> logOtpVerified(String otpType, bool success) async {
    await _analytics.logEvent(
      name: success ? 'otp_verified_success' : 'otp_verified_failed',
      parameters: {'otp_type': otpType},
    );
  }

  /// Log when OTP is resent
  Future<void> logOtpResent(String otpType) async {
    await _analytics.logEvent(
      name: 'otp_resent',
      parameters: {'otp_type': otpType},
    );
  }

  // ============================================
  // STOCK DISCOVERY & SEARCH
  // ============================================

  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  Future<void> logStockView(String ticker, String companyName) async {
    await _analytics.logViewItem(
      currency: 'USD',
      value: 0.0,
      items: [
        AnalyticsEventItem(
          itemId: ticker,
          itemName: companyName,
          itemCategory: 'stock',
        ),
      ],
    );
  }

  // ============================================
  // WATCHLIST EVENTS
  // ============================================

  Future<void> logCreateWatchlist(String watchlistName) async {
    await _analytics.logEvent(
      name: 'create_watchlist',
      parameters: {'watchlist_name': watchlistName},
    );
  }

  Future<void> logEditWatchlist(String watchlistId) async {
    await _analytics.logEvent(
      name: 'edit_watchlist',
      parameters: {'watchlist_id': watchlistId},
    );
  }

  Future<void> logDeleteWatchlist(String watchlistId, int stockCount) async {
    await _analytics.logEvent(
      name: 'delete_watchlist',
      parameters: {'watchlist_id': watchlistId, 'stock_count': stockCount},
    );
  }

  Future<void> logAddToWatchlist(String ticker, String watchlistId) async {
    await _analytics.logEvent(
      name: 'add_to_watchlist',
      parameters: {'ticker': ticker, 'watchlist_id': watchlistId},
    );
  }

  Future<void> logRemoveFromWatchlist(String ticker, String watchlistId) async {
    await _analytics.logEvent(
      name: 'remove_from_watchlist',
      parameters: {'ticker': ticker, 'watchlist_id': watchlistId},
    );
  }

  // ============================================
  // STARRED STOCKS
  // ============================================

  Future<void> logToggleStar(String ticker, bool isStarred) async {
    await _analytics.logEvent(
      name: isStarred ? 'star_stock' : 'unstar_stock',
      parameters: {'ticker': ticker},
    );
  }

  // ============================================
  // CHART INTERACTIONS
  // ============================================

  Future<void> logChartTimeRangeChange(String ticker, String timeRange) async {
    await _analytics.logEvent(
      name: 'chart_timerange_change',
      parameters: {
        'ticker': ticker,
        'time_range': timeRange, // 1D, 1W, 1M, 3M, 1Y, 5Y, All
      },
    );
  }

  Future<void> logChartInteraction(
    String ticker,
    String interactionType,
    String page,
    String chartType,
  ) async {
    await _analytics.logEvent(
      name: '${page}_chart_interaction',
      parameters: {
        'ticker': ticker,
        'interaction_type': interactionType, //drag,tap
        'chart_type': chartType,
      },
    );
  }

  // ============================================
  // FINANCIAL DATA VIEWS
  // ============================================

  Future<void> logViewFinancialStatement(String ticker) async {
    await _analytics.logEvent(
      name: 'view_financial_statement',
      parameters: {'ticker': ticker},
    );
  }

  Future<void> logViewCompanyProfile(String ticker) async {
    await _analytics.logEvent(
      name: 'view_company_profile',
      parameters: {'ticker': ticker},
    );
  }

  Future<void> logViewRevenueSegmentation(String ticker) async {
    await _analytics.logEvent(
      name: 'view_revenue_segmentation',
      parameters: {'ticker': ticker},
    );
  }

  // ============================================
  // SEC FILINGS
  // ============================================

  Future<void> logViewFiling(String ticker, String filingType) async {
    await _analytics.logEvent(
      name: 'view_sec_filing',
      parameters: {
        'ticker': ticker,
        'filing_type': filingType, // 10-Q, 10-K, 8-K
      },
    );
  }

  Future<void> logOpenFilingExternal(String ticker, String filingType) async {
    await _analytics.logEvent(
      name: 'open_filing_external',
      parameters: {'ticker': ticker, 'filing_type': filingType},
    );
  }

  // ============================================
  // EARNINGS TRANSCRIPTS
  // ============================================

  Future<void> logViewTranscript(String ticker) async {
    await _analytics.logEvent(
      name: 'view_earnings_transcript',
      parameters: {'ticker': ticker},
    );
  }

  // ============================================
  // FORECASTS & ESTIMATES
  // ============================================

  Future<void> logViewForecast(String ticker) async {
    await _analytics.logEvent(
      name: 'view_forecast',
      parameters: {'ticker': ticker},
    );
  }

  // ============================================
  // USER ENGAGEMENT
  // ============================================

  Future<void> logPullToRefresh(String screenName) async {
    await _analytics.logEvent(
      name: 'pull_to_refresh',
      parameters: {'screen_name': screenName},
    );
  }

  Future<void> logThemeChange(String theme) async {
    await _analytics.logEvent(
      name: 'theme_change',
      parameters: {'theme': theme}, // dark, light, system
    );
  }

  /// Log screen views with custom event names
  Future<void> logScreenView(String screenName, String? ticker) async {
    await _analytics.logEvent(
      name: screenName.toLowerCase().replaceAll(' ', '_'),
      parameters: {
        'screen_name': screenName,
        if (ticker != null && ticker.isNotEmpty) 'ticker': ticker,
      },
    );
  }

  // ============================================
  // ERROR TRACKING
  // ============================================

  Future<void> logError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {'error_type': errorType, 'error_message': errorMessage},
    );
  }

  Future<void> logRetryAction(String screenName, String actionType) async {
    await _analytics.logEvent(
      name: 'retry_action',
      parameters: {'screen_name': screenName, 'action_type': actionType},
    );
  }
}
