import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/my_tasks_screen/my_tasks_screen.dart';
import '../presentation/create_task_screen/create_task_screen.dart';
import '../presentation/task_detail_screen/task_detail_screen.dart';
import '../presentation/sent_tasks_screen/sent_tasks_screen.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/signup_screen/signup_screen.dart';
import '../presentation/user_search_screen/user_search_screen.dart';
import '../presentation/connection_requests_screen/connection_requests_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String myTasksScreen = '/my-tasks-screen';
  static const String createTaskScreen = '/create-task-screen';
  static const String taskDetailScreen = '/task-detail-screen';
  static const String sentTasksScreen = '/sent-tasks-screen';
  static const String userProfileScreen = '/user-profile-screen';
  static const String loginScreen = '/login-screen';
  static const String signupScreen = '/signup-screen';
  static const String userSearchScreen = '/user-search-screen';
  static const String connectionRequestsScreen = '/connection-requests-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => SplashScreen(),
    splashScreen: (context) => SplashScreen(),
    homeDashboard: (context) => HomeDashboard(),
    myTasksScreen: (context) => MyTasksScreen(),
    createTaskScreen: (context) => CreateTaskScreen(),
    taskDetailScreen: (context) => TaskDetailScreen(),
    sentTasksScreen: (context) => SentTasksScreen(),
    userProfileScreen: (context) => UserProfileScreen(),
    loginScreen: (context) => LoginScreen(),
    signupScreen: (context) => SignupScreen(),
    userSearchScreen: (context) => UserSearchScreen(),
    connectionRequestsScreen: (context) => ConnectionRequestsScreen(),
    // TODO: Add your other routes here
  };
}
