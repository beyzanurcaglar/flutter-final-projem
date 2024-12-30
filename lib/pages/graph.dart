import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../date_time/date_time.dart';

class StepGraph extends StatefulWidget {
  StepGraph({super.key});

  @override
  _StepGraphState createState() => _StepGraphState();
}

class _StepGraphState extends State<StepGraph> {
  late Box dailyBox;

  @override
  void initState() {
    super.initState();
    if (!Hive.isBoxOpen('daily')) {
      throw Exception("Hive box 'daily' is not open. Make sure it is initialized in main().");
    }
    dailyBox = Hive.box('daily');
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateWithDayName(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[200],
        centerTitle: true,
        title: const Text(
          "Haftalık Adım Grafiği",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
          leading: null,
          automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Bugün: Tarih Gösterimi
          Container(
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            width: double.infinity,
            child: Text(
              "$formattedDate",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 50),
          SizedBox(
            height: 400, // Grafiğin yüksekliğini burada belirtiyoruz
            child: ValueListenableBuilder(
              valueListenable: dailyBox.listenable(),
              builder: (context, box, widget) {
                final weeklySteps = getWeeklySteps(box);

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                      ),
                      barGroups: weeklySteps.entries.map((entry) {
                        final dayIndex = entry.key;
                        final steps = entry.value.toDouble();

                        return BarChartGroupData(
                          x: dayIndex,
                          barRods: [
                            BarChartRodData(
                              toY: steps,
                              color: Colors.lightGreen[800],
                              width: 30, // Çubuk genişliği
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false, // Sağdaki başlıkları gizledik
                            reservedSize: 40,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true, // Soldaki başlıkları gösteriyoruz
                            reservedSize: 40,
                            interval: 5000, // Değerler arasındaki aralık
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value >= 0 && value < 7) {
                                return Text(
                                  getDayShortName(value.toInt()),
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 50),
          Container(
            child: ValueListenableBuilder(
              valueListenable: dailyBox.listenable(),
              builder: (context, box, widget) {
                final todaySteps = dailyBox.get("stepcount"+todaysDateYYYYMMDD(), defaultValue: 0);
                print(todaySteps);

                double totalDistance = todaySteps * 0.8; // 0.8 metre/adım
                double totalCalories = todaySteps * 0.04; // 0.04 kalori/adım
                return Row(
                  children: [
                    SizedBox(width: 45,),
                    Container(
                      width: 150,
                      height: 100,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_walk,
                            color: Colors.orange,
                            size: 40,
                          ),
                          // Adım Sayısı Değeri
                          Text(
                            '${(totalDistance / 1000).toStringAsFixed(2)} km',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 150,
                      height: 100,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.local_fire_department,
                            color: Colors.orange,
                            size: 40,
                          ),
                          // Adım Sayısı Değeri
                          Text(
                            '${totalCalories.toStringAsFixed(2)} kcal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<int, int> getWeeklySteps(Box dailyBox) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
    final Map<int, int> weeklySteps = {
      1: 0, // Pazartesi
      2: 0, // Salı
      3: 0, // Çarşamba
      4: 0, // Perşembe
      5: 0, // Cuma
      6: 0, // Cumartesi
      0: 0, // Pazar
    };

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      if(day.isBefore(currentWeekStart))
        {
          continue;
        }
      final key = "stepcount${todaysDateYYYYMMDD1(day)}";
      final steps = dailyBox.get(key, defaultValue: 0);
      weeklySteps[day.weekday] = steps; // Doğru haftalık güne eşle
    }
    return weeklySteps;
  }

  String getDayShortName(int index) {
    const days = ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'];
    return days[index % 7];
  }

  String formatDateWithDayName(DateTime date) {
    final days = ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'];
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return "${date.day} ${months[date.month - 1]} ${days[date.weekday % 7]}";
  }


}
String todaysDateYYYYMMDD1([DateTime? date]) {
  final now = date ?? DateTime.now();
  return "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
}