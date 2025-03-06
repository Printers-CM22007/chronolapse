import 'package:chronolapse/ui/example_page_two.dart';
import 'package:chronolapse/ui/picture_taking_page.dart';
import 'package:chronolapse/ui/settings_page.dart';
import 'package:chronolapse/ui/shared/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'dashboard_page.dart';

class ExamplePageOne extends StatefulWidget {
  const ExamplePageOne(this.title, {super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ExamplePageOne> createState() => _ExamplePageOneState();
}

class _ExamplePageOneState extends State<ExamplePageOne> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          // mainAxisAlignment: MainAxisAlignment.start,

          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.arrow_forward),
              title: const Text('Go to other page'),
              subtitle: const Text('Goes to example page 2'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ExamplePageTwo()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward),
              title: const Text('Go to db page'),
              subtitle: const Text('Goes to db'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DashboardPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward),
              title: const Text('Go to picture taking page'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PictureTakingPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward),
              title: const Text('Go to settings page'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsPage("testProject")));
              },
            ),
            const Divider(),
            const Center(
              child: Text(
                'You have pushed the button this many times:',
              ),
            ),
            Center(
              child: Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const Divider(),
            VideoPlayerWidget(
                VideoPlayerController.networkUrl(Uri.parse(
                    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4')),
                forcedAspectRatio: 2.0 / 1.0)
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
