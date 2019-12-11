import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:optional/optional.dart';
import 'package:provider/provider.dart';

import 'model/AppState.dart';
import 'model/Feature.dart';

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
