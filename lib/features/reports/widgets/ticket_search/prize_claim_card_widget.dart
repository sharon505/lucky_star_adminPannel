import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/color_scheme.dart';

enum ClaimStatus { pending, approved, rejected, claimed }

ClaimStatus claimStatusFromApi(String raw) {
  switch (raw.trim().toUpperCase()) {
    case 'CLAIMED':
    case 'CLIAIMED':
      return ClaimStatus.claimed;
    case 'APPROVED':
      return ClaimStatus.approved;
    case 'REJECTED':
      return ClaimStatus.rejected;
    case 'PENDING':
    default:
      return ClaimStatus.pending;
  }
}

extension ClaimStatusStyle on ClaimStatus {
  String get label {
    switch (this) {
      case ClaimStatus.pending:
        return 'UNCLAIMED';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.claimed:
        return 'Claimed';
    }
  }

  Color get fg {
    switch (this) {
      case ClaimStatus.pending:
        return Colors.amber;
      case ClaimStatus.approved:
        return AppTheme.adminGreen;
      case ClaimStatus.rejected:
        return Colors.redAccent;
      case ClaimStatus.claimed:
        return Colors.blueAccent;
    }
  }

  Color get bg => fg.withOpacity(0.18);
}

String formatInr(num v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final decPart = parts[1];

  if (intPart.length <= 3) return '₹$intPart.$decPart';

  final last3 = intPart.substring(intPart.length - 3);
  String head = intPart.substring(0, intPart.length - 3);

  final chunks = <String>[];
  while (head.length > 2) {
    chunks.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) chunks.insert(0, head);

  final prefix = chunks.join(',');
  return '₹$prefix,$last3.$decPart';
}

String formatDateDdMmmYyyy(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    final dt = DateTime.parse(iso);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dd = dt.day.toString().padLeft(2, '0');
    final mmm = months[dt.month - 1];
    final yyyy = dt.year.toString();
    return '$dd $mmm $yyyy';
  } catch (_) {
    return '-';
  }
}

class PrizeTicketCard extends StatelessWidget {
  final String luckySlno;     // LUCKY_SLNO
  final num prizeAmount;      // PRIZE_AMOUNT
  final String customerName;  // CUSTOMER_NAME
  final String customerMob;   // CUSTOMER_MOB
  final String dateIso;       // DATE (ISO)
  final String claimStatus;   // CLAIM_STATUS

  // NEW (optional)
  final String? agentName;    // AGENT
  final String? claimedOnIso; // CLAIMED_ON (ISO or "yyyy-MM-dd hh:mm:ss a")

  const PrizeTicketCard({
    super.key,
    required this.luckySlno,
    required this.prizeAmount,
    required this.customerName,
    required this.customerMob,
    required this.dateIso,
    required this.claimStatus,
    this.agentName,
    this.claimedOnIso,
  });

  @override
  Widget build(BuildContext context) {
    final status = claimStatusFromApi(claimStatus);

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
          stops: [0, 1],
        ),
        color: AppTheme.adminGreenDarker.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.adminWhite.withOpacity(0.14), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + status
          Row(
            children: [
              Expanded(
                child: Text(
                  luckySlno,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.adminWhite,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: status.bg,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: status.fg.withOpacity(0.35), width: 1.w),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Prize
          Row(
            children: [
              Icon(Icons.card_giftcard_rounded, size: 18.sp, color: AppTheme.adminWhite),
              SizedBox(width: 8.w),
              Text(
                formatInr(prizeAmount),
                style: TextStyle(
                  color: AppTheme.adminGreen,
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Customer name
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 18.sp, color: AppTheme.adminWhite),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.adminWhite,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Mobile
          Row(
            children: [
              Icon(Icons.phone_iphone_outlined, size: 18.sp, color: AppTheme.adminWhite),
              SizedBox(width: 8.w),
              Text(
                customerMob,
                style: TextStyle(
                  color: AppTheme.adminWhite.withOpacity(0.90),
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Date
          Row(
            children: [
              Icon(Icons.event_outlined, size: 18.sp, color: AppTheme.adminWhite),
              SizedBox(width: 8.w),
              Text(
                formatDateDdMmmYyyy(dateIso),
                style: TextStyle(
                  color: AppTheme.adminWhite.withOpacity(0.85),
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Agent (NEW)
          if (agentName != null && agentName!.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.badge_rounded, size: 18.sp, color: AppTheme.adminWhite),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    agentName!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.adminWhite.withOpacity(.90),
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Claimed On (NEW)
          if (claimedOnIso != null && claimedOnIso!.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 18.sp, color: AppTheme.adminWhite),
                SizedBox(width: 8.w),
                Text(
                  _formatClaimedOnTimeExact(claimedOnIso!), // ← exact time shown
                  style: TextStyle(
                    color: AppTheme.adminWhite.withOpacity(0.85),
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

        ],
      ),
    );
  }

  /// Formats ISO or "yyyy-MM-dd hh:mm:ss a" into "dd MMM yyyy, HH:mm"
  // Use this for the "Claimed On" time display
  String _formatClaimedOnTimeExact(String raw) {
    final s = raw.trim();

    // Case 1: already like "yyyy-MM-dd HH:mm:ss AM/PM" → extract the time part exactly
    final r12 = RegExp(r'\b(\d{2}):(\d{2}):(\d{2})\s?(AM|PM)\b', caseSensitive: false);
    final m12 = r12.firstMatch(s);
    if (m12 != null) {
      final hh = m12.group(1)!;
      final mm = m12.group(2)!;
      final ss = m12.group(3)!;
      final ap = m12.group(4)!.toUpperCase();
      return '$hh:$mm:$ss $ap';
    }

    // Case 2: ISO → convert to 12h with seconds and AM/PM
    final dt = DateTime.tryParse(s);
    if (dt != null) {
      var h = dt.hour;
      final ap = (h >= 12) ? 'PM' : 'AM';
      h = h % 12; if (h == 0) h = 12;
      final hh = h.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      final ss = dt.second.toString().padLeft(2, '0');
      return '$hh:$mm:$ss $ap';
    }

    // Fallback: show raw
    return s;
  }

}

