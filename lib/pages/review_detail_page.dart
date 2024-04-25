import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/review_database.dart';
import '../model/review.dart';
import '../pages/edit_review_page.dart';

class ReviewDetailPage extends StatefulWidget {
  final int reviewId;

  const ReviewDetailPage({
    Key? key,
    required this.reviewId,
  }) : super(key: key);

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  late Review review;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshReview();
  }

  Future refreshReview() async {
    setState(() => isLoading = true);

    review = await ReviewDatabase.instance.readReview(widget.reviewId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Text(
            review.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat.yMMMd().format(review.createdTime),
            style: const TextStyle(color: Colors.white38),
          ),
          const SizedBox(height: 8),
          Text(
            review.description,
            style:
            const TextStyle(color: Colors.white70, fontSize: 18),
          )
        ],
      ),
    ),
  );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditReviewPage(review: review),
        ));

        refreshReview();
      });

  Widget deleteButton() => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () async {
      await ReviewDatabase.instance.delete(widget.reviewId);

      Navigator.of(context).pop();
    },
  );
}