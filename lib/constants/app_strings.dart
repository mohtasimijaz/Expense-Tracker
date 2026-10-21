/// Every user-facing string in the app.
///
/// Keeping text in one place makes copy changes and future translation
/// (e.g. moving to ARB files) straightforward.
abstract final class AppStrings {
  // App
  static const String appName = 'Expense Tracker';
  static const String appTagline =
      'Know where every rupee, dollar and euro goes';

  // Navigation
  static const String navHome = 'Home';
  static const String navStatistics = 'Statistics';
  static const String navSettings = 'Settings';

  // Onboarding
  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingStart = 'Get started';
  static const String onboardingTitle1 = 'Track every expense';
  static const String onboardingBody1 =
      'Add spending in seconds and keep everything safely stored on your device.';
  static const String onboardingTitle2 = 'See where money goes';
  static const String onboardingBody2 =
      'Beautiful charts show trends, categories and how this month compares to the last.';
  static const String onboardingTitle3 = 'Stay on budget';
  static const String onboardingBody3 =
      'Set a monthly budget and get alerts before you overspend.';
  static const String onboardingPrivacyPrefix =
      'By continuing you agree to our ';

  // Home
  static const String homeGreeting = 'Overview';
  static const String homeThisMonth = 'Spent this month';
  static const String homeTotalSpent = 'Total spent';
  static const String homeTransactions = 'Transactions';
  static const String homeHighest = 'Highest';
  static const String homeRecent = 'Expenses';
  static const String homeAllTime = 'All time';
  static const String homeClearFilters = 'Clear filters';
  static const String homeSetBudgetPrompt =
      'Set a monthly budget to track your limit';
  static const String homeSetBudgetAction = 'Set budget';

  // Search, sort, filter
  static const String searchHint = 'Search';
  static const String clearSearch = 'Clear search';
  static const String sortTooltip = 'Sort';
  static const String dateRangeTooltip = 'Filter by date';
  static const String sortNewest = 'Newest first';
  static const String sortOldest = 'Oldest first';
  static const String sortHighest = 'Highest amount';
  static const String sortLowest = 'Lowest amount';
  static const String sortCategory = 'Category (A–Z)';
  static const String filterAll = 'All';

  // Expense list
  static const String expenseSingular = 'expense';
  static const String expensePlural = 'expenses';
  static const String expenseDeleted = 'deleted';
  static const String undo = 'UNDO';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String swipeToDelete = 'Delete';

  // Empty / loading / error
  static const String emptyTitle = 'No expenses yet';
  static const String emptyMessage =
      'Tap the + button to add your first expense.';
  static const String noResultsTitle = 'No matching expenses';
  static const String noResultsMessage =
      'Try a different search, category or date range.';
  static const String addFirstExpense = 'Add expense';
  static const String loading = 'Loading your expenses…';
  static const String errorTitle = 'Something went wrong';
  static const String retry = 'Try again';
  static const String errorLoad = 'Could not load your expenses.';
  static const String errorSave =
      'Could not save the expense. Please try again.';
  static const String errorDelete =
      'Could not delete the expense. It has been restored.';
  static const String errorRestore = 'Could not restore the expense.';
  static const String errorClear = 'Could not delete your expenses.';
  static const String errorSettings = 'Could not save the setting.';
  static const String errorUnknown = 'An unexpected error occurred.';
  static const String errorShare = 'Could not share the recap.';

  // Add / edit
  static const String addExpenseTitle = 'New expense';
  static const String editExpenseTitle = 'Edit expense';
  static const String fieldTitle = 'Title';
  static const String fieldTitleHint = 'e.g. Lunch with friends';
  static const String fieldAmount = 'Amount';
  static const String fieldCategory = 'Category';
  static const String fieldDate = 'Date';
  static const String fieldNote = 'Note (optional)';
  static const String fieldNoteHint = 'Add any details';
  static const String saveExpense = 'Save expense';
  static const String updateExpense = 'Update expense';
  static const String deleteExpense = 'Delete expense';
  static const String expenseSaved = 'Expense saved';
  static const String expenseUpdated = 'Expense updated';
  static const String validationTitleEmpty = 'Please enter a title';
  static const String validationTitleLong = 'Title is too long';
  static const String validationAmountEmpty = 'Please enter an amount';
  static const String validationAmountInvalid = 'Please enter a valid number';
  static const String validationAmountZero = 'Amount must be greater than zero';
  static const String validationAmountTooLarge = 'Amount is too large';
  static const String validationNoteLong = 'Note is too long';

