import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/venue_provider.dart';
import '../providers/user_provider.dart';
import 'venue_detail_screen.dart';
import 'my_bookings_screen.dart';
import 'login_screen.dart';

class VenueListScreen extends StatefulWidget {
  const VenueListScreen({Key? key}) : super(key: key);

  @override
  _VenueListScreenState createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<VenueProvider>(context, listen: false).fetchVenues());
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_online),
            tooltip: 'My Bookings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              userProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Consumer<VenueProvider>(
        builder: (context, venueProvider, child) {
          if (venueProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (venueProvider.venues.isEmpty) {
            return const Center(child: Text('No venues available.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: venueProvider.venues.length,
            itemBuilder: (context, index) {
              final venue = venueProvider.venues[index];
              return Card(
                child: ListTile(
                  leading: Image.network(
                    venue.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(venue.name),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VenueDetailScreen(venue: venue),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
