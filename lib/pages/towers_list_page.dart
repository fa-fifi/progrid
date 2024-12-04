import 'package:flutter/material.dart';
import 'package:progrid/models/providers/tower_provider.dart';
import 'package:progrid/models/tower.dart';
import 'package:progrid/pages/map_page.dart';
import 'package:progrid/pages/tower_page.dart';
import 'package:progrid/utils/themes.dart';
import 'package:provider/provider.dart';

class TowersListPage extends StatefulWidget {
  const TowersListPage({super.key});

  @override
  State<TowersListPage> createState() => _TowersListPageState();
}

class _TowersListPageState extends State<TowersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // on call search query
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final towersProvider = Provider.of<TowersProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Query Towers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // search bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Enter ID, name, address, region, etc...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // towers list
            // TODO: implement pagination callback to provider
            Expanded(
              child: StreamBuilder<List<Tower>>(
                stream: towersProvider.getTowersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading towers'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No towers available'));
                  }

                  final List<Tower> towers = snapshot.data!;
                  // filter towers based on search query
                  // note that this is a local list; no need to requery the entire database
                  final List<Tower> filteredTowers = towers
                      .where((tower) =>
                          tower.name.toLowerCase().contains(_searchQuery) ||
                          tower.address.toLowerCase().contains(_searchQuery) ||
                          tower.region.toLowerCase().contains(_searchQuery) ||
                          tower.owner.toLowerCase().contains(_searchQuery) ||
                          tower.id.toLowerCase().contains(_searchQuery))
                      .toList();

                  // display filtered towers
                  return filteredTowers.isEmpty
                      ? const Center(child: Text('No results found'))
                      : Scrollbar(
                          child: ListView.builder(
                            itemCount: filteredTowers.length,
                            itemBuilder: (context, index) {
                              final tower = filteredTowers[index];
                              return GestureDetector(
                                onTap: () {
                                  print("Tapped on tower: ${tower.id}");
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => TowerPage(towerId: tower.id),
                                      transitionsBuilder: (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SafeArea(
                                    minimum: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 70,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  // completion status
                                                  Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: tower.status == 'surveyed' ? AppColors.green : AppColors.red,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 7),
                                                  // tower id
                                                  Text(
                                                    tower.id,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // tower name
                                              Text(
                                                tower.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 0),
                                              Row(
                                                children: [
                                                  // owner
                                                  Text(
                                                    tower.owner,
                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    ",",
                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  // region
                                                  Text(
                                                    tower.region,
                                                    style: const TextStyle(
                                                        fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Expanded(
                                          flex: 10,
                                          child: Icon(
                                            Icons.arrow_right,
                                            size: 38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
                child: const Text(
              "or...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )),
            const SizedBox(height: 6),
            FilledButton(
              onPressed: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => MapPage(),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        }));
              },
              child: const Text("Open Map"),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
