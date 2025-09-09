import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      drawer: const AppDrawer(),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryLimeGreen,
              ),
            );
          } else if (state is HomeLoaded) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports,
                    size: 100,
                    color: AppColors.primaryLimeGreen,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome to Bowlers Network!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLimeGreen,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your bowling community awaits',
                    style: TextStyle(fontSize: 16, color: AppColors.darkGray),
                  ),
                ],
              ),
            );
          } else if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(LoadHome());
                    },
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          // Initial state
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports,
                  size: 100,
                  color: AppColors.primaryLimeGreen,
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome to Bowlers Network!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLimeGreen,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your bowling community awaits',
                  style: TextStyle(fontSize: 16, color: AppColors.darkGray),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<HomeBloc>().add(LoadHome());
        },
        backgroundColor: AppColors.primaryLimeGreen,
        child: const Icon(Icons.refresh, color: AppColors.white),
      ),
    );
  }
}