  // Statistics
  static const String statsTitle = 'Statistics';
  static const String statsBreakdown = 'Spending breakdown';
  static const String statsToday = 'Today';
  static const String statsThisWeek = 'This week';
  static const String statsThisMonth = 'This month';
  static const String statsDailyAverage = 'Daily average';
  static const String statsComparison = 'Compared with last month';
  static const String statsLastMonth = 'Last month';
  static const String statsMoreThanLastMonth = 'more than last month';
  static const String statsLessThanLastMonth = 'less than last month';
  static const String statsSameAsLastMonth = 'Same as last month';
  static const String statsNoPreviousMonth =
      'No spending last month to compare';
  static const String statsWeekly = 'Last 7 days';
  static const String statsMonthlyTrend = 'Monthly trend';
  static const String statsCategories = 'By category';
  static const String statsPeriodMonth = 'This month';
  static const String statsPeriodAll = 'All time';
  static const String statsNoDataTitle = 'No statistics yet';
  static const String statsNoDataMessage =
      'Add a few expenses to see charts and trends.';
  static const String statsNoCategoryData = 'No spending in this period';

  // Budget
  static const String budgetTitle = 'Monthly budget';
  static const String budgetOf = 'of';
  static const String budgetUsed = 'used';
  static const String budgetLeft = 'left';
  static const String budgetOver = 'over budget';
  static const String budgetWarningTitle = 'Budget almost used';
  static const String budgetWarningMessage = 'You have used';
  static const String budgetWarningSuffix = 'of your monthly budget.';
  static const String budgetExceededTitle = 'Budget exceeded';
  static const String budgetExceededMessage =
      'You are over your monthly budget by';
  static const String budgetNotSet = 'Not set';
  static const String budgetDialogHint = 'Enter amount (0 to turn off)';
  static const String budgetRemove = 'Remove budget';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String sectionPreferences = 'PREFERENCES';
  static const String sectionBudget = 'BUDGET';
  static const String sectionNotifications = 'NOTIFICATIONS';
  static const String sectionData = 'DATA';
  static const String sectionAbout = 'ABOUT';
  static const String settingCurrency = 'Currency';
  static const String settingTheme = 'Theme';
  static const String themeSystem = 'System';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String settingBudgetAlerts = 'Budget alerts';
  static const String settingBudgetAlertsSubtitle =
      'Warn me when I approach or exceed my budget';
  static const String settingAlertThreshold = 'Warn me at';
  static const String settingAlertThresholdSuffix = '% of budget';
  static const String settingClearData = 'Delete all expenses';
  static const String settingClearDataSubtitle =
      'Permanently removes every expense';
  static const String clearDataConfirmTitle = 'Delete all expenses?';
  static const String clearDataConfirmMessage =
      'This removes every expense from this device. You can undo right after.';
  static const String clearDataDone = 'All expenses deleted';
  static const String settingPrivacy = 'Privacy policy';
  static const String settingVersion = 'Version';

  // Currency picker
  static const String currencyPickerTitle = 'Choose currency';
  static const String currencySearchHint = 'Search by name or code';
  static const String currencyNoResults = 'No currency found';

  // Delete, undo and options
  static const String expenseDeletedTitle = 'Expense deleted';
  static const String expenseRestored = 'Expense restored';
  static const String dismiss = 'Dismiss';
  static const String optionsEdit = 'Edit';
  static const String optionsDelete = 'Delete';
  static const String gestureHint =
      'Swipe left to delete · Press and hold for more options';

  // Quick add
  static const String quickAddTitle = 'Add expense';
  static const String quickAddMoreDetails = 'More details';
  static const String quickAddSave = 'Save';
  static const String keypadBackspace = 'Delete last digit';
  static const String keypadDecimal = 'Decimal point';

  // Haptics setting
  static const String settingHaptics = 'Haptic feedback';
  static const String settingHapticsSubtitle =
      'Vibrate on taps, saves and deletes';

  // Streaks and celebrations
  static const String streakTooltip =
      'Days in a row with at least one expense logged';
  static const String celebrationButton = 'Awesome!';
  static String streakChip(int days) => '$days-day streak';
  static String streakCelebrationTitle(int days) => '$days-day streak!';
  static String streakCelebrationMessage(int days) =>
      "You've logged expenses $days days in a row. Keep it going!";
  static String monthCelebrationTitle(String month) => '$month: under budget!';
  static String monthCelebrationMessage(String saved) =>
      'You stayed within your budget and kept $saved. Well done!';

