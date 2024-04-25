import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../db/review_database.dart';
import '../model/review.dart';
import '../pages/edit_review_page.dart';
import '../pages/review_detail_page.dart';
import '../widget/review_card_widget.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late List<Review> reviews;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshReviews();
  }

  @override
  void dispose() {
    ReviewDatabase.instance.close();

    super.dispose();
  }

  Future refreshReviews() async {
    setState(() => isLoading = true);

    reviews = await ReviewDatabase.instance.readAllReviews();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Notes',
        style: TextStyle(fontSize: 24),
      ),
      actions: const [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
          ? const CircularProgressIndicator()
          : reviews.isEmpty
          ? const Text(
        'No Reviews Yet',
        style: TextStyle(color: Colors.white, fontSize: 24),
      )
          : buildReviews(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.grey[100],
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditReviewPage()),
        );

        refreshReviews();
      },
    ),
  );


  Widget buildReviews() => StaggeredGridView.countBuilder(
    padding: const EdgeInsets.all(8),
    itemCount: reviews.length,
    staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    crossAxisCount: 4,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    itemBuilder: (context, index) {
      final review = reviews[index];

      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ReviewDetailPage(reviewId: review.id!),
          ));

          refreshReviews();
        },
        child: ReviewCardWidget(review: review, index: index),
      );
    },
  );
}