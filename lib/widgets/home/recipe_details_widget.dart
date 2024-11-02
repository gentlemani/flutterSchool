import 'package:flutter/material.dart';
import 'package:eatsily/widgets/home/image_loader_widget.dart';
import 'package:eatsily/widgets/home/build_vote_section_widget.dart';

class RecipeDetails extends StatelessWidget {
  final Map<String, dynamic> recipeData;
  final String recipeId;
  final String userId;

  const RecipeDetails({super.key, required this.recipeData, required this.recipeId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final String name = recipeData['name'] as String? ?? 'Nombre no disponible';
    final int likesCount = recipeData['likes'] as int? ?? 0;
    final int dislikesCount = recipeData['dislikes'] as int? ?? 0;
    final String imagePath = recipeData['image'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ImageLoader(imagePath: imagePath, recipeId: recipeId),
        Text(
          name,
          style: const TextStyle(fontSize: 20),
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
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