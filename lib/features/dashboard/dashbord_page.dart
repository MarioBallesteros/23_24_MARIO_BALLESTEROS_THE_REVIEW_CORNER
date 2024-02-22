import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:intersperse/intersperse.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:thefluttercorner/features/dashboard/reviewPage.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../../widgets/widgets.dart';
import 'package:thefluttercorner/features/dashboard/review.dart';

import 'ReviewDetailsPage.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({Key? key}) : super(key: key);

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
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ReviewPage(review: Review(
              reviewId: '',
              title: '',
              reviewText: '',
              rating: 0.0,
              userId: '',
              creationDate: Timestamp.now(), imageUrls: [],
            ))),
          );
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
  const _ReviewsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No hay datos disponibles"));
          }
          final reviews = snapshot.data!.docs.map((doc) => Review.fromFirestore(doc)).toList();

          return TableView.builder(
            columnCount: Review.itemCount,
            rowCount: reviews.length + 1,
            pinnedRowCount: 1,
            pinnedColumnCount: 0,
            columnBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(200)),
            rowBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(60)),
            cellBuilder: (context, vicinity) {
              final isHeader = vicinity.yIndex == 0;
              String label = isHeader ? Review.getHeaderLabel(vicinity.xIndex) : reviews[vicinity.yIndex - 1].getLabelForIndex(vicinity.xIndex);

              return TableViewCell(
                child: InkWell(
                  onTap: isHeader ? null : () {
                    // Navegar a la página de detalles de la review con la review seleccionada
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ReviewDetailsPage(review: reviews[vicinity.yIndex - 1])),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
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


