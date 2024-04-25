import 'package:flutter/material.dart';
import '../db/review_database.dart';
import '../model/review.dart';
import '../widget/review_form_widget.dart';

class AddEditReviewPage extends StatefulWidget {
  final Review? review;

  const AddEditReviewPage({
    Key? key,
    this.review,
  }) : super(key: key);

  @override
  State<AddEditReviewPage> createState() => _AddEditReviewPageState();
}

class _AddEditReviewPageState extends State<AddEditReviewPage> {
  final _formKey = GlobalKey<FormState>();
  late bool isImportant;
  late int number;
  late String title;
  late String description;

  @override
  void initState() {
    super.initState();

    isImportant = widget.review?.isImportant ?? false;
    number = widget.review?.number ?? 0;
    title = widget.review?.title ?? '';
    description = widget.review?.description ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: ReviewFormWidget(
        isImportant: isImportant,
        number: number,
        title: title,
        description: description,
        onChangedImportant: (isImportant) =>
            setState(() => this.isImportant = isImportant),
        onChangedNumber: (number) => setState(() => this.number = number),
        onChangedTitle: (title) => setState(() => this.title = title),
        onChangedDescription: (description) =>
            setState(() => this.description = description),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty && description.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateNote,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.review != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.review!.copy(
      isImportant: isImportant,
      number: number,
      title: title,
      description: description,
    );

    await ReviewDatabase.instance.update(note);
  }

  Future addNote() async {
    final note = Review(
      title: title,
      isImportant: true,
      number: number,
      description: description,
      createdTime: DateTime.now()
    );

    await ReviewDatabase.instance.create(note);
  }
}