import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  static const String routeName = '/rating';
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate & Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=ramesh')),
            const SizedBox(height: 16),
            const Text('How was your experience?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Rate Ramesh Kumar for his work.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Feedback Field
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe your experience (optional)',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Submit Review'),
              ),
            ),
            const SizedBox(height: 24),

            // Report Issue
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.report_problem_outlined, color: Colors.red),
              label: const Text('Report an issue', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
