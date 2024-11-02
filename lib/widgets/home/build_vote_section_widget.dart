import 'package:eatsily/screens/session/widget_tree.dart';
import 'package:eatsily/services/database_service.dart';
import 'package:eatsily/utils/auth.helpers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuildVoteSection extends StatelessWidget {
  final String recipeId;
  final String userId;
  final int currentVotes;
  final bool isLike;
  final DatabaseService _databaseService = DatabaseService();

  BuildVoteSection({
    super.key,
    required this.recipeId,
    required this.userId,
    required this.currentVotes,
    required this.isLike,
  });

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<DocumentSnapshot>(
      stream: _databaseService.getUserVoteStream(recipeId, userId),
      builder: (context, voteSnapshot) {
        if (voteSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (voteSnapshot.hasError) {
          return Center(child: Text('Error: ${voteSnapshot.error}'));
        }

        bool? userVote;
        var voteData = voteSnapshot.data?.data() as Map<String, dynamic>?;
        userVote = voteData?['vote'] as bool?;

        return _buildVoteRow(context, userVote);
      },
    );
  }

  Row _buildVoteRow(BuildContext context, bool? userVote) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$currentVotes', style: const TextStyle(fontSize: 17)),
        IconButton(
          iconSize: 25,
          icon: Icon(
            isLike
                ? (userVote == true
                    ? Icons.thumb_up_alt
                    : Icons.thumb_up_alt_outlined)
                : (userVote == false
                    ? Icons.thumb_down_alt
                    : Icons.thumb_down_alt_outlined),
            color: isLike
                ? (userVote == true ? Colors.blue : null)
                : (userVote == false ? Colors.red : null),
          ),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await _databaseService.voteRecipe(recipeId, userId, isLike);
            } else {
              handleLogout(context, redirectTo: const WidgetTree());
            }
          },
        ),
      ],
    );
  }
}
