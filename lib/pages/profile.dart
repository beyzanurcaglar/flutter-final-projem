import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../../models/person.dart';

final person = Person();

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _information = Hive.box('information');

  late final TextEditingController heightController;
  late final TextEditingController weightController;
  late final TextEditingController ageController;

  int? selectedActivity;
  bool isEditing = false;

  late String name = '';
  late double calorie = 0.0;
  late double water = 0.0;
  late double kgLow = 0.0;
  late double kgHigh = 0.0;
  late double mass = 0.0;
  late double height = 0.0;
  late double weight = 0.0;
  late int age = 0;
  late int gender = 0;
  late int activity = 0;
  late double bmr = 0.0;
  late double activityMultiplier = 1.2;

  @override
  void initState() {
    super.initState();
    // Load data from Hive box
    name = _information.get('name', defaultValue: '');
    calorie = _information.get('calorie', defaultValue: 0.0);
    water = _information.get('water', defaultValue: 0.0);
    kgLow = _information.get('kgLow', defaultValue: 0.0);
    kgHigh = _information.get('kgHigh', defaultValue: 0.0);
    mass = _information.get('mass', defaultValue: 0.0);
    height = _information.get('height', defaultValue: 0.0);
    weight = _information.get('weight', defaultValue: 0.0);
    age = _information.get('age', defaultValue: 0);
    gender = _information.get('gender', defaultValue: 0);
    activity = _information.get('activity', defaultValue: 0);
    bmr = _information.get('bmr', defaultValue: 0.0);
    activityMultiplier = _information.get('activityMultiplier', defaultValue: 1.2);

    heightController = TextEditingController(text: height.toString());
    weightController = TextEditingController(text: weight.toString());
    ageController = TextEditingController(text: age.toString());

    selectedActivity = activity;
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void writeData(String key, dynamic value) {
    _information.put(key, value);
  }

  void saveProfileData() async {
    setState(() {
      height = double.tryParse(heightController.text) ?? height;
      weight = double.tryParse(weightController.text) ?? weight;
      age = int.tryParse(ageController.text) ?? age;

      writeData('height', height);
      writeData('weight', weight);
      writeData('age', age);
      writeData('activity', selectedActivity);

      switch (selectedActivity) {
        case 1:
          activityMultiplier = 1.75;
          break;
        case 2:
          activityMultiplier = 1.55;
          break;
        case 3:
        default:
          activityMultiplier = 1.2;
          break;
      }

      if (gender == 1) {
        bmr = 655 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
      } else {
        bmr = 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
      }

      person.tdee = bmr * activityMultiplier;
      person.waterIntake = weight * 0.033;
      person.kgLow = 18.5 * (height / 100) * (height / 100);
      person.kgHigh = 24.9 * (height / 100) * (height / 100);
      person.massIndex = weight / ((height / 100) * (height / 100));

      writeData('calorie', person.tdee);
      writeData('water', person.waterIntake);
      writeData('kgLow', person.kgLow);
      writeData('kgHigh', person.kgHigh);
      writeData('mass', person.massIndex);

      isEditing = false;
    });

    setState(() {
      // Güncellenmiş değerleri tekrar alın
      height = _information.get('height', defaultValue: 0.0);
      weight = _information.get('weight', defaultValue: 0.0);
      age = _information.get('age', defaultValue: 0);
      calorie = _information.get('calorie', defaultValue: 0.0);
      water = _information.get('water', defaultValue: 0.0);
      kgLow = _information.get('kgLow', defaultValue: 0.0);
      kgHigh = _information.get('kgHigh', defaultValue: 0.0);
      mass = _information.get('mass', defaultValue: 0.0);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[300],
        centerTitle: true,
        title: const Text(
          "Profil",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
          leading: null,
          automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_box_rounded,
                        color: Colors.blueGrey,
                        size: 150,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (isEditing)
                  Column(
                    children: [
                      TextField(
                        controller: heightController,
                        decoration: const InputDecoration(labelText: 'Boy (cm)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: weightController,
                        decoration: const InputDecoration(labelText: 'Kilo (kg)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: ageController,
                        decoration: const InputDecoration(labelText: 'Yaş'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Aktivite',
                          style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      ),
                      RadioListTile<int>(
                        title: const Text('Çok Hareketli'),
                        value: 1,
                        groupValue: selectedActivity,
                        onChanged: (value) => setState(() => selectedActivity = value),
                      ),
                      RadioListTile<int>(
                        title: const Text('Orta Hareketli'),
                        value: 2,
                        groupValue: selectedActivity,
                        onChanged: (value) => setState(() => selectedActivity = value),
                      ),
                      RadioListTile<int>(
                        title: const Text('Az Hareketli'),
                        value: 3,
                        groupValue: selectedActivity,
                        onChanged: (value) => setState(() => selectedActivity = value),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: saveProfileData,
                        child: const Text(
                          "Değişiklikleri Kaydet",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TitleSubtitleCell(
                          title: height.toString(),
                          subtitle: "Boy (cm)",
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TitleSubtitleCell(
                          title: weight.toString(),
                          subtitle: "Kilo (kg)",
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TitleSubtitleCell(
                          title: age.toString(),
                          subtitle: "Yaş",
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                _buildInfoContainer('Kitle İndeksi: ${mass.toStringAsFixed(2)}'),
                _buildInfoContainer('İdeal Kilo Aralığı: ${kgLow.toStringAsFixed(2)} - ${kgHigh.toStringAsFixed(2)} kg'),
                _buildInfoContainer('TDEE: ${calorie.toStringAsFixed(2)} kcal'),
                _buildInfoContainer('Günlük Su Alımı: ${water.toStringAsFixed(2)} litre/gün'),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor: Colors.white70,
                  ),
                  onPressed: () => setState(() => isEditing = !isEditing),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Düzenle",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor: Colors.white70,
                  ),
                  onPressed: () async {
                    var infoBox = await Hive.openBox("information");
                    var daily =await Hive.openBox("daily");// 'information' box'ını aç
                    await infoBox.clear();
                    await daily.clear();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                          (route) => false,
                      arguments: {'hideArrow': true},// Önceki tüm sayfaları kaldır
                    );

                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.exit_to_app_outlined, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Çıkış Yap",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white70.withOpacity(0.2),
        border: Border.all(color: Colors.green, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TitleSubtitleCell extends StatelessWidget {
  final String title;
  final String subtitle;

  const TitleSubtitleCell({super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}