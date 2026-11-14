
import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'features/home/screens/home_screen.dart';

class HoodVoiceApp extends StatelessWidget {
  const HoodVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HoodVoice Cartagena',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.lightGray,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
          secondary: AppColors.yellow,
          surface: AppColors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          centerTitle: false,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: AppColors.navy),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
