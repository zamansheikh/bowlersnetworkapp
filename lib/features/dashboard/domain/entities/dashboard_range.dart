/// Time-window selector used across all dashboard endpoints. Backend
/// accepts the lowercase token; we keep the days separately so the
/// charts can size their x-axis accordingly. Pro endpoints (`/api/pro/*`)
/// only accept 7d / 30d — `proSafeFallback` clamps a selection to a
/// pro-supported value.
enum DashboardRange {
  d7('7d', 7, 'Last 7 days'),
  d30('30d', 30, 'Last 30 days'),
  d90('90d', 90, 'Last 90 days'),
  d365('365d', 365, 'Last year');

  const DashboardRange(this.wire, this.days, this.label);

  final String wire;
  final int days;
  final String label;

  /// Pro endpoints reject 90d/365d. Fall back to 30d for those so the
  /// shared selector can be reused.
  DashboardRange proSafeFallback() {
    if (this == DashboardRange.d7 || this == DashboardRange.d30) return this;
    return DashboardRange.d30;
  }
}
