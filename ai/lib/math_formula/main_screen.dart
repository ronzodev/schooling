import 'package:ai/math_formula/data_models.dart';
import 'package:ai/math_formula/formular_catergory.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MathFormulasScreen extends StatelessWidget {
  const MathFormulasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'Math Formulas',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppTheme.textPrimary),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCategoryCard(
                    context,
                    title: 'Algebra',
                    icon: Icons.functions_rounded,
                    color: AppTheme.accentBlue,
                    formulas: algebraFormulas,
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Geometry',
                    icon: Icons.architecture_rounded,
                    color: AppTheme.accentGreen,
                    formulas: geometryFormulas,
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Trigonometry',
                    icon: Icons.change_history_rounded,
                    color: AppTheme.accentOrange,
                    formulas: trigonometryFormulas,
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Calculus',
                    icon: Icons.trending_up,
                    color: AppTheme.accentPurple,
                    formulas: calculusFormulas,
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Statistics',
                    icon: Icons.bar_chart_rounded,
                    color: AppTheme.accentPink,
                    formulas: statisticsFormulas,
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
                    border: Border.all(color: color.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppTheme.textSecondary, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
