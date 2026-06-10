import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/booking_provider.dart';
import '../providers/user_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.id;
    if (userId != null) {
      Future.microtask(() =>
          Provider.of<BookingProvider>(context, listen: false).fetchMyBookings(userId));
    }
  }

  void _cancelBooking(String bookingId) async {
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.id;
    if (userId == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    await Provider.of<BookingProvider>(context, listen: false).cancelBooking(userId, bookingId);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoadingBookings && bookingProvider.myBookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bookingProvider.myBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 80, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text('No upcoming bookings', style: GoogleFonts.outfit(fontSize: 20, color: Colors.white54)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookingProvider.myBookings.length,
            itemBuilder: (context, index) {
              final booking = bookingProvider.myBookings[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.sports, color: Theme.of(context).primaryColor, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.venue?.name ?? 'Venue ${booking.venueId}',
                              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${booking.date} • ${booking.startTime}',
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                        onPressed: () => _cancelBooking(booking.id),
                        tooltip: 'Cancel Booking',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
