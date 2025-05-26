import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rating_service.dart';
import '../auth/auth_service.dart';
import 'ratings_list_screen.dart';

class ForemanHome extends StatefulWidget {
  const ForemanHome({super.key});

  @override
  State<ForemanHome> createState() => _ForemanHomeState();
}

class _ForemanHomeState extends State<ForemanHome> {
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
        title: const Text('Foreman Dashboard'),
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
                    onPressed: _viewAllRatings,
                    child: const Text('View All Ratings'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Completed Job ${index + 1}'),
                  trailing: ElevatedButton(
                    onPressed: () => _rateWorkshopOwner(index),
                    child: const Text('Rate Owner'),
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

  void _rateWorkshopOwner(int jobIndex) {
    final jobId =
        'job$jobIndex'; // Remove const since it's not a constant expression
    const ownerId = 'owner123';
    const ownerName = 'Workshop Owner';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RatingScreen(
              jobId: jobId,
              toUserId: ownerId,
              toUserName: ownerName,
              role: 'owner',
            ),
      ),
    ).then((_) => _loadRatings());
  }
}
