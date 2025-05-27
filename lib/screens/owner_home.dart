import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rating_service.dart';
import '../screens/rating_screen.dart';
import '../models/user_model.dart';
import 'ratings_list_screen.dart'; // Add this import
import '../auth/auth_service.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  double _averageRating = 0.0;
  int _ratingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final ratingService = Provider.of<RatingService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    _averageRating = await ratingService.getAverageRating(
      authService.currentUser!.uid,
    );
    _ratingCount = await ratingService.getRatingCount(
      authService.currentUser!.uid,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:
                () =>
                    Provider.of<AuthService>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Rating Display
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Your Rating', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 30),
                      const SizedBox(width: 8),
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('($_ratingCount reviews)'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _viewAllRatings(),
                    child: const Text('View All Ratings'),
                  ),
                ],
              ),
            ),
          ),

          // Example job completion section
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Replace with actual completed jobs
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Completed Job ${index + 1}'),
                  trailing: ElevatedButton(
                    onPressed: () => _rateForeman(index),
                    child: const Text('Rate Foreman'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _viewAllRatings() {
    final authService = Provider.of<AuthService>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RatingsListScreen(userId: authService.currentUser!.uid),
      ),
    );
  }

  void _rateForeman(int jobIndex) {
    // In a real app, you'd get this from your jobs data
    const foremanId = 'foreman123';
    const foremanName = 'John Foreman';
    final jobId = 'job_$jobIndex'; // Added underscore for better readability

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RatingScreen(
              jobId: jobId,
              toUserId: foremanId,
              toUserName: foremanName,
              role: 'foreman',
            ),
      ),
    ).then((_) => _loadRatings());
  }
}
