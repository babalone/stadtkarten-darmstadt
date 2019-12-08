import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:geojson/geojson.dart';
import 'package:http/http.dart' as http;
import 'package:optional/optional_internal.dart';
import 'package:provider/provider.dart';
import 'package:stolpersteine_darmstadt/darmstadt/colors.dart';

import 'MapVizalization.dart';
import 'model/Feature.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Future<http.Response> geoJson;

  MyApp({Key key, this.geoJson}) : super(key: key);

  Future<List<Feature>> fetchPost() async {
    final response = await http
        .get('https://stadtatlas.darmstadt.de/geojson/Stolpersteine.geojson');
    print(response);
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
              return fetchPost();
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              return new AppState();
            },
          ),
        ],
        child: MaterialApp(
          title: "Stolpersteine Darmstadt",
          theme: ThemeData(
            primarySwatch: DaColor.blue,
          ),
//          home: MapVisualization(),
          routes: <String, WidgetBuilder>{
            "/": (context) => MapVisualization(),
            "/details": (BuildContext context) => DetailsView(),
          },
        ));
  }
}

class AppState with ChangeNotifier {
  Optional<Feature> currentFeature = Optional.empty();

  setCurrentFeature(Feature feature) {
    this.currentFeature = Optional.of(feature);
    notifyListeners();
  }
}

class DetailsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var maybeFeature = Provider.of<AppState>(context).currentFeature;
    return Scaffold(
      appBar: AppBar(
        title: Text(maybeFeature.value.name),
      ),
      body: Center(
        child: renderFeature(maybeFeature),
      ),
    );
  }

  Widget renderFeature(Optional<Feature> maybeFeature) {
    if (maybeFeature.isPresent) {
      final feature = maybeFeature.value;
      return Column(
        children: <Widget>[
          Text(feature.description.replaceAll("<br>", "\n")),
          if (feature.link.isPresent)
            Linkify(
              text: "Weitere Informationen: ${feature.link.value}",
              onOpen: (link) async {
                print(link);
                await FlutterWebBrowser.openWebPage(url: link.url);
              },
            ),
        ],
      );
    } else {
      return Text(
          "Sie können auf der Karte einen Ort auswählen, um hier mehr über diesen Ort zu erfahren.");
    }
  }
}
