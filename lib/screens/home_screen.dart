import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_caching/data/movie_bloc/movie_bloc.dart';
import 'package:offline_caching/models/movie.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static Route route() => MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<MovieBloc>().add(DeleteAllMovies());
            },
            icon: const Icon(
              Icons.cancel_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (state is MovieLoaded) {
            return ListView.builder(
              itemCount: state.movies.length,
              itemBuilder: (context, index) {
                Movie movie = state.movies[index];
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
                            context.read<MovieBloc>().add(
                                  UpdateMovie(
                                    movie: movie.copyWith(
                                        addedToWatchLater:
                                            !movie.addedToWatchLater),
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
                            context
                                .read<MovieBloc>()
                                .add(DeleteMovie(movie: movie));
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
          } else {
            return const Center(
              child: Text('Unfortunatilry, Something went wrong'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showModalBottomSheet(
            context: context,
          );
        },
      ),
    );
  }

  // show sheet to insret a new movie
  _showModalBottomSheet({
    required BuildContext context,
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
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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

                      context.read<MovieBloc>().add(UpdateMovie(
                            movie: movie.copyWith(
                              name: nameController.text,
                              imageUrl: imageUrlController.text,
                            ),
                          ));
                      // moviesBox.put(
                      //   movie.id,
                      //   movie.copyWith(
                      //     name: nameController.text,
                      //     imageUrl: imageUrlController.text,
                      //   ),
                      // );
                    } else {
                      // Create a new Movie Object entry
                      Movie movie = Movie(
                        id: '${random.nextInt(1000)}',
                        name: nameController.text,
                        imageUrl: imageUrlController.text,
                      );

                      // insert it into cache
                      context.read<MovieBloc>().add(AddMovie(movie: movie));
                      // moviesBox.put(movie.id, movie);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
