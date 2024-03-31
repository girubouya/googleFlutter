import 'dart:js';

import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAppState()),
        ChangeNotifierProvider(create: (context) => VisibilityState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 0, 25)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Map<String, dynamic> word = {
    "pair": WordPair.random(),
    "opacity": 1.0,
  };

  void getNext() {
    word["pair"] = WordPair.random();
    notifyListeners();
  }

  var wordLists = <Map<String, dynamic>>[];
  var favorutes = <WordPair>[];
  void toggleFavorite() {
    if (favorutes.contains(word["pair"])) {
      favorutes.remove(word["pair"]);
    } else {
      favorutes.add(word["pair"]);
    }
    notifyListeners();
  }

  void downOpacity(List<Map<String, dynamic>> wordLists) {
    wordLists.asMap().forEach((key, value) {
      value["opacity"] -= 0.2;
    });
    notifyListeners();
  }
}

class VisibilityState extends ChangeNotifier {
  var visibility = false;

  void toggleVisibility() {
    visibility = !visibility;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget? page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
        defauled:
        throw UnimplementedError('no Widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                      icon: Icon(Icons.home), label: Text('Home')),
                  NavigationRailDestination(
                      icon: Icon(Icons.favorite), label: Text('Like')),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            )
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var word = appState.word;
    IconData icon;
    if (appState.favorutes.contains(word['word'])) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: Container(
              width: 150,
              color: Colors.greenAccent,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 100,
                height: (appState.wordLists.length * 20) + 20,
                child: Container(
                  child: ListView(
                    reverse: false,
                    children: [
                      for (var word in appState.wordLists)
                        SizedBox(
                          height: 40,
                          child: Card(
                            color: Colors.redAccent,
                            child: Text(word["pair"].toString()),
                          ),
                        )
                    ],
                  ),
                ),
              )),
        ),
        Expanded(
          child: Container(
            color: Colors.blueAccent,
            child: Column(
              children: [
                BigCard(pair: word["pair"]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          appState.getNext();
                          appState.wordLists.add(word);
                          appState.downOpacity(appState.wordLists);
                        },
                        icon: Icon(Icons.next_plan),
                        label: Text('next')),
                    ElevatedButton.icon(
                        onPressed: () {
                          appState.toggleFavorite();
                        },
                        icon: Icon(icon),
                        label: Text('good'))
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class FavoritePage extends StatefulWidget {
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favoriteList = appState.favorutes;

    if (favoriteList.isEmpty) {
      return Center(
        child: Text('not Data'),
      );
    }

    return Container(
        child: ListView(
      children: [
        for (var list in favoriteList)
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(255, 255, 82, 139),
            ),
            child: SizedBox(
              height: 50,
              child: ListTile(
                leading: Icon(Icons.favorite),
                trailing: GestureDetector(
                  child: Icon(Icons.delete_forever),
                  onTap: () {
                    setState(() {
                      favoriteList.remove(list);
                    });
                  },
                ),
                title: Text('$list'),
              ),
            ),
          )
      ],
    ));
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      elevation: 10.0,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