  // Insights
  static const String insightsTitle = 'Insights';
  static const String insightPaceGood = 'On track';
  static const String insightPaceBad = 'Heads up';
  static const String insightWeekend = 'Weekend effect';
  static const String insightTopCategory = 'Top category';
  static const String insightNoSpend = 'No-spend days';
  static const String insightBiggest = 'Biggest expense';
  static const String insightRecapMessage = 'Tap to see your month in review';
  static String insightPace(String amount, int percent) =>
      "At this pace you'll spend $amount this month — $percent% of your "
      'budget.';
  static String insightCategoryTitle(String category) => '$category spending';
  static String insightCategoryLess(int percent, String category) =>
      'You spent $percent% less on $category than this time last month 🎉';
  static String insightCategoryMore(int percent, String category) =>
      'You spent $percent% more on $category than this time last month.';
  static String insightWeekendMore(String ratio) =>
      'Weekends cost you $ratio× more per day than weekdays.';
  static String insightWeekdayMore(String ratio) =>
      'Weekdays cost you $ratio× more per day than weekends.';
  static String insightTopCategoryMessage(String category, int percent) =>
      '$category is $percent% of your spending this month.';
  static String insightNoSpendMessage(int days) =>
      '$days no-spend ${days == 1 ? 'day' : 'days'} this month. Nice '
      'discipline! 💪';
  static String insightBiggestMessage(String title, String amount) =>
      '$title — $amount.';
  static String insightRecapTitle(String month) => 'Your $month recap';

  // Monthly recap
  static const String recapTooltip = 'Monthly recap';
  static const String recapYouSpent = 'You spent';
  static const String recapTopCategory = 'Your top category';
  static const String recapBiggestDay = 'Your biggest day';
  static const String recapNoSpendDays = 'No-spend days';
  static const String recapShare = 'Share';
  static const String recapClose = 'Close';
  static const String recapEmpty = 'No expenses this month yet.';
  static const String recapFooter = 'Made with Expense Tracker';
  static String recapTitle(String month, {required bool current}) =>
      current ? '$month so far' : 'Your $month';
  static String recapCount(int count) =>
      'across $count ${count == 1 ? 'expense' : 'expenses'}';
  static String recapAverage(String amount) => "That's $amount a day";
  static String recapShareOf(int percent) => '$percent% of everything';
  static String recapCompared(String month) => 'Compared with $month';
  static String recapLess(int percent) => '$percent% less 🎉';
  static String recapMore(int percent) => '$percent% more';
  static String recapNoSpendMessage(int days, int total) =>
      '$days of $total days without spending';
  static String recapShareText(String month) =>
      'My $month spending recap from Expense Tracker';

  // Privacy policy
  static const String privacyTitle = 'Privacy policy';
  static const String privacyUpdatedPrefix = 'Last updated: ';
  static const List<(String, String)> privacySections = [
    (
      'Overview',
      'Expense Tracker helps you record and understand your spending. This '
          'policy explains what information the app handles and how it is used.',
    ),
    (
      'Data you enter',
      'Expenses, budgets and preferences you enter are stored only on your '
          'device in a local database. They are not uploaded to any server and '
          'no account is required.',
    ),
    (
      'Crash reports and analytics',
      'If enabled by the developer, the app uses Google Firebase Crashlytics '
          'and Firebase Analytics to collect anonymous crash reports and usage '
          'events (for example "expense added"). These never include the titles, '
          'notes or amounts of your expenses. Google processes this data under '
          'its own privacy policy.',
    ),
    (
      'Permissions',
      'The app only requests internet access, which is used for crash '
          'reporting, analytics and downloading fonts. It does not access your '
          'contacts, location, camera or files.',
    ),
    (
      'Deleting your data',
      'You can delete all expenses at any time from Settings → Delete all '
          'expenses. Uninstalling the app removes all data stored by it.',
    ),
    (
      'Children',
      'The app is not directed at children under 13 and does not knowingly '
          'collect information from them.',
    ),
    (
      'Changes',
      'This policy may be updated with new versions of the app. The date at '
          'the top shows when it last changed.',
    ),
    (
      'Contact',
      'For questions about this policy, use the developer contact details '
          'shown on the app\'s store listing.',
    ),
  ];
}
