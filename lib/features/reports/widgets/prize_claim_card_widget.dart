import 'package:flutter/material.dart';
import '../../../core/theme/color_scheme.dart';

enum ClaimStatus { pending, approved, rejected, claimed }

extension ClaimStatusX on ClaimStatus {
  String get label {
    switch (this) {
      case ClaimStatus.pending:  return 'Pending';
      case ClaimStatus.approved: return 'Approved';
      case ClaimStatus.rejected: return 'Rejected';
      case ClaimStatus.claimed:  return 'Claimed';
    }
  }

  /// Chip background color
  Color bg() {
    switch (this) {
      case ClaimStatus.pending:  return Colors.amber.withOpacity(0.18);
      case ClaimStatus.approved: return AppTheme.adminGreen.withOpacity(0.20);
      case ClaimStatus.rejected: return Colors.redAccent.withOpacity(0.20);
      case ClaimStatus.claimed:  return Colors.blueAccent.withOpacity(0.20);
    }
  }

  /// Chip text color
  Color fg() {
    switch (this) {
      case ClaimStatus.pending:  return Colors.amber;
      case ClaimStatus.approved: return AppTheme.adminGreen;
      case ClaimStatus.rejected: return Colors.redAccent;
      case ClaimStatus.claimed:  return Colors.blueAccent;
    }
  }
}

/// A dashboard card showing SL No, Prize, Customer, and Claim Status.
class PrizeClaimCard extends StatelessWidget {
  final int slNo;
  final num prizeAmount;
  final String customerName;
  final ClaimStatus status;
  final VoidCallback? onTap;

  const PrizeClaimCard({
    super.key,
    required this.slNo,
    required this.prizeAmount,
    required this.customerName,
    required this.status,
    this.onTap,
  });

  String _formatCurrency(num v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Indian numbering (12,34,56,789)
    final buf = StringBuffer();
    int i = intPart.length;
    if (i > 3) {
      buf.write(intPart.substring(i - 3));
      i -= 3;
      while (i > 0) {
        final start = (i - 2) < 0 ? 0 : i - 2;
        buf.write(',${intPart.substring(start, i)}');
        i -= 2;
      }
      return '₹${buf.toString().split('').reversed.join()}'.split('').reversed.join() + '.$decPart';
    } else {
      return '₹$intPart.$decPart';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container
        (
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.adminGreenDarker,
              AppTheme.adminGreenDark,
              AppTheme.adminGreenLite,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.adminWhite.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SL No badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.adminWhite.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.adminWhite.withOpacity(0.18)),
              ),
              child: Text(
                'SL: $slNo',
                style: const TextStyle(
                  color: AppTheme.adminWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name
                  Text(
                    customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.adminWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Prize row
                  Row(
                    children: [
                      const Icon(Icons.card_giftcard_rounded,
                          size: 18, color: AppTheme.adminWhite),
                      const SizedBox(width: 6),
                      Text(
                        _formatCurrency(prizeAmount),
                        style: const TextStyle(
                          color: AppTheme.adminGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: status.bg(),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: status.fg().withOpacity(0.35)),
              ),
              child: Text(
                status.label,
                style: TextStyle(
                  color: status.fg(),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
