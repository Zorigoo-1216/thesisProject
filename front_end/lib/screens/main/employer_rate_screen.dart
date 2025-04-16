import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class EmployerRateScreen extends StatefulWidget {
  const EmployerRateScreen({super.key});

  @override
  State<EmployerRateScreen> createState() => _EmployerRateScreenState();
}

class _EmployerRateScreenState extends State<EmployerRateScreen> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void submitRating() {
    final comment = commentController.text.trim();
    debugPrint("Rating: $selectedRating, Comment: $comment");
    // TODO: API call or logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Үнэлгээ илгээгдлээ")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
          Icon(Icons.settings),
          SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text("О.Эрдэнэцогт", style: AppTextStyles.heading),
            const Text("Барилгын инженер", style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.md),

            // Rating Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statBox("4.5", "RATING", Icons.star, Colors.amber),
                const SizedBox(width: 12),
                _statBox("12", "НИЙТ АЖИЛ", Icons.work, Colors.green),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ⭐ Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() => selectedRating = index + 1);
                  },
                );
              }),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ✍️ Comment
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What do you want to say?",
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ✅ Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedRating > 0 ? submitRating : null,
                child: const Text("Send Rating"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
