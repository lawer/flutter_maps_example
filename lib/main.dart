import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Station.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

Future<bool> doAuth() async {
  // Set provider
  final providers = [
    AuthUiItem.AuthAnonymous,
    AuthUiItem.AuthEmail,
    AuthUiItem.AuthGoogle,
  ];

  return await FlutterAuthUi.startUi(
      items: providers,
      tosAndPrivacyPolicy: TosAndPrivacyPolicy(
        tosUrl: "https://www.google.com",
        privacyPolicyUrl: "https://www.google.com",
      ),
      androidOption: AndroidOption(
        enableSmartLock: false, // default true
      ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Marker> markers = [];

  Future<void> _downloadData() async {
    Uri uri = Uri.http("barcelonaapi.marcpous.com", "bicing/stations.json");

    var result = await http.get(uri);
    var body = result.body;

    Map<String, dynamic> results = jsonDecode(body);
    Map<String, dynamic> data = results["data"];
    List<dynamic> bicisJson = data["bici"];

    List<Bici> _bicis = [];
    List<Marker> _markers = [];

    for (var o in bicisJson) {
      var bici = Bici.fromJson(o);
      _bicis.add(bici);
    }

    for (var bici in _bicis) {
      var marker = Marker(
          point: LatLng(double.parse(bici.lat), double.parse(bici.lon)),
          builder: (ctx) => Container(
                child: Icon(
                  Icons.pin_drop,
                  color: Colors.blue.shade600,
                ),
              ));

      _markers.add(marker);
    }

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      markers = _markers;
    });

    print(_bicis);
    print(markers);
  }

  void incCounter(FirebaseFirestore database) {
    var collection = database.collection('counter');
    var result = collection.get();
    result.then((QuerySnapshot querySnapshot) {
      print(querySnapshot.size);

      if (querySnapshot.size == 0) {
        collection.add({"counter": 0});
      } else {
        var document = querySnapshot.docs.first;
        var data = document.data();

        collection.doc(document.id).set({"counter": data["counter"] + 1});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    FirebaseAuth.instance.userChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
        doAuth();
      } else {
        print('User is signed in!');
      }
    });

    var database = FirebaseFirestore.instance;

    incCounter(database);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.map)),
                Tab(icon: Icon(Icons.list)),
              ],
            ),
            title: Text(widget.title),
          ),
          body: TabBarView(
            children: [
              MyMap(markers: markers),
              Container(
                child: FutureBuilder(
                  future: database.collection("instituts").get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data;
                      var docs = data.docs;
                      return ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          padding: const EdgeInsets.all(8),
                          itemCount: data.size,
                          itemBuilder: (context, index) {
                            return ListTile(title: Text(docs[index]['nom']));
                          });
                    } else {
                      return Text("Loading...");
                    }
                  },
                ),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _downloadData,
            tooltip: 'Increment',
            child: Icon(Icons.refresh),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}

class MyMap extends StatelessWidget {
  const MyMap({
    Key key,
    @required this.markers,
  }) : super(key: key);

  final List<Marker> markers;

  @override
  Widget build(BuildContext context) {
    return Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FlutterMap(
      options: MapOptions(
        center: LatLng(41.39843017161212, 2.203274055678667),
        zoom: 14.0,
        plugins: [
          MarkerClusterPlugin(),
        ],
      ),
      layers: [
        TileLayerOptions(
            urlTemplate:
                "https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        MarkerClusterLayerOptions(
          maxClusterRadius: 120,
          size: Size(40, 40),
          markers: markers,
          builder: (context, markers) {
            return FloatingActionButton(
              child: Text(markers.length.toString()),
              onPressed: null,
            );
          },
        ),
      ],
    ));
  }
}
