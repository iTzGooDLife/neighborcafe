import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double maxRating;
  final IconData filledStar;
  final IconData unfilledStar;
  final Color color;
  final double size;

  StarRating({
    required this.rating,
    this.maxRating = 5,
    this.filledStar = Icons.star,
    this.unfilledStar = Icons.star_border,
    this.color = Colors.amber,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];
    for (int i = 1; i <= maxRating; i++) {
      stars.add(Icon(
        i <= rating ? filledStar : unfilledStar,
        color: color,
        size: size,
      ));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double fraction;

  _StarClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
