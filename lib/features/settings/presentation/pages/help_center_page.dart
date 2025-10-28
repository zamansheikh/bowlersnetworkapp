import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/colors.dart';
import '../../../safety/presentation/widgets/report_dialog.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Center'),
        elevation: 0,
        backgroundColor: AppColors.primaryLimeGreen,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLimeGreen,
                    AppColors.primaryLimeGreen.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🛡️ Safety First',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your safety and our community safety is our top priority',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Report Section
            _buildSectionCard(
              context: context,
              title: '🚨 Report a Concern',
              description:
                  'Report inappropriate content, harassment, or child safety concerns',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => ReportDialog(
                    reportedUserId: 'anonymous',
                    onReportSubmitted: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 12.h),

            // Contact Section
            _buildSectionCard(
              context: context,
              title: '📧 Contact Safety Team',
              description:
                  'Email: jay@jmarentertainment.com\n\nResponse time: 24 hours or less',
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'jay@jmarentertainment.com',
                  queryParameters: {'subject': 'BowlersNetwork Safety Concern'},
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
            ),

            SizedBox(height: 24.h),

            // Safety Tips
            Text(
              'Safety Tips',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            _buildTipCard(
              icon: '🚫',
              title: 'Never Share Personal Information',
              description:
                  'Don\'t share phone numbers, addresses, or financial details',
            ),
            _buildTipCard(
              icon: '🔐',
              title: 'Use Strong Passwords',
              description: 'Keep your account secure with a unique password',
            ),
            _buildTipCard(
              icon: '🔔',
              title: 'Trust Your Instincts',
              description: 'If something feels wrong, report it immediately',
            ),
            _buildTipCard(
              icon: '👨‍👩‍👧‍👦',
              title: 'Talk to Trusted Adults',
              description:
                  'Always discuss online safety with parents or guardians',
            ),

            SizedBox(height: 24.h),

            // Helpful Resources
            Text(
              'Helpful Resources',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            _buildResourceTile(
              title: 'NCMEC - CyberTipline',
              url: 'https://www.cybertipline.org/',
            ),
            _buildResourceTile(
              title: 'Common Sense Media',
              url: 'https://www.commonsensemedia.org/',
            ),
            _buildResourceTile(title: 'FBI Tips', url: 'https://tips.fbi.gov/'),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTile({required String title, required String url}) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            Icon(Icons.open_in_new, color: Colors.blue, size: 18.sp),
          ],
        ),
      ),
    );
  }
}
