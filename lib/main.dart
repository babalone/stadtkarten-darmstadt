import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
    return FutureProvider(
        initialData: List<Feature>(),
        create: (context) {
          return fetchPost();
        },
        child: MaterialApp(
          title: 'Stolpersteine Darmstadt',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MapVisualization(),
        ));
  }
}
