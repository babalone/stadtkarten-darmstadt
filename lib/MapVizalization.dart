import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as map;
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import 'model/Feature.dart';

class MapVisualization extends StatelessWidget {
  Widget osmMap(List<Feature> features) {
    return Container(
      child: map.FlutterMap(
        options: new map.MapOptions(
          center: new LatLng(49.8680, 8.655),
          zoom: 12.5,
        ),
        layers: [
          map.TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          map.MarkerLayerOptions(markers: buildList(features))
        ],
      ),
    );
  }

  List<Marker> buildList(List<Feature> data) {
    return data
        .map((feature) => new map.Marker(
            point: feature.point,
            builder: (BuildContext context) => GestureDetector(
                onTap: () {
                  print(feature);
                },
                child: Icon(Icons.location_on))))
        .toList();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stolpersteine Darmstadt"),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Consumer<List<Feature>>(
        builder: (context, features, child) {
          if (features.isEmpty) {
            return CircularProgressIndicator();
          } else {
            return osmMap(features);
          }
        },
      )),
    );
  }
}
