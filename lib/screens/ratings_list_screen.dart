import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rating_service.dart';
import '../models/rating.dart';

class RatingsListScreen extends StatelessWidget {
  final String userId;

  const RatingsListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ratingService = Provider.of<RatingService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Ratings')),
      body: StreamBuilder<List<Rating>>(
        stream: ratingService.getRatingsForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No ratings yet'));
          }

          final ratings = snapshot.data!;
          return ListView.builder(
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              final rating = ratings[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber[100],
                    child: Text(
                      rating.stars.toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  title: Text(rating.comment.isNotEmpty 
                      ? rating.comment 
                      : 'No comment provided'),
                  subtitle: Text(
                    'From ${rating.role == 'foreman' ? 'Foreman' : 'Workshop Owner'} • '
                    '${rating.createdAt.toString().substring(0, 10)}',
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