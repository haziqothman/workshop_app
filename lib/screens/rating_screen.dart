import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rating_service.dart';
import '../auth/auth_service.dart';
import '../models/rating.dart';

class RatingScreen extends StatefulWidget {
  final String jobId;
  final String ratedUserId;
  final String ratedUserName;
  final String role;
  final String jobTitle;

  const RatingScreen({
    super.key,
    required this.jobId,
    required this.ratedUserId,
    required this.ratedUserName,
    required this.role,
    required this.jobTitle,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate ${widget.ratedUserName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'How was your experience with ${widget.ratedUserName} for job "${widget.jobTitle}"?',
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
              onPressed: _rating == 0 || _isSubmitting ? null : _submitRating,
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    final ratingService = Provider.of<RatingService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a rating'),
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final rating = Rating(
      id:
          '${widget.jobId}_${authService.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: authService.currentUser!.uid,
      toUserId: widget.ratedUserId,
      jobId: widget.jobId,
      jobTitle: widget.jobTitle,
      stars: _rating,
      comment: _commentController.text,
      createdAt: DateTime.now(),
      role: widget.role,
    );

    try {
      await ratingService.submitRating(rating);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your Rating successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit rating: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
