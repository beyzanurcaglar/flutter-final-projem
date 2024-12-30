import 'package:fitness_app/date_time/date_time.dart';
import 'package:fitness_app/models/fitness_program.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'graph.dart';
import 'profile.dart';

void main() async{
  await Hive.initFlutter();
  await Hive.openBox("information");
  await Hive.openBox("daily");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainTabView(),
    );
  }
}

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket();
  Widget currentTab = const HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: InkWell(
          onTap: () {
            selectTab = 0; // Set the current tab to Home
            currentTab = const HomePage(); // Set the active page to HomePage
            if (mounted) {
              setState(() {});
            }
          },
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2),
                ]),
            child: const Icon(
              Icons.home,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, -2))]),
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TabButton(
                    icon: Icons.list_alt,
                    isActive: selectTab == 0,
                    onTap: () {
                      selectTab = 1;
                      currentTab = StepGraph();
                      if (mounted) {
                        setState(() {});
                      }
                    }),
                const SizedBox(width: 40),
                TabButton(
                    icon: Icons.person,
                    isActive: selectTab == 1,
                    onTap: () {
                      selectTab = 2;
                      currentTab =  ProfileView();
                      if (mounted) {
                        setState(() {});
                      }
                    }),
              ],
            ),
          )),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  late String name='';
  late double dailyWater = 0.0;
  late int stepCount =0;
  final double totalCalories = 2000; // Günlük toplam kalori hedefi
  late int burnedCalories = 0;
  late int calori =0;
  late int dailyBurnedCalories;
  late ValueListenable<Box> dailyBoxListenable;
  late ValueNotifier<double> progressNotifier;
  late double progress;


  @override
  void initState(){
    super.initState();
    final box=Hive.box("information");
    final daily = Hive.box("daily");
    dailyBoxListenable = Hive.box("daily").listenable();
    setState(() {
      name=box.get('name');
      dailyWater = daily.get("dailyWater"+todaysDateYYYYMMDD(), defaultValue: 0.0);
      stepCount=daily.get("stepcount"+todaysDateYYYYMMDD(),defaultValue: 0);
      burnedCalories = daily.get("burnedCalories" +todaysDateYYYYMMDD(),defaultValue: 0);
      progress = daily.get("progress"+todaysDateYYYYMMDD(),defaultValue: 0.0);
      progressNotifier = ValueNotifier(progress);
      burnedCalories=start();
    });
  }
  List waterArr = [
    {"title": "2 lt" },
    {"title": "1.5lt"},
    {"title": "1lt"},
    {"title": "0.5lt"},
    {"title": "0.1lt"},
  ];
  void _incrementProgress() {
    var daily =Hive.box("daily");
    setState(() {
      if (dailyWater < 1.0) {
        dailyWater += 0.1;

        if (dailyWater > 1.0) {
          dailyWater = 1.0;
        }
      }
      daily.put("dailyWater"+todaysDateYYYYMMDD(), dailyWater);
    });
  }
  int start()
  {
    var daily =Hive.box("daily");
    setState(() {
      burnedCalories=
          (daily.get("tennis"+todaysDateYYYYMMDD(),defaultValue: 0) * 8)+
              (daily.get("cardio"+todaysDateYYYYMMDD(),defaultValue: 0) * 6)+
              (daily.get("running"+todaysDateYYYYMMDD(),defaultValue: 0) * 2)+
              (daily.get("volleyball"+todaysDateYYYYMMDD(),defaultValue: 0) * 6)+
              (daily.get("football"+todaysDateYYYYMMDD(),defaultValue: 0) * 10)+
              (daily.get("cycling"+todaysDateYYYYMMDD(),defaultValue: 0) * 10);
      daily.put("burnedCalories" +todaysDateYYYYMMDD(),burnedCalories);
      daily.put("progress"+todaysDateYYYYMMDD(), (burnedCalories / totalCalories) * 100);
      progressNotifier.value = (burnedCalories / totalCalories) * 100;
    });
    return burnedCalories;
  }

  Future<bool> addSteps() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController stepController = TextEditingController();
        return AlertDialog(
          title: const Text(
            'Adım Ekle',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
          content: TextField(
            controller: stepController,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'İptal',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final int addedSteps = int.tryParse(stepController.text) ?? 0;
                setState(() {
                  final todayKey = "stepcount" + todaysDateYYYYMMDD();
                  final currentSteps = Hive.box("daily").get(todayKey, defaultValue: 0);
                  Hive.box("daily").put(todayKey, currentSteps + addedSteps);
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Ekle',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitTrack',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: null,
        automaticallyImplyLeading: false,// Geri ok simgesini kaldırır
      ),

      body:  SingleChildScrollView(
        child :Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.lightGreen,
              child:Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Merhaba,', style: TextStyle(fontSize: 50, color: Colors.white)),
                    Text(name, style: const TextStyle(fontSize: 50, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Aktiviteler'),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20) ,
                    scrollDirection: Axis.horizontal,
                    itemCount: fitnessPrograms.length,
                    itemBuilder: (context, index) {
                      return Program(
                        program: fitnessPrograms[index],
                        active: true,
                      );
                    },
                    separatorBuilder: (context,index) => const SizedBox(width:10),
                  ),
                ),
              ],
            ),
            SizedBox(height :media.width * 0.05),
            Row(
              children: [
                Expanded(

                  child: Stack(
                      children: [Container(
                        height: media.width * 0.95,
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const[
                              BoxShadow(color: Colors.black12,blurRadius: 2)
                            ]),
                        child: Row(
                          children: [
                            SimpleAnimationProgressBar(
                              height: media.width * 0.85,
                              width: media.width * 0.07,
                              backgroundColor: Colors.grey.shade100,
                              foregrondColor: Colors.purple,
                              ratio: dailyWater,
                              direction: Axis.vertical,
                              curve: Curves.fastLinearToSlowEaseIn,
                              duration: const Duration(seconds: 3),
                              borderRadius: BorderRadius.circular(15),
                              gradientColor: const LinearGradient(
                                  colors: [Colors.blue,Colors.blueAccent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter),
                            ),

                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Günlük su ekle",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) {
                                      return const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          colors: [Colors.black,Colors.black],
                                          end: Alignment.centerRight)
                                          .createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: waterArr.map((wObj) {
                                      var isLast = wObj == waterArr.last;
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                margin:
                                                const EdgeInsets.symmetric(vertical: 4),
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.purple.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                              ),
                                              if (!isLast)
                                                DottedDashedLine(
                                                    height: media.width * 0.11,
                                                    width: 0,
                                                    dashColor: Colors.pink.withOpacity(0.5),
                                                    axis: Axis.vertical)
                                            ],
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                wObj["title"].toString(),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                ),
                                              ),
                                              ShaderMask(
                                                blendMode: BlendMode.srcIn,
                                                shaderCallback: (bounds) {
                                                  return const LinearGradient(
                                                      colors: [Colors.grey],
                                                      begin: Alignment.centerLeft,
                                                      end: Alignment.centerRight)
                                                      .createShader(Rect.fromLTRB(
                                                      0,
                                                      0,
                                                      bounds.width,
                                                      bounds.height));
                                                },
                                              ),
                                            ],
                                          ),

                                        ],
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: FloatingActionButton(
                                  onPressed: _incrementProgress,
                                  backgroundColor: Colors.blue,
                                  mini: true,
                                  child: const Icon(
                                    Icons.water_drop_outlined,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),]
                  ),
                ),
                SizedBox(width: media.width * 0.05,),
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.lightGreen[100],
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Harcanan kalori",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: media.width * 0.2,
                                      height: media.width * 0.2,
                                      child: ValueListenableBuilder(
                                          valueListenable: dailyBoxListenable,
                                          builder: (context, Box box, _) {
                                            final BurnedCalories = box.get("burnedCalories" +todaysDateYYYYMMDD());
                                            return  Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                  Icon(Icons.local_fire_department,
                                                  color: Colors.orange,
                                                  size: 35,
                                                ),
                                              Text(
                                                '$BurnedCalories',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w700),
                                              ),
                                                ]
                                                ),
                                              ],
                                            );
                                          }
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),
                        Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.lightGreen[100],
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ValueListenableBuilder(
                                valueListenable: dailyBoxListenable,
                                builder: (context, Box box, _) {
                                  final stepCount = box.get("stepcount" + todaysDateYYYYMMDD(), defaultValue: 0);
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Günlük Adım Sayısı',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        '$stepCount',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              ElevatedButton(
                                onPressed: () async {
                                  await addSteps();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightGreen[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  '👣',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),]
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const TabButton({required this.icon, required this.isActive, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: isActive ? Colors.green : Colors.grey),
      onPressed: onTap,
    );
  }
}

