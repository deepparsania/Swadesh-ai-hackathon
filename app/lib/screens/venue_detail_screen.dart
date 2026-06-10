import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/venue.dart';
import '../models/slot.dart';
import '../providers/booking_provider.dart';
import '../providers/user_provider.dart';

class VenueDetailScreen extends StatefulWidget {
  final Venue venue;
  const VenueDetailScreen({super.key, required this.venue});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeOfDay;

  @override
  void initState() {
    super.initState();
    _fetchSlotsForDate(_selectedDate, _selectedTimeOfDay);
  }

  void _fetchSlotsForDate(DateTime date, String? timeOfDay) {
    Future.microtask(() =>
        Provider.of<BookingProvider>(context, listen: false)
            .fetchSlots(widget.venue.id, date, timeOfDay));
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
        widget.venue.id,
        _selectedDate,
        slot.startTime,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Slot booked successfully!', style: GoogleFonts.inter()),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.inter()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _confirmBooking(Slot slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Confirm Booking',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Do you want to book the slot at ${slot.startTime} on ${DateFormat.MMMd().format(_selectedDate)}?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _bookSlot(slot);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.venue.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.venue.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, const Color(0xFF0F172A).withOpacity(0.9)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white54, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.venue.location ?? 'Location unknown',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Select Date', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: 14,
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDate = date);
                          _fetchSlotsForDate(date, _selectedTimeOfDay);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(colors: [Theme.of(context).primaryColor, const Color(0xFF2563EB)])
                                : null,
                            color: isSelected ? null : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? Colors.transparent : Colors.white12),
                            boxShadow: isSelected
                                ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(DateFormat.E().format(date).toUpperCase(), style: GoogleFonts.inter(color: isSelected ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(date.day.toString(), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text('Filter Time', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _buildFilterChip('All', null),
                      _buildFilterChip('Morning', 'morning'),
                      _buildFilterChip('Afternoon', 'afternoon'),
                      _buildFilterChip('Evening', 'evening'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Consumer<BookingProvider>(
            builder: (context, bookingProvider, child) {
              if (bookingProvider.isLoadingSlots) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (bookingProvider.slots.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text('No slots available.', style: GoogleFonts.inter(color: Colors.white54))),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final slot = bookingProvider.slots[index];
                      final isBooked = slot.status == 'booked';
                      return InkWell(
                        onTap: isBooked ? null : () => _confirmBooking(slot),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isBooked ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isBooked ? Colors.white12 : Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            slot.startTime,
                            style: GoogleFonts.inter(
                              color: isBooked ? Colors.white38 : Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: isBooked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: bookingProvider.slots.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedTimeOfDay == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        selected: isSelected,
        selectedColor: Theme.of(context).primaryColor,
        checkmarkColor: Colors.white,
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : Colors.white12)),
        onSelected: (selected) {
          setState(() => _selectedTimeOfDay = selected ? value : null);
          _fetchSlotsForDate(_selectedDate, _selectedTimeOfDay);
        },
      ),
    );
  }
}
