import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:intersperse/intersperse.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/widgets.dart';
import 'package:thefluttercorner/features/dashboard/review.dart'; // Asegúrate de importar tu clase Review

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    const summaryCards = [
      SummaryCard(title: 'Total Sales', value: '\$125,000'),
      SummaryCard(title: 'Total Users', value: '12,000'),
      SummaryCard(title: 'KPI Progress Rate', value: '52.3%'),
    ];

    return ContentView(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Implementar acción para agregar una nueva reseña...
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Dashboard',
            description: 'A summary of key data and insights on your project.',
          ),
          const Gap(16),
          if (responsive.isMobile)
            ...summaryCards
          else
            Row(
              children: summaryCards
                  .map<Widget>((card) => Expanded(child: card))
                  .intersperse(const Gap(16))
                  .toList(),
            ),
          const Gap(16),
          Expanded(
            child: _ReviewsView(),
          ),
        ],
      ),
    );
  }
}

class _ReviewsView extends StatelessWidget {
  const _ReviewsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Asumimos que la decoración es para los bordes de las celdas encabezado
    final decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(color: theme.dividerColor),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No hay datos disponibles"));
          }
          final reviews = snapshot.data!.docs.map((doc) => Review.fromFirestore(doc)).toList();

          return TableView.builder(
            columnCount: Review.itemCount, // Asegúrate de que Review.itemCount refleje el número correcto de columnas
            rowCount: reviews.length + 1, // +1 por la fila de encabezado
            pinnedRowCount: 1,
            pinnedColumnCount: 0, // Asumimos que no hay columnas fijas aquí, ajusta según sea necesario
            columnBuilder: (index) => TableSpan(
              foregroundDecoration: index == 0 ? decoration : null,
              extent: const FractionalTableSpanExtent(1 / Review.itemCount), // Ajusta según el número de columnas
            ),
            rowBuilder: (index) => TableSpan(
              foregroundDecoration: index == 0 ? decoration : null,
              extent: const FixedTableSpanExtent(50),
            ),
            cellBuilder: (context, vicinity) {
              final isHeader = vicinity.xIndex == 0 || vicinity.yIndex == 0;
              String label;
              if (isHeader) {
                label = Review.getHeaderLabel(vicinity.xIndex); // Correcto para la cabecera
              } else {
                final review = reviews[vicinity.yIndex - 1];
                label = review.getLabelForIndex(vicinity.xIndex); // Esto debería funcionar correctamente para las filas
              }
              // Asegúrate de que este bloque está funcionando como esperas
              print("Label: $label"); // Agrega esta línea para depurar

              return TableViewCell(
                child: ColoredBox(
                  color: isHeader ? Colors.transparent : colorScheme.background,
                  child: Center(
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: isHeader ? FontWeight.w600 : null,
                            color: isHeader ? null : colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
