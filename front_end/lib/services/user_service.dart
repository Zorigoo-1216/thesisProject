import '../../models/user_model.dart';

class UserService {
  static Future<UserModel> fetchUser() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate delay
    return UserModel(
      name: "О.Эрдэнэцогт",
      role: "Барилгын инженер",
      email: "erdene@example.com",
      phone: "98112233",
      personal: {
        "Төрсөн огноо": "1995-05-12",
        "Регистр": "УБ12345678",
        "Гэрийн хаяг": "БЗД 14-р хороо",
        "Хүйс": "Эрэгтэй",
        "Баталгаажуулсан эсэх": "Тийм",
        "Хөгжлийн бэрхшээлтэй": "Үгүй",
        "Жолооны үнэмлэх": "Байхгүй",
      },
      jobInfo: {
        "Үндсэн салбар": "Барилга, дэд бүтэц",
        "Туршлага": "Intermediate",
        "Хүсэж буй цалин": "8000₮/цаг",
        "Хэл": "Англи",
      },
      skills: [
        "Swift",
        "UI Design",
        "iOS",
        "Prototyping",
        "User Testing",
        "User Research",
      ],
      isVerified: false,
    );
  }

  static Future<void> updateUser(UserModel user) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate saving
    print("Saved: ${user.toJson()}");
  }
}
