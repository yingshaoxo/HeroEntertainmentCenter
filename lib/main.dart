import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:discoverpingableserviceonlocalnetwork/discoverpingableserviceonlocalnetwork.dart';
import 'package:heroentertainmentcenter/store.dart';

import 'package:isolate_handler/isolate_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyStore.init_preferences();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Hero Entertainment Center'),
    );
  }
}

void getURLlistFromIsolate(Map<String, dynamic> context) {
  final messenger = HandledIsolate.initialize(context);

  messenger.listen((msg) async {
    print(msg);

    String? wifiAddress =
        await Discoverpingableserviceonlocalnetwork.getWIFIaddress();

    if (wifiAddress == null) {
      return;
    }

    print(wifiAddress);
    List<String>? hosts =
        await Discoverpingableserviceonlocalnetwork.findServicesInANetwork(
            wifiAddress + "/24", 5000, 5010);
    //await Discoverpingableserviceonlocalnetwork.findServicesInANetwork( wifi_address + "/24", 80, 5100);

    List<String>? urls = [];
    if (hosts != null) {
      for (String host in hosts) {
        String baseUrl = "http://" + host;
        //print(baseUrl);
        final response = await http
            .get(Uri.parse("$baseUrl/api/info/"))
            .timeout(Duration(milliseconds: 500), onTimeout: () {
          return http.Response('Error', 500);
        });
        //print(response.body.toString());
        if (response.statusCode == 200) {
          urls.add(baseUrl);
        }
      }
    }

    messenger.send(urls);
  });
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final isolates = IsolateHandler();
  List<String> targetLocalShowURLlist = [];

  void setPath(List<String> urls) {
    setState(() {
      targetLocalShowURLlist = urls;
    });

    isolates.kill('urlList');
  }

  getEverythingDone() {
    isolates.spawn<List<String>>(getURLlistFromIsolate,
        name: 'urlList',
        onReceive: setPath,
        onInitialized: () =>
            isolates.send("made by yingshaoxo", to: 'urlList'));
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getEverythingDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = (MediaQuery.of(context).size.height);
    double width = (MediaQuery.of(context).size.width);
    double boxSize = width * 0.2;

    List<Widget> getBoxList() {
      return targetLocalShowURLlist.map((e) {
        return InkWell(
          child: Container(
            constraints: BoxConstraints(minWidth: boxSize, minHeight: boxSize),
            padding: const EdgeInsets.all(8),
            child: Center(child: Text(e, style: TextStyle(fontSize: 15))),
            //color: Colors.red[100],
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.red.withOpacity(0.1),
                Colors.white.withOpacity(0.3),
                Colors.blue.withOpacity(0.2)
              ],
            )),
          ),
          onTap: () {
            _launchURL(e);
          },
        );
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      //backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (targetLocalShowURLlist.length < 1) ...[
                Text(
                  'We are in search...',
                ),
              ] else ...[
                Center(
                  child: GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    children: getBoxList(),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            getEverythingDone();
          },
          tooltip: 'Increment',
          child: Icon(Icons
              .refresh)), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<void> _launchURL(String _url) async {
  await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
}
