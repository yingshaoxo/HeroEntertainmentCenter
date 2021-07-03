import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:discoverpingableserviceonlocalnetwork/discoverpingableserviceonlocalnetwork.dart';
import 'package:heroentertainmentcenter/store.dart';

import 'package:url_launcher/url_launcher.dart';

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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> targetLocalShowURLlist = [];

  Future<void> getEverythingDone() async {
    String? wifi_address =
        await Discoverpingableserviceonlocalnetwork.getWIFIaddress();

    if (wifi_address == null) {
      return;
    }

    print(wifi_address);
    List<String>? hosts =
        await Discoverpingableserviceonlocalnetwork.findServicesInANetwork(
            wifi_address + "/24", 5000, 5100);
    if (hosts != null) {
      targetLocalShowURLlist.clear();
      for (String host in hosts) {
        targetLocalShowURLlist.add("http://" + host + "/ui");
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getEverythingDone();
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
            child: Center(child: Text(e, style: TextStyle(fontSize: 10))),
            //color: Colors.red[100],
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[Colors.red, Colors.white, Colors.blue],
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (targetLocalShowURLlist.length < 1) ...[
              Text(
                'We are in search...',
              ),
            ] else ...[
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    children: getBoxList(),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await getEverythingDone();
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
