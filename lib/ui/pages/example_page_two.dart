import 'package:flutter/material.dart';

// Ignoring because file is an example
// coverage:ignore-start
class ExamplePageTwo extends StatefulWidget {
  const ExamplePageTwo({super.key});

  @override
  State<ExamplePageTwo> createState() => _ExamplePageTwoState();
}

class _ExamplePageTwoState extends State<ExamplePageTwo> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Example Page 2"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Go to back'),
              subtitle: const Text(
                  'You can also use the normal Android back button/gesture'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
// coverage:ignore-end