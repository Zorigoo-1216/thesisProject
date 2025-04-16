import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          toolbarHeight: 80,
          // title: const Text(
          //   'Сайн уу Зоригоо',
          //   style: TextStyle(color: AppColors.text, fontSize: 20),
          // ),
          actions: const [
            Icon(Icons.notifications_none, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Icon(Icons.settings, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            SizedBox(width: AppSpacing.sm),
          ],
        ),
        body: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage('assets/images/user.png'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "О.Эрдэнэсүхт",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Барилгын туслах ажилтан авна"),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "БЗД, Жуков, Сансар горхи хотхон",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              "120000₮ / өдөр",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // TabBar
            const TabBar(
              labelColor: Color(0xFF636AE8),
              unselectedLabelColor: Colors.black,
              indicatorColor: Color(0xFF636AE8),
              tabs: [
                Tab(text: 'Ажлын мэдээлэл'),
                Tab(text: 'Ажил олгогч мэдээлэл'),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(children: [_jobInfoTab(), _employerInfoTab()]),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // 💬 Apply action here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF636AE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Ажиллах хүсэлт илгээх",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jobInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          Text("Ажлын тухай", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            "We are looking for a talented and experienced Senior Product Designer to join our team...",
          ),

          SizedBox(height: 16),
          Text(
            "Ажлын шаардлага",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text("Цалин: 120000₮ / Өдөр\nӨдрийн 3 хоолтой\nУнааны мөнгөтэй"),

          SizedBox(height: 16),
          Text("Шаардлагууд", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("""
              - Strong design portfolio
              - Sketch, Figma ашиглах чадвар
              - Харилцааны өндөр соёл
              - Хэрэглэгч төвт загварын мэдлэг
              """),
        ],
      ),
    );
  }

  Widget _employerInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "О.Эрдэнэсүхт",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text("Барилгын инженер"),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "4.5",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Text("Нийт ажил: 12"),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text("Тухай", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Cillum laboris sunt nostrud cillum minim amet magna..."),

          const SizedBox(height: 16),
          const Text(
            "Холбоо барих",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text("Хувь хүн"),
          const Text("+976 98451216"),

          const SizedBox(height: 16),
          const Text(
            "Сэтгэгдэл",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Jinny Oslin",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "4.5 ⭐",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Magna id sint irure in cillum esse nisi magna pariatur excepteur laboris.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
