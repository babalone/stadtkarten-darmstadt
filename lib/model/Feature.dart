import 'package:geojson/geojson.dart';
import 'package:latlong/latlong.dart';
import 'package:optional/optional.dart';

/// A feature to be located on the map view
class Feature {
  String name;
  String icon;
  String layer;
  String coords;
  String description;
  LatLng point;
  Optional<String> link;

  /// The GeoJsonFeature from which the other information got retrieved (if built with fromFeature(...))
  GeoJsonFeature geoJsonFeature;

  @override
  toString() {
    return "name: $name; icon: $icon; layer: $layer; coords: $coords; description: $description; link: $link";
  }

  static Feature fromFeature(GeoJsonFeature geoJsonFeature) {
    var properties = geoJsonFeature.properties;
    Optional<String> handleLink(String link) {
      // TODO: locate these values in a properties file
      if (link == "http://www.stolpersteine.com/") {
        return Optional.empty();
      } else {
        return Optional.ofNullable("https://stadtatlas.darmstadt.de/" + link);
      }
    }

//point.geometry.geoPoint.point

    return new Feature()
      ..name = properties["name"]
      ..icon = properties["icon"]
      ..layer = properties["layer"]
      ..coords = properties["coords"]
      ..description = properties["description"]
      ..link = handleLink(properties["link"])
      ..point = geoJsonFeature?.geometry?.geoPoint?.point
      ..geoJsonFeature = geoJsonFeature;
  }
}
