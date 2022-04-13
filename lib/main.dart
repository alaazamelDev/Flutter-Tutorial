import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:offline_caching/data/movie_bloc/movie_bloc.dart';
import 'package:offline_caching/data/services/hive_database.dart';
import 'package:offline_caching/models/movie.dart';
import 'package:offline_caching/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());

  // Create an instance of HiveDatabase
  HiveDatabase hiveDatabase = HiveDatabase();
  await hiveDatabase.openBox(); // open box

  runApp(MyApp(
    hiveDatabase: hiveDatabase,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required HiveDatabase hiveDatabase,
  })  : _hiveDatabase = hiveDatabase,
        super(key: key);

  final HiveDatabase _hiveDatabase;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _hiveDatabase,
      child: BlocProvider(
        create: (context) => MovieBloc(
          // inject repository instance
          hiveDatabase: context.read<HiveDatabase>(),
        )..add(LoadMovies()),
        child: MaterialApp(
          title: 'Hive Caching',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
