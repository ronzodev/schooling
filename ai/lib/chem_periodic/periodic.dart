import 'dart:convert';
import 'package:ai/chem_periodic/detailed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Constants
const kRowCount = 6;
const kContentSize = 110.0;
const kGutterWidth = 2.0;
const kGutterInset = EdgeInsets.all(kGutterWidth);

// Model Class
class ElementData {
  final String name, category, symbol, extract, source, atomicWeight;
  final int number;
  final List<Color> colors;

  ElementData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        category = json['category'],
        symbol = json['symbol'],
        extract = json['extract'],
        source = json['source'],
        atomicWeight = json['atomic_weight'],
        number = json['number'],
        colors = (json['colors'] as List).map((value) => Color(value)).toList();
}

// Main Screen
class ElementsScreen extends StatelessWidget {
  ElementsScreen({Key? key}) : super(key: key);

  final Future<List<ElementData>> gridList = rootBundle
      .loadString('assets/equipment/elementsGrid.json')
      .then((source) => jsonDecode(source)['elements'] as List)
      .then((list) => list
          .map((json) => json != null ? ElementData.fromJson(json) : null)
          .whereType<ElementData>()
          .toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text(
          'Elements',
          
        ),
        centerTitle: true,
        
      
      ),
      body: FutureBuilder<List<ElementData>>(
        future: gridList,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return _buildTable(snapshot.data!);
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading elements.'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildTable(List<ElementData> elements) {
    final tiles = elements.map((element) => ElementTile(element)).toList();
    const tileFullHeight = kContentSize + (kGutterWidth * 4);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: kRowCount * tileFullHeight,
        child: GridView.count(
          crossAxisCount: kRowCount,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: tiles,
        ),
      ),
    );
  }
}

// Element Tile Widget
class ElementTile extends StatelessWidget {
  const ElementTile(this.element, {this.isLarge = false, Key? key})
      : super(key: key);

  final ElementData element;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final tileText = <Widget>[
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text('${element.number}',
            style: const TextStyle(fontSize: 16.0, color: Colors.white,
                fontWeight: FontWeight.w600),
            ),
      ),
      Text(
        element.symbol,
        style: Theme.of(context).primaryTextTheme.bodyLarge?.copyWith(
              fontSize: isLarge ? 24.0 : 16.0,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
      Text(
        element.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textScaleFactor: isLarge ? 0.65 : 1,
        style: Theme.of(context).primaryTextTheme.bodyLarge?.copyWith(
              fontSize: isLarge ? 16.0 : 12.0,
              color: const Color.fromARGB(255, 253, 250, 250),
              fontWeight: FontWeight.bold,
            ),
      ),
    ];

    final tile = Container(
      margin: kGutterInset,
      width: kContentSize,
      height: kContentSize,
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(colors: element.colors),
        backgroundBlendMode: BlendMode.multiply,
      ),
      child: RawMaterialButton(
        onPressed: !isLarge
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(element)),
                );
              }
            : null,
        fillColor: Colors.grey[800],
        disabledElevation: 10.0,
        padding: kGutterInset * 2.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: tileText,
        ),
      ),
    );

    return Hero(
      tag: 'hero-${element.symbol}',
      flightShuttleBuilder: (_, anim, __, ___, ____) => ScaleTransition(
          scale: anim.drive(Tween(begin: 1, end: 1.75)), child: tile),
      child: Transform.scale(scale: isLarge ? 1.75 : 1, child: tile),
    );
  }
}
