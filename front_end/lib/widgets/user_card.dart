import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../constant/styles.dart';

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({super.key, required this.user});

  /// `Зоригтбаатар Очирсүрэн` → `О.Зоригтбаатар`
  String formatName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final lastInitial = parts[1].substring(0, 1);
      return '$lastInitial.${parts[0]}';
    } else {
      return fullName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = formatName(user.name);

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                (user.avatar != null && user.avatar!.isNotEmpty)
                    ? NetworkImage(user.avatar!)
                    : const AssetImage('assets/images/avatar.png')
                        as ImageProvider,
          ),
          const SizedBox(height: 8),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 14, color: Colors.orange),
              const SizedBox(width: 2),
              Text(
                user.averageRating.overall.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.favorite, size: 14, color: Colors.red),
              const SizedBox(width: 2),
              Text(
                user.reviews.length.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
