import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          if (bookingProvider.isLoadingBookings) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bookingProvider.myBookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }
          return ListView.builder(
            itemCount: bookingProvider.myBookings.length,
            itemBuilder: (context, index) {
              final booking = bookingProvider.myBookings[index];
              return Card(
                child: ListTile(
                  title: Text(booking.venue?.name ?? 'Venue ${booking.venueId}'),
                  subtitle: Text(
                    '${booking.date} at ${booking.startTime}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _cancelBooking(booking.id),
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
