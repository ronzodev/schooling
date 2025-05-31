import 'package:ai/math_formula/data_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

class FormulaCategoryScreen extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<MathFormula> formulas;

  const FormulaCategoryScreen({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.formulas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: formulas.length,
        itemBuilder: (context, index) {
          final formula = formulas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(icon, color: color),
              title: Text(
                formula.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (formula.latex != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TeXView( 
                            // Use proper LaTeX tags for inline or display formulas
                            child: TeXViewDocument("""
                              \\( ${formula.latex!} \\)
                            """,),  // For inline formula
                            // or use:
                            // child: TeXViewDocument("""
                            //   $$ ${formula.latex!} $$
                            // """), // For display-style formula
                            style: const TeXViewStyle(
                              contentColor: Colors.blueAccent,
                              backgroundColor: Color.fromARGB(0, 3, 2, 2),
                            ),
                          ),
                        ),
                      Text(formula.description),
                      if (formula.example != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Example: ${formula.example}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
