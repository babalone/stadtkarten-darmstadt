import 'package:flutter/widgets.dart';
import 'package:optional/optional.dart';

import 'Feature.dart';

class AppState with ChangeNotifier {
  Optional<Feature> currentFeature = Optional.empty();

  setCurrentFeature(Feature feature) {
    this.currentFeature = Optional.of(feature);
    notifyListeners();
  }
}
