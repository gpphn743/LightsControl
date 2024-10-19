import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (_) => LightState(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lightState = Provider.of<LightState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _lightButton(context, Colors.red, lightState, 'redLight'),
            const SizedBox(height: 10),
            _lightButton(context, Colors.green, lightState, 'greenLight'),
            const SizedBox(height: 10),
            _lightButton(context, Colors.blue, lightState, 'blueLight'),
          ],
        ),
      ),
      //     Center(
      //   child: Switch(
      //       value: lightState.isLightOn,
      //       onChanged: (value) {
      //         lightState.toggleLight();
      //       }),
      // ),
    );
  }

  Widget _lightButton(BuildContext context, Color color, LightState lightState,
      String lightKey) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: 200,
      height: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.grey[200]),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: color,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'OFF',
                  style: TextStyle(color: Colors.black),
                ),
                Switch(
                    value: lightState.lights[lightKey] ?? false,
                    onChanged: (value) {
                      lightState.toggleLight(lightKey);
                    }),
                const Text(
                  'ON',
                  style: TextStyle(color: Colors.black),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LightState with ChangeNotifier {
  Map<String, bool> _lights = {};
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('lights');

  Map<String, bool> get lights => _lights;

  LightState() {
    _dbRef.onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _lights = data.map((key, value) => MapEntry(key, value as bool));
      notifyListeners();
    });
  }

  void toggleLight(String lightKey) {
    _lights[lightKey] = !_lights[lightKey]!;
    _dbRef.child(lightKey).set(_lights[lightKey]);
    notifyListeners();
  }
}
