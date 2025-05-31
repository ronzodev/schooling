import 'package:ai/chem_periodic/periodic.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final ElementData element;

  DetailPage(this.element, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listItems = <Widget>[
      ListTile(
        leading: const Icon(Icons.category, color: Colors.white,),
        title: Text(element.category.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18.0)),
      ),
      ListTile(
        leading: const Icon(Icons.info, color: Colors.white,),
        title: Text(element.extract, style: const TextStyle(color: Colors.white)),
        subtitle: Text(element.source, style: const TextStyle(color: Colors.white),),
      ),
      ListTile(
        leading: const Icon(Icons.fiber_smart_record, color: Colors.white,),
        title: Text(element.atomicWeight, style: const TextStyle(color: Colors.white),),
        subtitle: const Text('Atomic Weight', style: TextStyle(color: Colors.white),),
      ),
    ].expand((widget) => [widget, const Divider()]).toList();

    return Scaffold(
      backgroundColor: Color.lerp(Colors.grey[850], element.colors[0], 0.07),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.lerp(Colors.grey[850], element.colors[1], 0.2),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kContentSize * 1.5),
          child: ElementTile(element, isLarge: true),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 24.0),
        children: listItems,
      ),
    );
  }
}