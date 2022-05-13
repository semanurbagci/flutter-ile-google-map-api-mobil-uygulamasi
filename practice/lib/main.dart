import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Iskele(),
    );
  }
}

class Iskele extends StatefulWidget {
  @override
  _IskeleState createState() => _IskeleState();
}

class _IskeleState extends State<Iskele> {

  String donustur(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000 + 10800000);
    //var formattedDate = DateFormat.yMMMd().format(date);
    var x = DateFormat.yMd().add_Hms().format(date);
    return x;
  }

  List<String> tarihler = [];
  List<double> mesafeler = [];
  Map<String, double> map = {
    "En uzun mesafeli 5 yolculuktaki gun ve mesafeler. Sorgu tipi ": 1.3
  };

  void tip1_3() async {
    map = {
    "En uzun mesafeli 5 yolculuktaki gun ve mesafeler. Sorgu tipi ": 1.3
  };
    final firestoreInstance = FirebaseFirestore.instance;
    var result = await firestoreInstance
        .collection("data")
        .orderBy("trip_distance", descending: true)
        .limit(5)
        .get();
    result.docs.forEach((res) {
      setState(() {
        var tarih = donustur(res.get("tpep_pickup_datetime"));
        var mesafe = res.get("trip_distance");
        tarihler.add(tarih);
        mesafeler.add(mesafe);
      });
    });
    map = Map.fromIterables(tarihler, mesafeler);
  }
  
  TextEditingController tarih1 = TextEditingController();
  TextEditingController tarih2 = TextEditingController();
  TextEditingController lokasyon = TextEditingController();
  int sayac = 0;

  void tip2_1() async {
    sayac=0;
    var t1 = tarih1.text.toString();
    var t2 = tarih2.text.toString();
    var lk = lokasyon.text.toString();
    int t1i = int.parse(t1);
    int t2i = int.parse(t2);

    final firestoreInstance = FirebaseFirestore.instance;
    var result = await firestoreInstance
        .collection("dataS")
        .orderBy("tpep_pickup_datetime")
        .get();
    result.docs.forEach((res) {
      setState(() {
        var mesafe2 = res.get("tpep_pickup_datetime");
        var mesafe2s = mesafe2.toString();
        var parsedstring = mesafe2s
            .replaceAll(':', '')
            .replaceAll(" ", "")
            .replaceAll("-", "");
        int parsedint = int.parse(parsedstring);
        //print(parseDtInt);
        if (t1i < parsedint &&
            parsedint < t2i &&
            res.get("PULocationID").toString() == lk) {
          sayac++;
          var y = res.get("PULocationID");
          print("$parsedint, $y");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("YazLab2 Proje2"),
      ),
      body: SingleChildScrollView(
        //margin: EdgeInsets.all(50),
        child: Center(
            child: Column(
          children: [
            ElevatedButton(
              child: Text('sorgu1.3'),
              onPressed: () {
                tip1_3();
              },
            ),
            ListTile(
              title: Text(map.toString()),
            ),
            TextField(
              controller: tarih1,
            ),
            TextField(
              controller: tarih2,
            ),
            TextField(
              controller: lokasyon,
            ),
            ElevatedButton(
                child: Text("sorgu2.1"),
                onPressed: () {
                  tip2_1();
                }),
            ListTile(
              title: Text(
                  "Iki tarih arasında belirli bir lokasyondan hareket eden araç sayısı: "),
              subtitle: Text(sayac.toString()),
            ),
          ],
        )),
      ),
    );
  }
}