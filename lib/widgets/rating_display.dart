import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rating_service.dart';

class RatingDisplay extends StatelessWidget {
  final String userId;

  const RatingDisplay({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ratingService = Provider.of<RatingService>(context);

    return FutureBuilder<double>(
      future: ratingService.getAverageRating(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final averageRating = snapshot.data ?? 0.0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              averageRating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 4),
            Text(
              '(${ratingService.getRatingCount(userId)})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
