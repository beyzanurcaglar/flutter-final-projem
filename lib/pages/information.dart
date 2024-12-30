import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../../models/person.dart';
import 'homepage.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: InfoPage(),
    );
  }

}
final person = Person();

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final _information = Hive.box('information');

  void writeData(String key, dynamic value) {
    _information.put(key, value);
  }
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bilgi Sayfası',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white54,
        elevation: 5.0,
        centerTitle: true,
      ),

      body: Container(
        color: Colors.lightGreen[800],
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Yaş',
                  fillColor: Colors.white54,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => person.age = int.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Yaşınızı giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Ağırlık',
                  fillColor: Colors.white54,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => person.weight = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ağırlığınızı giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Boşluk
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Boy',
                  fillColor: Colors.white54,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => person.height = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Boyunuzu giriniz.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              const Text(
                'Cinsiyet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              RadioListTile<int>(
                title: const Text(
                  'Kadın',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                value: 1,
                groupValue: person.gender,
                onChanged: (value) {
                  setState(() {
                    person.gender = value!;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text(
                  'Erkek',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                value: 2,
                groupValue: person.gender,
                onChanged: (value) {
                  setState(() {
                    person.gender = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              const Text(
                'Aktivite',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              RadioListTile<int>(
                title: const Text(
                  'Çok Hareketli',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                value: 1,
                groupValue: person.activity,
                onChanged: (value) {
                  setState(() {
                    person.activity = value!;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text(
                  'Orta Hareketli',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                value: 2,
                groupValue: person.activity,
                onChanged: (value) {
                  setState(() {
                    person.activity = value!;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text(
                  'Az hareketli',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                value: 3,
                groupValue: person.activity,
                onChanged: (value) {
                  setState(() {
                    person.activity = value!;
                  });
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    writeData('age', person.age);
                    writeData('weight', person.weight);
                    writeData('height', person.height);
                    writeData('active', person.activity);
                    writeData('gender', person.gender);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OutputPage()),
                    );
                  }
                },
                child: const Text('ONAYLA',
                  style: TextStyle(
                      color: Colors.black
                  ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class OutputPage extends StatelessWidget {

  final _information = Hive.box('information');

  void writeData(String key, dynamic value) {
    _information.put(key, value);
  }
  @override
  Widget build(BuildContext context) {
    String genderText = person.gender == 1 ? "Kadın":"Erkek";
    String activityText = "";

    if (person.activity == 1) activityText = "Çok Hareketli";
    if (person.activity == 2) activityText = "Orta Hareketli";
    if (person.activity == 3) activityText = "Az Hareketli";

    switch (person.activity) {
      case 1:
        person.activityMultiplier = 1.75; // Athletic
        break;
      case 2:
        person.activityMultiplier = 1.55; // Active
        break;
      case 3:
        person.activityMultiplier = 1.2; // Sedentary
        break;
      default:
        person.activityMultiplier = 1.2; // Default case
    }

    if (person.gender == 1) {
      person.bmr = 655 + (9.6 * person.weight) + (1.8 * person.height) - (4.7 * person.age);
    } else {
      person.bmr = 66 + (13.7 * person.weight) + (5 * person.height) - (6.8 * person.age);
    }

    person.tdee = (person.bmr * person.activityMultiplier);
    writeData('calorie', person.tdee);
    person.waterIntake = person.weight * 0.033;
    writeData('water', person.waterIntake);
    person.kgLow = (18.5 * (person.height / 100) * (person.height / 100)) ;
    writeData('kgLow', person.kgLow);
    person.kgHigh = (24.9 * (person.height / 100) * (person.height / 100));
    writeData('kgHigh', person.kgHigh);
    person.massIndex = (person.weight / ((person.height / 100) * (person.height / 100)) );
    writeData('mass', person.massIndex);

    return Scaffold(
      body: Container(
        color: Colors.lightGreen[800],
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoContainer(
                text:
                'İdeal kilo aralığınız: ${person.kgLow.toStringAsFixed(2)} -  ${person.kgHigh.toStringAsFixed(2)} kg',
              ),
              _buildInfoContainer(
                text:
                'Kitle indeksiniz: ${person.massIndex.toStringAsFixed(2)}',
              ),
              _buildInfoContainer(
                text:
                'Günlük almanız gereken ortalama kalori: ${person.tdee.toStringAsFixed(2)} kalori',
              ),
              _buildInfoContainer(
                text:
                'Günlük içmeniz gereken su miktarı: ${person.waterIntake.toStringAsFixed(2)} litre',
              ),
              SizedBox(height: 300),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_sharp,
                      color: Colors.black,
                      size: 50,
                    ),
                    tooltip: 'Geri',
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  MainTabView()),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.black,
                      size: 50,
                    ),
                    tooltip: 'Ana Sayfaya Git',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer({required String text}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(15.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Arka plan için şeffaf bir renk
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }
}