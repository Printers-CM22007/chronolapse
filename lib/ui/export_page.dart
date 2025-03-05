import 'package:chronolapse/ui/example_page_two.dart';
import 'package:flutter/material.dart';

class ExportPage extends StatefulWidget {
  final String _projectName;

  const ExportPage(this._projectName, {super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Export"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Go to previous page'),
              subtitle: const Text('Goes to video preview'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    // placeholder below for previous page!!!!!!!!!!!!!!!!!!!
                    builder: (context) => const ExamplePageTwo()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download timelapse'),
              subtitle: const Text('Saves video to camera roll'),
              onTap: () {
                // save video to device
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share timelapse'),
              subtitle: const Text(
                  'Send your timelapse to someone or upload it to social media'),
              onTap: () {
                // share video with built in OS functionality
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Download Frames'),
              subtitle: const Text(
                  'Download a folder containing all the individual frames of the timelapse'),
              onTap: () {
                // download all frames individually
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              // placeholder below for home page!!!!!!!!!!!!!!!!!!!
              builder: (context) => const ExamplePageTwo()));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.home),
      ),
    );
  }
}
