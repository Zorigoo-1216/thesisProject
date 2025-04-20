// ✅ RatedUserModel -ийг зөв тодорхойлсон
import '.././models/user_model.dart';

class RatedUserModel {
  final UserModel user;
  final double rating;

  RatedUserModel({required this.user, required this.rating});

  factory RatedUserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'];
    if (userData is Map<String, dynamic>) {
      return RatedUserModel(
        user: UserModel.fromJson(userData),
        rating: (json['rating'] ?? 0).toDouble(),
      );
    } else {
      throw Exception('RatedUserModel.fromJson → "user" is not a map');
    }
  }
}
