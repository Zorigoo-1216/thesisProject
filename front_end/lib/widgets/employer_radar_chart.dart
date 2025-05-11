// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class EmployerRadarChart extends StatelessWidget {
//   final Map<String, num> criteria;

//   const EmployerRadarChart({super.key, required this.criteria});

//   @override
//   Widget build(BuildContext context) {
//     final keys = criteria.keys.toList();
//     final values = criteria.values.map((e) => e.toDouble()).toList();

//     return RadarChart(
//       RadarChartData(
//         dataSets: [
//           RadarDataSet(
//             dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
//             fillColor: Colors.blue.withOpacity(0.3),
//             borderColor: Colors.blue,
//             entryRadius: 3,
//             borderWidth: 2,
//           ),
//         ],
//         radarBackgroundColor: Colors.transparent,
//         radarBorderData: const BorderSide(color: Colors.grey),
//         titlePositionPercentageOffset: 0.2,

//         /// ✅ Шинэ API: `getTitle`-ийг зөв тохируулсан
//         getTitle: (index, angle) {
//           return RadarChartTitle(
//             text: keys[index],
//             //textStyle: const TextStyle(fontSize: 10, color: Colors.black),
//           );
//         },

//         tickCount: 5,
//         ticksTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
//         tickBorderData: const BorderSide(color: Colors.grey),
//         gridBorderData: const BorderSide(color: Colors.grey),
//       ),
//     );
//   }
// }
