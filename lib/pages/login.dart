import 'package:fitness_app/models/person.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'information.dart';

void main() async{
  await Hive.openBox("information");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }

}
final person = Person();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _information = Hive.box('information');
  final _formKey = GlobalKey<FormState>();

  void writeData(String key ,String value){//dataları kaydettiğimiz func
    _information.put(key,value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.lightGreen[800],
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'photo/logo.jpg',
                height: 250,
              ),
              const SizedBox(height: 5),
              const Text(
                "FitTrack'e Hoşgeldiniz!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Ad',
                  fillColor: Colors.white54,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSaved: (value) => person.username = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen adınızı giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async{
                  if (_formKey.currentState!.validate())
                  {
                    _formKey.currentState!.save();
                    writeData('name',person.username);//adını hiveboxa kaydettik
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => InfoPage()));
                },
                child: const Text('DEVAM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}