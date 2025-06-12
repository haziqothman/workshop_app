import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rating_service.dart';
import '../auth/auth_service.dart';
import 'ratings_list_screen.dart';
import 'rating_screen.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  double _averageRating = 0.0;
  int _ratingCount = 0;
  int _totalJobsCompleted = 0;
  double _averageJobCompletionTime = 2.5;
  final List<Map<String, dynamic>> _completedJobs = [
    {
      'id': 'job1',
      'title': 'Tukar Minyak Hitam',
      'date': '15 Jan 2023',
      'foreman': 'Ali Bin Abu',
      'foremanId': 'foreman001',
      'completionTime': 2,
    },
    {
      'id': 'job2',
      'title': 'Servis Brek',
      'date': '22 Feb 2023',
      'foreman': 'Ahmad Bin Hassan',
      'foremanId': 'foreman002',
      'completionTime': 3,
    },
    {
      'id': 'job3',
      'title': 'Baiki Enjin',
      'date': '5 Mac 2023',
      'foreman': 'Siti Binti Rahman',
      'foremanId': 'foreman003',
      'completionTime': 4,
    },
    {
      'id': 'job4',
      'title': 'Tukar Tayar',
      'date': '18 Apr 2023',
      'foreman': 'Muthu A/L Kumar',
      'foremanId': 'foreman004',
      'completionTime': 1,
    },
    {
      'id': 'job5',
      'title': 'Servis Penghawa Dingin',
      'date': '2 Mei 2023',
      'foreman': 'Tan Ah Kow',
      'foremanId': 'foreman005',
      'completionTime': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRatings();
    _totalJobsCompleted = _completedJobs.length;
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop Owner Dashboard'),
        centerTitle: true,
        elevation: 2,
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
          // Performance Metrics Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Workshop Performance',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        label: Text(
                          'Owner',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPerformanceStat(
                        'Avg Rating',
                        _averageRating.toStringAsFixed(1),
                        Icons.star,
                        Colors.amber,
                      ),
                      _buildPerformanceStat(
                        'Total Ratings',
                        _ratingCount.toString(),
                        Icons.reviews,
                        theme.colorScheme.primary,
                      ),
                      _buildPerformanceStat(
                        'Jobs Completed',
                        _totalJobsCompleted.toString(),
                        Icons.work_history,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPerformanceStat(
                        'Avg Completion',
                        '${_averageJobCompletionTime} days',
                        Icons.timer,
                        Colors.blue,
                      ),
                      _buildPerformanceStat(
                        'Active Foremen',
                        '${_completedJobs.map((j) => j['foremanId']).toSet().length}',
                        Icons.people,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: _viewAllRatings,
                    child: const Text('View All Workshop Ratings'),
                  ),
                ],
              ),
            ),
          ),

          // Recent Jobs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Jobs',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_completedJobs.length} Jobs',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _completedJobs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final job = _completedJobs[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              job['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${job['completionTime']} days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Foreman: ${job['foreman']}',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          job['date'],
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.star_rate_rounded, size: 18),
                            label: const Text('Rate This Foreman'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: theme.colorScheme.onSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _rateForeman(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _viewAllRatings() {
    final authService = Provider.of<AuthService>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RatingsListScreen(
              userId: authService.currentUser!.uid,
              showReceivedRatings: true,
              isOwnerView: true, // This enables the delete functionality
            ),
      ),
    );
  }

  void _rateForeman(int jobIndex) {
    final job = _completedJobs[jobIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RatingScreen(
              jobId: job['id'],
              ratedUserId: job['foremanId'],
              ratedUserName: job['foreman'],
              role: 'foreman',
              jobTitle: job['title'],
            ),
      ),
    ).then((_) => _loadRatings());
  }
}
