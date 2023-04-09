import 'package:flutter/material.dart';

void main() {
  runApp(const LunchMenuApp());
}

class LunchMenuApp extends StatelessWidget {
  const LunchMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData();
    final ThemeData darkTheme = ThemeData.dark();

    return MaterialApp(
      title: 'Lunch App',
      theme: lightTheme.copyWith(
        colorScheme: lightTheme.colorScheme.copyWith(secondary: Colors.blue),
      ),
      darkTheme: darkTheme.copyWith(
        colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.blue),
      ),
      themeMode: ThemeMode.dark,
      home: const HomePage(title: 'Lunch Menu App'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                "Today, Monday xx.xx.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            CourseCardWidget(
              courseName: "Salad Salad Salad Salad",
              allergens: "G L",
            ),
            CourseCardWidget(
              courseName: "Soup Soup Soup Soup",
              allergens: "G",
            ),
            CourseCardWidget(
              courseName: "Main Main Main Main",
              allergens: "",
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCardWidget extends StatelessWidget {
  final String courseName;
  final String allergens;

  const CourseCardWidget({super.key, required this.courseName, required this.allergens});

  Icon getMenuTypeIcon(String courseName) {
    if (courseName.toLowerCase().contains("salad")) {
      return const Icon(
        Icons.restaurant_menu,
        color: Colors.green,
        size: 40,
      );
    } else if (courseName.toLowerCase().contains("soup")) {
      return const Icon(
        Icons.restaurant,
        color: Colors.red,
        size: 40,
      );
    } else {
      return const Icon(
        Icons.egg,
        color: Colors.cyan,
        size: 40,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getMenuTypeIcon(courseName),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseName),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (allergens.contains("L"))
                      Icon(
                        Icons.mail,
                        color: Colors.blue.shade800,
                      ),
                    if (allergens.contains("G"))
                      Icon(
                        Icons.mail,
                        color: Colors.orange.shade400,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
