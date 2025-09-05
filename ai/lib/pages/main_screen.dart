import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

import '../pages/course.dart';
import '../chem_periodic/periodic.dart';
import '../math_formula/main_screen.dart';
import '../solar/solar_system_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    CourseListScreen(),
    ElementsScreen(),
    const MathFormulasScreen(),
    const SolarSystemScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Colors.deepPurple.shade900,
                    Colors.indigo.shade900,
                  ]
                : [
                    Colors.deepPurple.shade700,
                    Colors.indigo.shade700,
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[300]!,
                gap: 8,
                activeColor: Colors.orange,
                iconSize: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: Colors.white.withOpacity(0.3),
                color: Colors.white,
                tabs: const [
                   GButton(
                    icon: LineIcons.school,
                    text: 'Courses',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                   GButton(
                    icon: LineIcons.flask,
                    text: 'Periodic',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                   GButton(
                    icon: Icons.functions_outlined,
                    text: 'Formulas',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GButton(
                    icon: Icons.public,
                    text: 'SolarSys',
                    textStyle:  TextStyle(fontWeight: FontWeight.bold),
                    
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