class Program extends StatefulWidget {
  final FitnessProgram program;
  final bool active;

  const Program({super.key, required this.program, this.active = false});

  @override
  _ProgramState createState() => _ProgramState();
}

class _ProgramState extends State<Program> {
  late TextEditingController _controller;
  late var box;
  late ValueNotifier<double> progressNotifier;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    box = Hive.box("daily");
    double initialProgress = box.get("progress${todaysDateYYYYMMDD()}", defaultValue: 0.0);
    progressNotifier = ValueNotifier(initialProgress);
  }

  void start() {
    var daily = Hive.box("daily");
    setState(() {
      var burnedCalories =
          (daily.get("tennis${todaysDateYYYYMMDD()}", defaultValue: 0) * 8) +
              (daily.get("cardio${todaysDateYYYYMMDD()}", defaultValue: 0) * 6) +
              (daily.get("running${todaysDateYYYYMMDD()}", defaultValue: 0) * 2) +
              (daily.get("volleyball${todaysDateYYYYMMDD()}", defaultValue: 0) * 6) +
              (daily.get("football${todaysDateYYYYMMDD()}", defaultValue: 0) * 10) +
              (daily.get("cycling${todaysDateYYYYMMDD()}", defaultValue: 0) * 10);

      daily.put("burnedCalories${todaysDateYYYYMMDD()}", burnedCalories);

      double progress = (burnedCalories / 2000) * 100;
      daily.put("progress${todaysDateYYYYMMDD()}", progress);
      progressNotifier.value = progress; // Progress bar'ı güncelle
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    progressNotifier.dispose();
    super.dispose();
  }
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("AKTİVİTE SÜRENİZİ GİRİNİZ"),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "KAÇ DK",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İPTAL"),
            ),
            TextButton(
              onPressed: () {
                int? enteredValue = int.tryParse(_controller.text);
                if (enteredValue != null) {
                  setState(() {
                    box.put(widget.program.name + todaysDateYYYYMMDD(), enteredValue);
                    start();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("LÜTFEN SAYI GİRİNİZ"),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text("KAYDET"),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDialog,
      child: Container(
        height: 100,
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: widget.program.image,
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(15),
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.program.name),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 10,
                  ),
                  Text(widget.program.cals),
                  const SizedBox(width: 15),
                  const Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 10,
                  ),
                  const SizedBox(width: 5),
                  Text(widget.program.time),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}