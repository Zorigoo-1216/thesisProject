import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class RateEmployeeScreen extends StatefulWidget {
  const RateEmployeeScreen({super.key});

  @override
  State<RateEmployeeScreen> createState() => _RateEmployeeScreenState();
}

class _RateEmployeeScreenState extends State<RateEmployeeScreen> {
  List<bool> isExpanded = List.generate(5, (_) => false);
  List<double> selectedRatings = List.generate(5, (_) => 0.0);
  List<TextEditingController> commentControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var controller in commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void handleRating(int index, double rating) {
    setState(() {
      selectedRatings[index] = rating;
    });
  }

  Widget buildStarRow(int index) {
    return Row(
      children: List.generate(5, (i) {
        return IconButton(
          onPressed: () => handleRating(index, i + 1),
          icon: Icon(
            Icons.star,
            color:
                selectedRatings[index] >= i + 1
                    ? AppColors.primary
                    : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Үнэлгээ өгөх"),
        actions: const [
          Icon(Icons.notifications_none, color: AppColors.primary),
          SizedBox(width: 16),
          Icon(Icons.settings, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                    radius: 28,
                  ),
                  title: const Text("Full name"),
                  subtitle: const Text("99010101"),
                  trailing: IconButton(
                    icon: Icon(
                      isExpanded[index]
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onPressed: () {
                      setState(() {
                        isExpanded[index] = !isExpanded[index];
                      });
                    },
                  ),
                ),
                if (isExpanded[index])
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStarRow(index),
                        Text(
                          "${selectedRatings[index]} оноо",
                          style: const TextStyle(color: AppColors.subtitle),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: commentControllers[index],
                          decoration: InputDecoration(
                            hintText: "Сэтгэгдэл бичих...",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            suffixIcon: const Icon(
                              Icons.send,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radius,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
