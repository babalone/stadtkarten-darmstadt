import 'package:geojson/geojson.dart';
import 'package:latlong/latlong.dart';
import 'package:optional/optional.dart';

class Feature {
  String name;
  String icon;
  String layer;
  String coords;
  String description;
  LatLng point;
  Optional<String> link;

  @override
  toString() {
    return "name: $name; icon: $icon; layer: $layer; coords: $coords; description: $description; link: $link";
  }

  static Feature fromFeature(GeoJsonFeature geoJsonFeature) {
    var properties = geoJsonFeature.properties;
    Optional<String> handleLink(String link) {
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
      ..point = geoJsonFeature?.geometry?.geoPoint?.point;
  }
}
