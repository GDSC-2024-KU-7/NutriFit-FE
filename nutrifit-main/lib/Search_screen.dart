import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: SearchPage(),
  ));
}

class SearchPage extends StatelessWidget {
  final List<String> words = ['m-burger', 'c-burger', 'p-burger', 'l-burger'];

  @override
  Widget build(BuildContext context) {
    return SearchScreen(words: words);
  }
}

class SearchScreen extends StatefulWidget {
  final List<String> words;

  SearchScreen({required this.words});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String>? _matchingWords;

  void _searchWords(String query) {
    setState(() {
      _matchingWords =
          widget.words.where((word) => word.contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(
          child: Text(
            'NutriFit',
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search'),
              onChanged: (query) {
                _searchWords(query);
              },
            ),
            _matchingWords != null
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _matchingWords!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_matchingWords![index]),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  word: _matchingWords![index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                : _buildGridBoxes(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'my page',
          ),
        ],
      ),
    );
  }

  Widget _buildGridBoxes() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      padding: EdgeInsets.all(24.0),
      itemCount: ['농수산물', '수산물', '가공식품', '음식'].length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetailScreen(word: ['농수산물', '수산물', '가공식품', '음식'][index]),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              border: Border.all(),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(['농수산물', '수산물', '가공식품', '음식'][index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColoredBox(String word) {
    return Container(
      margin: EdgeInsets.all(15),
      width: 131,
      height: 103,
      color: Colors.amber,
      child: TextButton(
        onPressed: () {
          filterWords(word);
        },
        child: Text(word),
      ),
    );
  }

  void filterWords(String keyword) {
    setState(() {
      _matchingWords =
          widget.words.where((word) => word.contains(keyword)).toList();
    });
    // Navigate to detail page with filteredWords
  }
}

class DetailScreen extends StatelessWidget {
  final String word;

  DetailScreen({required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'NutriFit',
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
      body: Center(
        child: Text('Detail for $word'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'my page',
          ),
        ],
      ),
    );
  }
}
