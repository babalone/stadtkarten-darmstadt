import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:geojson/geojson.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:stolpersteine_darmstadt/darmstadt/colors.dart';

import 'DetailsView.dart';
import 'MapVizalization.dart';
import 'model/AppState.dart';
import 'model/Feature.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Future<http.Response> geoJson;

  MyApp({Key key, this.geoJson}) : super(key: key);

  Future<List<Feature>> fetchPost() async {
    // TODO: configure URL in properties
    final response = await http
        .get('https://stadtatlas.darmstadt.de/geojson/Stolpersteine.geojson');
    print(response);
    // TODO: handle other status codes
    if (response.statusCode == 200) {
      return parseToFeatures(latin1ToUtf8(response.body));
    } else {
      return null;
    }
  }

  String latin1ToUtf8(String s) =>
      Utf8Decoder().convert(Latin1Encoder().convert(s));

  Future<List<Feature>> parseToFeatures(String json) async {
    final GeoJson geoJson = new GeoJson();
    await geoJson.parse(json, disableStream: true);
//    data.data.map(Feature.fromFeature).toList();
    return geoJson.features.map(Feature.fromFeature).toList();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          FutureProvider(
            initialData: List<Feature>(),
            create: (context) {
              // TODO: always fetch the data? Cache it for speed and slow/costly internet access. Extend AppState for this?
              return fetchPost();
            },
            catchError: (error, stacktrace) {
              // TODO: inform the user? Allow him to send a crash-notice to app-developer?
              print(error);
              print(stacktrace);
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              return new AppState();
            },
          ),
        ],
        child: MaterialApp(
          // TODO: title should be in a properties-file
          title: "Stolpersteine Darmstadt",
          theme: ThemeData(
            // TODO: should be in a properties-file
            primarySwatch: DaColor.blue,
          ),
//          home: MapVisualization(),
          routes: <String, WidgetBuilder>{
            "/": (context) => MapVisualization(),
            "/details": (context) => DetailsView(),
            "/information": (context) => getUsageInformation(),
            "/legal": (context) => getLegalInformation(),
          },
        ));
  }

  /// returns the usage information and explanation where the data comes from
  Widget getUsageInformation() {
    // TODO: add text to properties-file
    return Linkify(
      text:
          """Die App zeigt Informationen zu den Stolpersteinen in Darmstadt an. 
        Zu einigen Personen gibt es längere Berichte, die von verschiedenen Vereinen
        zusammengestellt wurden. Diese App macht die Daten auf mobilen Endgeräten verfügbar.
        Die Daten kommen von https://stadtatlas.darmstadt.de/""",
      humanize: true,
      onOpen: (link) async {
        print(link);
        await FlutterWebBrowser.openWebPage(url: link.url);
      },
    );
  }

  /// returns the legal information and sources of the data
  Widget getLegalInformation() {
    // TODO: add text to properties-file
    return Linkify(
      text:
          // TODO: Lizenz anfügen
          """Diese Anwendung ist OpenSource (Lizenz zur Nuzung folgt noch).
        Die Daten kommen von https://stadtatlas.darmstadt.de/""",
      humanize: true,
      onOpen: (link) async {
        print(link);
        await FlutterWebBrowser.openWebPage(url: link.url);
      },
    );
  }
}
