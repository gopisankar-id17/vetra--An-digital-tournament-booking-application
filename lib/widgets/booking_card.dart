import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../utils/app_theme.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancelBooking;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancelBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Booking ID row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status.name.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // Booking ID
                  Text(
                    'Booking ID: ${booking.id}',
                    style: const TextStyle(
                      color: AppTheme.textMediumColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tournament name
              Text(
                booking.tournamentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDarkColor,
                ),
              ),

              const SizedBox(height: 8),

              // Booking date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: AppTheme.textMediumColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Booked on: ${_formatDate(booking.bookingDate)}',
                    style: const TextStyle(
                      color: AppTheme.textMediumColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Receipt ID if available
              if (booking.receiptId != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.receipt,
                      size: 16,
                      color: AppTheme.textMediumColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Receipt: ${booking.receiptId}',
                      style: const TextStyle(
                        color: AppTheme.textMediumColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Amount paid
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    size: 16,
                    color: AppTheme.textMediumColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Amount: ₹${booking.amountPaid.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.textMediumColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Notes if available
              if (booking.notes != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.textLightColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    booking.notes!,
                    style: const TextStyle(
                      color: AppTheme.textMediumColor,
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],

              // Action buttons based on booking status
              if (booking.status == BookingStatus.pending ||
                  booking.status == BookingStatus.confirmed) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // View details button
                    OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Cancel booking button
                    if (onCancelBooking != null)
                      OutlinedButton.icon(
                        onPressed: onCancelBooking,
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (booking.status) {
      case BookingStatus.pending:
        return AppTheme.warningColor;
      case BookingStatus.confirmed:
        return AppTheme.infoColor;
      case BookingStatus.active:
        return AppTheme.secondaryColor;
      case BookingStatus.completed:
        return AppTheme.successColor;
      case BookingStatus.cancelled:
        return AppTheme.errorColor;
      case BookingStatus.refunded:
        return AppTheme.textMediumColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
