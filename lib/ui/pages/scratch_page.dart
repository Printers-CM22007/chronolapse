import 'package:flutter/material.dart';

// Ignoring because example file
// coverage:ignore-start
class ScratchPage extends StatefulWidget {
  const ScratchPage({super.key});

  @override
  State<ScratchPage> createState() => _ScratchPageState();
}

class _ScratchPageState extends State<ScratchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horizontal Scrollable Buttons')),
      body: Column(
        children: [
          // Horizontally scrollable buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                10,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Button $index'),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10), // Space between buttons and list
          // List of items
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                  leading: const Icon(Icons.list),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// coverage:ignore-end