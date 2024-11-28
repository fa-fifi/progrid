import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progrid/models/tower_provider.dart';
import 'package:progrid/pages/issue_creation_page.dart';
import 'package:progrid/utils/themes.dart';
import 'package:provider/provider.dart';

class IssuesListPage extends StatefulWidget {
  // TODO: implement callback system
  final String towerId; // id of selected tower

  const IssuesListPage({super.key, required this.towerId});

  @override
  State<IssuesListPage> createState() => _IssuesListPageState();
}

class _IssuesListPageState extends State<IssuesListPage> {
  late Tower selectedTower;

  @override
  Widget build(BuildContext context) {
    final towersProvider = Provider.of<TowersProvider>(context);

    // fetch tower from provider
    selectedTower = towersProvider.towers.firstWhere(
      (tower) => tower.id == widget.towerId,
      orElse: () => throw Exception('Tower not found'),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget.towerId,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            const Text(
              "Site Issues",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 0),

            // new issue ticket link
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IssueCreationPage(towerId: selectedTower.id),
                    ));
              },
              child: Text(
                "Create New Ticket",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // issues list
            Expanded(
              child: ListView.builder(
                itemCount: selectedTower.issues.length,
                itemBuilder: (context, index) {
                  final issue = selectedTower.issues[index];

                  // tags
                  final String tagsDisplay = issue.tags.join(', '); // no null check needed

                  return GestureDetector(
                    onTap: () {
                      // TODO: implement view individual issue page
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SafeArea(
                        minimum: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // left
                            Expanded(
                              flex: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // status indicator
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: issue.status == 'resolved' ? AppColors.green : AppColors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 7),

                                      // issue id
                                      Text(
                                        issue.id,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      )
                                    ],
                                  ),

                                  // issue tag
                                  Text(
                                    tagsDisplay,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Text(
                                        issue.authorName,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ', ',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${issue.status[0].toUpperCase()}${issue.status.substring(1)}',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),

                            // right
                            Expanded(
                              flex: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // date time
                                  Text(
                                    DateFormat('dd/MM/yy').format(issue.dateTime.toDate()),
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Icon(
                                    Icons.arrow_right,
                                    size: 36,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
