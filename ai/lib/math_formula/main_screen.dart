import 'package:ai/math_formula/data_models.dart';
import 'package:ai/math_formula/formular_catergory.dart';
import 'package:flutter/material.dart';

class MathFormulasScreen extends StatelessWidget {
  const MathFormulasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Formulas'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryCard(
            context,
            title: 'Algebra',
            icon: Icons.functions,
            color: Colors.blue,
            formulas: algebraFormulas,
          ),
          _buildCategoryCard(
            context,
            title: 'Geometry',
            icon: Icons.shape_line,
            color: Colors.green,
            formulas: geometryFormulas,
          ),
          _buildCategoryCard(
            context,
            title: 'Trigonometry',
            icon: Icons.change_history,
            color: Colors.orange,
            formulas: trigonometryFormulas,
          ),
          _buildCategoryCard(
            context,
            title: 'Calculus',
            icon: Icons.trending_up,
            color: Colors.purple,
            formulas: calculusFormulas,
          ),
          _buildCategoryCard(
            context,
            title: 'Statistics',
            icon: Icons.bar_chart,
            color: Colors.red,
            formulas: statisticsFormulas,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<MathFormula> formulas,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormulaCategoryScreen(
                title: title,
                color: color,
                icon: icon,
                formulas: formulas,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}