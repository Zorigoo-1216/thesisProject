import 'package:flutter/material.dart';
import '../screens/start/splash_screen.dart';
import '../screens/start/start_screen.dart';
import '../screens/start/login_screen.dart';
import '../screens/start/register_screen.dart';

import '../screens/main/employer_screen.dart';
//import '../screens/main/home_screen.dart';
import '../screens/main/job_detail_screen.dart';
import '../screens/main/job_filter_sheet_screen.dart';
import '../screens/main/job_request_screen.dart';
import '../screens/main/joblist_screen.dart';
import '../screens/main/job_contract_screen.dart';
// Add other imports...
import '../screens/main/main_wrapper.dart';
import '../screens/main/rate_employee_screen.dart';
import '../screens/main/work_progress_screen.dart';
import '../screens/main/employee_contract_screen.dart';
import '../screens/main/employee_work_progress_screen.dart';
import '../screens/main/employee_payment_screen.dart';
import '../screens/main/employer_rate_screen.dart';
//import '../screens/main/profile_screen.dart';
import '../screens/main/profile_detail_screen.dart';
import '../screens/main/job_histoty_screen.dart';
import '../screens/main/created_job_history.dart';
import '../screens/main/contract_history_screen.dart';
import '../screens/main/sent_application_history.dart';
import '../screens/main/notification_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/splash': (context) => const SplashScreen(),
    '/start': (context) => const StartScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    // Bottom Navigation Wrapper
    '/home': (context) => const MainWrapper(),

    '/employer': (context) => const EmployerScreen(),
    '/job-detail': (context) => const JobDetailScreen(),
    '/job-filter-sheet': (context) => const JobFilterSheet(),
    //'/job-request': (context) => const JobRequestScreen(),
    '/job-list-screen': (context) => const JobListScreen(),

    '/suitable-workers': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == null || !(args is Map) || !args.containsKey('jobId')) {
        debugPrint("Invalid args: $args");
        return const Scaffold(body: Center(child: Text("Invalid Job ID")));
      }
      return JobRequestScreen(
        initialTabIndex: 0,
        jobId: args['jobId'].toString(),
        hasInterview: args['hasInterview'] ?? false,
        // Ensure jobId is a String
      );
    },

    '/job-request': (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is! Map<String, dynamic> || !args.containsKey('jobId')) {
        debugPrint("❌ /job-request route: invalid or missing arguments");
        return const Scaffold(body: Center(child: Text("Invalid job ID")));
      }
      return JobRequestScreen(
        initialTabIndex: 1,
        jobId: args['jobId'],
        hasInterview: false,
      );
    },
    '/interview': (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is! Map<String, dynamic> || !args.containsKey('jobId')) {
        debugPrint("❌ /interview route: invalid or missing arguments");
        return const Scaffold(body: Center(child: Text("Invalid job ID")));
      }
      return JobRequestScreen(
        initialTabIndex: 2,
        jobId: args['jobId'],
        hasInterview: args['hasInterview'] ?? false,
      );
    },

    '/contract-candidates': (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is! Map<String, dynamic> || !args.containsKey('jobId')) {
        debugPrint(
          "❌ /contract-candidates route: invalid or missing arguments",
        );
        return const Scaffold(body: Center(child: Text("Invalid job ID")));
      }
      return JobRequestScreen(
        initialTabIndex: 3,
        jobId: args['jobId'],
        hasInterview: args['hasInterview'] ?? false,
      );
    },

    '/job-contract': (context) => const JobContractScreen(initialTabIndex: 0),
    '/contract-employees':
        (context) => const JobContractScreen(initialTabIndex: 1),
    '/rate-employee': (context) => const RateEmployeeScreen(),
    '/job-progress': (context) => const WorkProgressScreen(initialTabIndex: 1),
    '/job-employees': (context) => const WorkProgressScreen(initialTabIndex: 0),
    '/job-payment': (context) => const WorkProgressScreen(initialTabIndex: 2),

    // main.dart or routes.dart
    '/employee-contract': (context) => const EmployeeContractScreen(),
    '/employee-progress': (context) => const EmployeeWorkProgressScreen(),
    '/employee-payment': (context) => const EmployeePaymentScreen(),
    '/employer-rate': (context) => const EmployerRateScreen(),

    '/profile-detail': (context) => const ProfileDetailScreen(),
    '/job-history': (context) => const JobHistoryScreen(),
    '/created-job-history': (context) => const CreatedJobHistoryScreen(),
    '/contract-history': (context) => const ContractHistoryScreen(),
    '/sent-applicaiton-history':
        (context) => const SentApplicationHistoryScreen(),
    '/notification': (context) => const NotificationScreen(),
  };
}
