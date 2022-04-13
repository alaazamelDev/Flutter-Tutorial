import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_caching/models/movie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static Route route() => MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Movie> moviesBox;

  @override
  void initState() {
    super.initState();
    // initialize box instance
    moviesBox = Hive.box('favorite_movies');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text('Home Screen'),
      ),
      body: ValueListenableBuilder(
        valueListenable: moviesBox.listenable(),
        builder: (context, Box<Movie> box, _) {
          // retrieve data from cache
          List<Movie> movies = box.values.toList().cast<Movie>();
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              Movie movie = movies[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: ListTile(
                  leading: Image.network(
                    movie.imageUrl,
                    width: 80,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(movie.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Add/Remove form watch later list
                          moviesBox.put(
                            movie.id,
                            movie.copyWith(
                              addedToWatchLater: !movie.addedToWatchLater,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.watch_later_rounded,
                          color: movie.addedToWatchLater
                              ? Colors.grey
                              : Colors.deepPurple,
                        ),
                        splashRadius: 20,
                      ),
                      IconButton(
                        onPressed: () {
                          _showModalBottomSheet(
                            context: context,
                            moviesBox: moviesBox,
                            movie: movie,
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                        ),
                        splashRadius: 20,
                      ),
                      IconButton(
                        onPressed: () {
                          // Delete movie entry
                          box.delete(movie.id);
                        },
                        icon: const Icon(
                          Icons.delete,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showModalBottomSheet(
            context: context,
            moviesBox: moviesBox,
          );
        },
      ),
    );
  }

  // show sheet to insret a new movie
  _showModalBottomSheet({
    required BuildContext context,
    required Box<Movie> moviesBox,
    Movie? movie,
  }) {
    Random random = Random();
    TextEditingController nameController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();

    if (movie != null) {
      nameController.text = movie.name;
      imageUrlController.text = movie.imageUrl;
    }

    showModalBottomSheet(
      isDismissible: true,
      elevation: 5,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(labelText: 'Movie'),
              ),
              TextField(
                controller: imageUrlController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (movie != null) {
                    // Update the current movie object
                    moviesBox.put(
                      movie.id,
                      movie.copyWith(
                        name: nameController.text,
                        imageUrl: imageUrlController.text,
                      ),
                    );
                  } else {
                    // Create a new Movie Object entry
                    Movie movie = Movie(
                      id: '${random.nextInt(1000)}',
                      name: nameController.text,
                      imageUrl: imageUrlController.text,
                      addedToWatchLater: false,
                    );

                    // insert it into cache
                    moviesBox.put(movie.id, movie);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
