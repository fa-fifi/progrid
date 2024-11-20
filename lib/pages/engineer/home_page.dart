import 'package:flutter/material.dart';
import 'package:progrid/components/my_button.dart';
import 'package:progrid/components/my_loader.dart';
import 'package:progrid/services/objects/tower.dart';
import 'package:progrid/services/objects/user.dart';

class EngineerHomePage extends StatefulWidget {
  const EngineerHomePage({super.key});

  @override
  State<EngineerHomePage> createState() => _EngineerHomePageState();
}

class _EngineerHomePageState extends State<EngineerHomePage> {
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchTowers();
  }

  // Fetch towers
  Future<void> _fetchTowers() async {
    setState(() {
      _isFetching = true;
    });

    await TowerService().fetchTowers();

    setState(() {
      _isFetching = false;
    });
  }

  Widget _buildTowersList() {
    var towers = TowerService().getTowers();

    // If no towers found
    if (towers.isEmpty) {
      return const Center(child: Text('No towers available.'));
    }

    return ListView.builder(
      itemCount: towers.length,
      itemBuilder: (context, index) {
        var tower = towers[index];
        var inspections = tower.inspections;
        var issues = tower.issues;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            title: Text(tower.towerId),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${tower.status}'),
                if (inspections.isNotEmpty)
                  Text('Inspection Ticket Count: ${inspections.length}'),
                if (issues.isNotEmpty)
                  Text('Issue Ticket Count: ${issues.length}'),
              ],
            ),
            onTap: () {
              // TODO: navigate to tower page
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userInformation = UserInformation(); // user information singleton

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(40),
        child: _isFetching
            ? const Center(child: MyLoadingIndicator()) // Make sure loading indicator is centered
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Engineer Home Page",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Text("User ID: ${userInformation.userId}"),
                  Text("Email: ${userInformation.email}"),
                  Text("User Type: ${userInformation.userType}"),

                  const SizedBox(height: 20),

                  // logout button
                  MyButton(
                    onTap: UserInformation().logout,
                    text: "Logout",
                  ),

                  const SizedBox(height: 24),

                  // Ensure that the ListView is properly constrained
                  Expanded(child: _buildTowersList()), // Wrapping ListView with Expanded
                ],
              ),
      ),
    );
  }
}
