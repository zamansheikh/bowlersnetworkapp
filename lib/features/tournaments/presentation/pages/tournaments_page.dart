import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/tournament.dart';
import '../bloc/tournament_cubit.dart';
import '../bloc/tournament_state.dart';
import '../widgets/tournament_card.dart';
import '../widgets/tournament_filter_bottom_sheet.dart';
import '../widgets/create_tournament_bottom_sheet.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _tabs = ['All Tournament', 'Registered', 'Available'];

  @override
  void initState() {
    super.initState();
    context.read<TournamentCubit>().loadTournaments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<TournamentCubit>().refreshTournaments(),
                color: AppColors.primaryLimeGreen,
                child: BlocConsumer<TournamentCubit, TournamentState>(
                  listener: (context, state) {
                    if (state is TournamentError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    } else if (state is TournamentRegistrationSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.wasRegistered
                                ? 'Successfully registered for ${state.tournament.name}'
                                : 'Successfully unregistered from ${state.tournament.name}',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is TournamentLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryLimeGreen,
                        ),
                      );
                    }

                    if (state is TournamentError) {
                      return _buildErrorState(state);
                    }

                    if (state is TournamentLoaded) {
                      return _buildContent(state);
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTournamentBottomSheet,
        backgroundColor: AppColors.primaryLimeGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                size: 20,
                color: AppColors.gray700,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Tournaments',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TournamentLoaded state) {
    return Column(
      children: [
        // Search and Filter Section
        _buildSearchAndFilter(state),

        // Tabs Section
        _buildTabs(state),

        // Content Section
        Expanded(
          child: state.filteredTournaments.isEmpty
              ? _buildEmptyState(state)
              : _buildTournamentsList(state),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(TournamentLoaded state) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<TournamentCubit>().updateSearchTerm(value);
                  },
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search tournaments...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray500,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.gray500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.gray300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.gray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryLimeGreen,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => _showFilterBottomSheet(state),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLimeGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          if (state.selectedFormats.isNotEmpty ||
              state.selectedAccessLevels.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            _buildActiveFilters(state),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilters(TournamentLoaded state) {
    final activeFilters = <String>[];
    activeFilters.addAll(state.selectedFormats);
    activeFilters.addAll(state.selectedAccessLevels);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...activeFilters.map((filter) => _buildFilterChip(filter)),
        GestureDetector(
          onTap: () => context.read<TournamentCubit>().resetFilters(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.clear, size: 16, color: AppColors.gray700),
                SizedBox(width: 4),
                Text(
                  'Clear All',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLimeGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLimeGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            filter,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryLimeGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              // Remove this specific filter
              final cubit = context.read<TournamentCubit>();
              if (['Singles', 'Doubles', 'Teams'].contains(filter)) {
                cubit.toggleFormatFilter(filter);
              } else {
                cubit.toggleAccessLevelFilter(filter);
              }
            },
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.primaryLimeGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(TournamentLoaded state) {
    return Container(
      height: 60.h,
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: _tabs
              .map((tab) => _buildTabItem(tab, state.activeTab))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTabItem(String tab, String activeTab) {
    final isActive = tab == activeTab;

    return GestureDetector(
      onTap: () => context.read<TournamentCubit>().setActiveTab(tab),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLimeGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isActive ? AppColors.primaryLimeGreen : AppColors.gray400,
            width: 2,
          ),
        ),
        child: Text(
          tab,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? AppColors.white : AppColors.gray600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentsList(TournamentLoaded state) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: state.filteredTournaments.length,
      itemBuilder: (context, index) {
        final tournament = state.filteredTournaments[index];

        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: TournamentCard(
            tournament: tournament,
            onTap: () => _navigateToTournamentDetail(tournament),
            onRegister: () => _handleRegistration(tournament),
            isRegistering: false, // We'll handle this in the cubit
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(TournamentLoaded state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 40,
                color: AppColors.gray400,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              state.searchTerm.isNotEmpty ||
                      state.selectedFormats.isNotEmpty ||
                      state.selectedAccessLevels.isNotEmpty
                  ? 'No tournaments match your filters'
                  : state.activeTab == 'Registered'
                  ? 'No registered tournaments'
                  : state.activeTab == 'Available'
                  ? 'No available tournaments'
                  : 'No tournaments available',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              state.searchTerm.isNotEmpty ||
                      state.selectedFormats.isNotEmpty ||
                      state.selectedAccessLevels.isNotEmpty
                  ? 'Try adjusting your filters'
                  : 'Check back later for new tournaments',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(TournamentError state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            CustomButton(
              text: 'Retry',
              onPressed: () =>
                  context.read<TournamentCubit>().loadTournaments(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(TournamentLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TournamentFilterBottomSheet(state: state),
    );
  }

  void _showCreateTournamentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateTournamentBottomSheet(),
    );
  }

  void _navigateToTournamentDetail(Tournament tournament) {
    context.push('/tournaments/${tournament.id}', extra: tournament);
  }

  void _handleRegistration(Tournament tournament) {
    context.read<TournamentCubit>().handleTournamentRegistration(tournament);
  }
}
