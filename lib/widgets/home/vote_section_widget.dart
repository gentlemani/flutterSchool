import 'package:flutter/material.dart';
import 'package:eatsily/widgets/home/build_vote_section_widget.dart';

class VoteSection extends StatelessWidget {
  final String recipeId;
  final String userId;
  final int likesCount;
  final int dislikesCount;

  const VoteSection({
    super.key,
    required this.recipeId,
    required this.userId,
    required this.likesCount,
    required this.dislikesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("¡Valora esta receta!"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BuildVoteSection(recipeId: recipeId, userId: userId, currentVotes: likesCount, isLike: true),
            BuildVoteSection(recipeId: recipeId,userId: userId,currentVotes: dislikesCount,isLike: false),
          ],
        ),
      ],
    );
  }

}
