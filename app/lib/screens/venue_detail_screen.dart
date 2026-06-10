import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/venue.dart';
import '../models/slot.dart';
import '../providers/booking_provider.dart';
import '../providers/user_provider.dart';

class VenueDetailScreen extends StatefulWidget {
  final Venue venue;
  const VenueDetailScreen({Key? key, required this.venue}) : super(key: key);

  @override
  _VenueDetailScreenState createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchSlotsForDate(_selectedDate);
  }

  void _fetchSlotsForDate(DateTime date) {
    Future.microtask(() =>
        Provider.of<BookingProvider>(context, listen: false)
            .fetchSlots(widget.venue.id, date));
  }

  void _bookSlot(Slot slot) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    if (userProvider.currentUser == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await bookingProvider.bookSlot(
        userProvider.currentUser!.id,
        slot.id,
        widget.venue.id,
        _selectedDate,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slot booked successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmBooking(Slot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text('Book slot at ${DateFormat.jm().format(slot.startTime)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bookSlot(slot);
            },
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.venue.name)),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    _fetchSlotsForDate(date);
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat.E().format(date), style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                        Text(date.day.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, bookingProvider, child) {
                if (bookingProvider.isLoadingSlots) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (bookingProvider.slots.isEmpty) {
                  return const Center(child: Text('No slots available for this date.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: bookingProvider.slots.length,
                  itemBuilder: (context, index) {
                    final slot = bookingProvider.slots[index];
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slot.isBooked ? Colors.grey : Colors.green,
                      ),
                      onPressed: slot.isBooked ? null : () => _confirmBooking(slot),
                      child: Text(
                        DateFormat.jm().format(slot.startTime),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
