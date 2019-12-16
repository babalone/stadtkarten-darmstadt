import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as map;
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import 'model/AppState.dart';
import 'model/Feature.dart';

/// A view with a FlutterMap and clickable markers on it.
/// The view is consuming a list of features and will show a wait-view while waiting for the data.
class MapVisualization extends StatelessWidget {
  Widget osmMap(List<Feature> features) {
    return Container(
      child: map.FlutterMap(
        // TODO: make initial position configurable in properties-file
        options: new map.MapOptions(
          center: new LatLng(49.8680, 8.655),
          zoom: 12,
        ),
        layers: [
          // TODO: make this configurable in properties file
          // TODO: is it fine to directly use openstreetmap.org?
          map.TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          map.MarkerLayerOptions(markers: buildList(features))
        ],
      ),
    );
  }

  /// convert a list of features to a list of clickable markers.
  /// The markers will set information for the details-view and navigate to it on click.
  List<Marker> buildList(List<Feature> data) {
    return data
        .map((feature) => new map.Marker(
            point: feature.point,
            builder: (BuildContext context) => GestureDetector(
                onTap: () {
                  print(feature);
                  Provider.of<AppState>(context).setCurrentFeature(feature);
                  Navigator.pushNamed(context, "/details");
                },
                child: Icon(Icons.location_on))))
        .toList();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO: make it configurable in properties-file
        title: Text("Stolpersteine Darmstadt"),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Consumer<List<Feature>>(
        builder: (context, features, child) {
          if (features == null) {
            // TODO: make it configurable in properties-file
            // TODO: better information to show? When does this happen? One-click option to inform app-developers if this is an error?
            return Text("features seems to be null");
          } else {
            if (features.isEmpty) {
              return CircularProgressIndicator();
            } else {
              return osmMap(features);
            }
          }
        },
      )),
    );
  }
}
