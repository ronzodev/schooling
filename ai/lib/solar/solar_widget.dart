import 'package:flutter/material.dart';

import 'solar_data.dart';
import 'solar_model.dart';


class PlanetSelectorSheet extends StatelessWidget {
  final String currentPlanet;
  final Function(Planet) onPlanetSelected;

  const PlanetSelectorSheet({
    super.key,
    required this.currentPlanet,
    required this.onPlanetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const Text(
            'Explore Planets',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Planet grid - responsive layout
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = (constraints.maxWidth / 120).floor().clamp(2, 4);
                
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: PlanetsData.planets.length,
                  itemBuilder: (context, index) {
                    return _buildPlanetButton(context, PlanetsData.planets[index]);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPlanetButton(BuildContext context, Planet planet) {
    final isSelected = currentPlanet == planet.name;
    
    return ElevatedButton(
      onPressed: () {
        onPlanetSelected(planet);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[800],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: isSelected ? 8 : 2,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          planet.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}