import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rating_service.dart';
import '../auth/auth_service.dart';
import '../models/rating.dart';

class RatingScreen extends StatefulWidget {
  final String jobId;
  final String toUserId;
  final String toUserName;
  final String role;

  const RatingScreen({
    super.key,
    required this.jobId,
    required this.toUserId,
    required this.toUserName,
    required this.role,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate ${widget.toUserName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'How was your experience with ${widget.toUserName}?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Add comment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _rating == 0 ? null : _submitRating,
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    final ratingService = Provider.of<RatingService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    final rating = Rating(
      id: '${widget.jobId}_${authService.currentUser!.uid}',
      fromUserId: authService.currentUser!.uid,
      toUserId: widget.toUserId,
      jobId: widget.jobId,
      stars: _rating,
      comment: _commentController.text,
      createdAt: DateTime.now(),
      role: widget.role,
    );

    try {
      await ratingService.submitRating(rating);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit rating: $e')));
    }
  }
}
