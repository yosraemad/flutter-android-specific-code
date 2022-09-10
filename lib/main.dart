import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Specific Code',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Running Android Specific Code'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel("com.example.flutter_app/android");

  int _batteryLevel = -1;
  double _phoneTemperature = -1;
  Future<void> _getBatteryLevel() async {
    int batteryLevel;
    try {
      final int result = await platform.invokeMethod("getBatteryLevel");
      batteryLevel = result;
    } on PlatformException catch (e) {
      batteryLevel = -1;
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getPhoneTemperature() async {
    double phoneTemperature;
    try {
      final String result = await platform.invokeMethod("getPhoneTemperature");
      phoneTemperature = double.parse(result);
    } on PlatformException catch (e) {
      phoneTemperature = -1;
    }
    setState(() {
      _phoneTemperature = phoneTemperature;
    });
  }

  Future<void> _getBatteryLevelAndPhoneTemperature() async {
    await _getBatteryLevel();
    await _getPhoneTemperature();
  }

  late Future<void> getStatus = _getBatteryLevelAndPhoneTemperature();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: getStatus,
          builder: (context, snapshot) {
            print(snapshot.connectionState);
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      StatusCard(
                        image: "https://i.postimg.cc/Mpw13tfX/battery.jpg",
                        status: "$_batteryLevel%",
                        isNormal: _batteryLevel > 50 && _batteryLevel != -1,
                      ),
                      StatusCard(
                        image: "https://i.postimg.cc/W17gBr08/temp.jpg",
                        status: "$_phoneTemperature°C",
                        isNormal:
                            _phoneTemperature < 40 && _phoneTemperature != -1,
                      ),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () => _getBatteryLevelAndPhoneTemperature(),
                      child: const Text("Refresh"))
                ],
              ),
            );
          }),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String image;
  final String status;
  final bool isNormal;
  const StatusCard(
      {super.key,
      required this.image,
      required this.status,
      required this.isNormal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Card(
        elevation: 2,
        child: Column(children: [
          Image.network(
            image,
            width: 100,
            height: 200,
          ),
          Text(status == "-1.0°C" || status == "-1%" ? "Unknown" : status,
              style: TextStyle(
                  color: isNormal ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
        ]),
      ),
    );
  }
}
