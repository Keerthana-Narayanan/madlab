import 'package:flutter/material.dart';

void main() {
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Rater',
      theme: ThemeData.dark(),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Simulated "database"
String? currentUserEmail;
final List<Map<String, dynamic>> reviews = [];
final List<String> watchlist = [];

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login(BuildContext context) {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      currentUserEmail = emailController.text.trim();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter credentials')));
    }
  }

  void register(BuildContext context) {
    login(context); // Just redirect without actual registration logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => login(context),
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () => register(context),
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> allMovies = [
    {
      "title": "Interstellar",
      "genre": "Sci-Fi",
      "release": "2014",
      "description": "Space adventure.",
    },
    {
      "title": "Inception",
      "genre": "Thriller",
      "release": "2010",
      "description": "Dream layers.",
    },
    {
      "title": "The Batman",
      "genre": "Action",
      "release": "2022",
      "description": "Dark Knight returns.",
    },
    {
      "title": "Avengers: Endgame",
      "genre": "Superhero",
      "release": "2019",
      "description": "Epic Marvel finale.",
    },
    {
      "title": "The Matrix",
      "genre": "Sci-Fi",
      "release": "1999",
      "description": "Reality is a simulation.",
    },
    {
      "title": "Titanic",
      "genre": "Romance",
      "release": "1997",
      "description": "Tragic love story on a sinking ship.",
    },
    {
      "title": "Joker",
      "genre": "Drama",
      "release": "2019",
      "description": "Origin of the Joker.",
    },
    {
      "title": "The Lion King",
      "genre": "Animation",
      "release": "1994",
      "description": "A lion cub’s journey to adulthood.",
    },
    {
      "title": "Dune",
      "genre": "Sci-Fi",
      "release": "2021",
      "description": "A noble family becomes embroiled in a war.",
    },
    {
      "title": "Top Gun: Maverick",
      "genre": "Action",
      "release": "2022",
      "description": "Return of the ace pilot.",
    },
  ];

  List<Map<String, String>> filteredMovies = [];

  @override
  void initState() {
    super.initState();
    filteredMovies = List.from(allMovies);
    searchController.addListener(_filterMovies);
  }

  void _filterMovies() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredMovies =
          allMovies
              .where(
                (movie) =>
                    movie['title']!.toLowerCase().contains(query) ||
                    movie['genre']!.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movies"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              currentUserEmail = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by title or genre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMovies.length,
              itemBuilder: (context, i) {
                final movie = filteredMovies[i];
                return ListTile(
                  title: Text(movie['title']!),
                  subtitle: Text("${movie['genre']} | ${movie['release']}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailPage(movie: movie),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MovieDetailPage extends StatelessWidget {
  final Map movie;
  final reviewController = TextEditingController();
  final ratingController = TextEditingController();

  MovieDetailPage({required this.movie});

  void submitReview(BuildContext context) {
    reviews.add({
      'email': currentUserEmail,
      'movie': movie['title'],
      'review': reviewController.text,
      'rating': double.tryParse(ratingController.text) ?? 0,
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Review Submitted")));
    reviewController.clear();
    ratingController.clear();
  }

  void saveToWatchlist(BuildContext context) {
    if (!watchlist.contains(movie['title'])) {
      watchlist.add(movie['title']);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Added to Watchlist")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Already in Watchlist")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['title']),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () => saveToWatchlist(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Genre: ${movie['genre']}"),
            Text("Release: ${movie['release']}"),
            SizedBox(height: 8),
            Text(movie['description'], style: TextStyle(fontSize: 16)),
            Divider(),
            Text(
              "Write a Review",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: reviewController,
              decoration: InputDecoration(labelText: "Review"),
            ),
            TextField(
              controller: ratingController,
              decoration: InputDecoration(labelText: "Rating (1-5)"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () => submitReview(context),
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  List<Map<String, dynamic>> getUserReviews() {
    return reviews.where((r) => r['email'] == currentUserEmail).toList();
  }

  List<String> getWatchlist() {
    return watchlist;
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = currentUserEmail ?? 'Guest';
    final userReviews = getUserReviews();
    final userWatchlist = getWatchlist();

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User: $userEmail"),
            SizedBox(height: 10),
            Text("Your Reviews", style: TextStyle(fontWeight: FontWeight.bold)),
            ...userReviews
                .map(
                  (r) => ListTile(
                    title: Text(r['movie']),
                    subtitle: Text("Rating: ${r['rating']}, ${r['review']}"),
                  ),
                )
                .toList(),
            SizedBox(height: 10),
            Text("Watchlist", style: TextStyle(fontWeight: FontWeight.bold)),
            ...userWatchlist.map((m) => ListTile(title: Text(m))).toList(),
          ],
        ),
      ),
    );
  }
}
