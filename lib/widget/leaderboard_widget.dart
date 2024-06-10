import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minesweeper/modele/utils.dart';
import 'package:minesweeper/riverpod/providers.dart';

class LeaderboardWidget extends ConsumerStatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends ConsumerState<LeaderboardWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: FutureBuilder<Map<String, int>>(
        future: ref.watch(leaderboardNotifierProvider.notifier).getSortedLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          } else {
            final leaderboardData = snapshot.data;
            if (leaderboardData != null && leaderboardData.isNotEmpty) {
              List<MapEntry<String, int>> entries = leaderboardData.entries.toList();
              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      ref.read(leaderboardNotifierProvider.notifier).removeFromLeaderboard(entry.key);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        leading: getTrophyWidget(index),
                        title: Text(
                          entry.key,
                        ),
                        trailing: Text(
                          '${entry.value}',
                          
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text("Aucune donnée trouvée."));
            }
          }
        },
      ),
    );
  }

  Widget getTrophyWidget(int index) {
    index++;
    if (index == 1 || index == 2 || index == 3) {
      return Icon(Icons.emoji_events, color: getColorTrophee(index));
    } else {
      return Text(index.toString(),style: Theme.of(context).textTheme.titleLarge,);
    }
  }
}
