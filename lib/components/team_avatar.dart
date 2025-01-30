import 'package:flutter/material.dart';

class TeamAvatarImage extends StatelessWidget {
  final int year;
  final int teamNum;
  final double size;

  const TeamAvatarImage({
    super.key,
    required this.year,
    required this.teamNum,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://www.thebluealliance.com/avatar/$year/frc$teamNum.png',
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => Icon(
        Icons.groups,
        size: size,
      ),
    );
  }
}
