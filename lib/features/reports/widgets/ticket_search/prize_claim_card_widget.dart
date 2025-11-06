import 'package:flutter/material.dart';
import '../../../../core/theme/color_scheme.dart';

/// --- Status ---------------------------------------------------------------

enum ClaimStatus { pending, approved, rejected, claimed }

ClaimStatus claimStatusFromApi(String raw) {
  switch (raw.trim().toUpperCase()) {
    case 'CLAIMED':
    case 'CLIAIMED': // typo-safe
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
      case ClaimStatus.pending:  return 'UNCLAIMED';
      case ClaimStatus.approved: return 'Approved';
      case ClaimStatus.rejected: return 'Rejected';
      case ClaimStatus.claimed:  return 'Claimed';
    }
  }

  Color get fg {
    switch (this) {
      case ClaimStatus.pending:  return Colors.amber;
      case ClaimStatus.approved: return AppTheme.adminGreen;
      case ClaimStatus.rejected: return Colors.redAccent;
      case ClaimStatus.claimed:  return Colors.blueAccent;
    }
  }

  Color get bg => fg.withOpacity(0.18);
}

/// --- Helpers --------------------------------------------------------------

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
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final dd = dt.day.toString().padLeft(2, '0');
    final mmm = months[dt.month - 1];
    final yyyy = dt.year.toString();
    return '$dd $mmm $yyyy';
  } catch (_) {
    return '-';
  }
}

/// --- Redesigned minimal card (with mobile) --------------------------------

class PrizeTicketCard extends StatelessWidget {
  final String luckySlno;     // LUCKY_SLNO
  final num prizeAmount;      // PRIZE_AMOUNT
  final String customerName;  // CUSTOMER_NAME
  final String customerMob;   // CUSTOMER_MOB  <-- NEW
  final String dateIso;       // DATE (ISO)
  final String claimStatus;   // CLAIM_STATUS

  const PrizeTicketCard({
    super.key,
    required this.luckySlno,
    required this.prizeAmount,
    required this.customerName,
    required this.customerMob,
    required this.dateIso,
    required this.claimStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = claimStatusFromApi(claimStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // subtle glassy look
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
        ),
        color: AppTheme.adminGreenDarker.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.adminWhite.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 10),
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
                  style: const TextStyle(
                    color: AppTheme.adminWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: status.bg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: status.fg.withOpacity(0.35)),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Prize
          Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, size: 18, color: AppTheme.adminWhite),
              const SizedBox(width: 8),
              Text(
                formatInr(prizeAmount),
                style: const TextStyle(
                  color: AppTheme.adminGreen,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Customer name
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 18, color: AppTheme.adminWhite),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.adminWhite,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Mobile
          Row(
            children: [
              const Icon(Icons.phone_iphone_outlined, size: 18, color: AppTheme.adminWhite),
              const SizedBox(width: 8),
              Text(
                customerMob,
                style: TextStyle(
                  color: AppTheme.adminWhite.withOpacity(0.90),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Date
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 18, color: AppTheme.adminWhite),
              const SizedBox(width: 8),
              Text(
                formatDateDdMmmYyyy(dateIso),
                style: TextStyle(
                  color: AppTheme.adminWhite.withOpacity(0.85),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
