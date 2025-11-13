import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../../core/constants/colors.dart';
import '../../data/models/report_model.dart';

class ReportDialog extends StatefulWidget {
  final String reportedUserId;
  final String? reportedPostId;
  final String? reportedMessageId;
  final VoidCallback? onReportSubmitted;

  const ReportDialog({
    super.key,
    required this.reportedUserId,
    this.reportedPostId,
    this.reportedMessageId,
    this.onReportSubmitted,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_selectedReason == null) {
      Fluttertoast.showToast(
        msg: 'Please select a reason',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Call reportRepository to submit report when backend is ready

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Fluttertoast.showToast(
          msg:
              'Report submitted. Thank you for keeping BowlersNetwork safe 🛡️',
          backgroundColor: Colors.green,
        );
        widget.onReportSubmitted?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to submit report. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.flag, color: Colors.red, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Content',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Help us keep BowlersNetwork safe',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Reason Selection
              Text(
                'What\'s the problem?',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),

              // Reason Options
              ...reportReasons.map((reason) => _buildReasonTile(reason)),

              SizedBox(height: 20.h),

              // Description
              Text(
                'Additional Details (Optional)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Provide more context...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),

              SizedBox(height: 20.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Submit Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Help Info
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Reports are reviewed within 24 hours',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonTile(ReportReason reason) {
    final isSelected = _selectedReason == reason.key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason.key;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryLimeGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: isSelected
              ? AppColors.primaryLimeGreen.withValues(alpha: 00.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(reason.icon, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    reason.description,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryLimeGreen,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }
}
