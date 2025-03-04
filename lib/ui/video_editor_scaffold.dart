import 'package:flutter/material.dart';

class VideoEditor extends StatelessWidget {
  const VideoEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Editor Scaffold',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const ManualMarkerPlacerPage(),
    );
  }
}

class ManualMarkerPlacerPage extends StatefulWidget {
  const ManualMarkerPlacerPage({super.key});

  @override
  _ManualMarkerPlacerPageState createState() => _ManualMarkerPlacerPageState();
// const ManualMarkerPlacerPage({super.key});
}

class _ManualMarkerPlacerPageState extends State<ManualMarkerPlacerPage> {
  double _opacity = 1.0;
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;

  final List<Map<String, dynamic>> _markers = [];
  int? _selectedMarkerIndex;

  Widget _buildAdjustmentSliders() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
              'Brightness',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: _brightness,
            min: -1.0,
            max: 1.0,
            divisions: 200,
            label: (_brightness * 100).round().toString(),
            // label: 'Brightness: ${_brightness.toStringAsFixed(2)}',
            onChanged: (v) => setState(() => _brightness = v)

        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Contrast',
            style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: _contrast,
            min: 0.0,
            max: 2.0,
            divisions: 200,
            label: ((_contrast * 100) - 100).round().toString(),
            onChanged: (v) => setState(() => _contrast = v)
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
              'Saturation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: _saturation,
            min: 0.0,
            max: 2.0,
            divisions: 200,
            label: ((_saturation * 100) - 100).round().toString(),
            onChanged: (v) => setState(() => _saturation = v)
        ),
      ],
    );
  }

  void _editMarkerDetails(int index) {
    final marker = _markers[index];
    final TextEditingController nameController = TextEditingController(
      text: marker['name'],
    );
    final TextEditingController xController = TextEditingController(
      text: marker['offset'].dx.toStringAsFixed(2),
    );
    final TextEditingController yController = TextEditingController(
      text: marker['offset'].dy.toStringAsFixed(2),
    );


    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rename Marker'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: xController,
                  decoration: const InputDecoration(labelText: 'X Coordinate'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: yController,
                  decoration: const InputDecoration(labelText: 'Y Coordinate'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')
            ),
            TextButton(
                onPressed: () {
                  final newX = double.tryParse(xController.text) ?? marker['offset'].dx;
                  final newY = double.tryParse(yController.text) ?? marker['offset'].dy;

                  setState(() {
                    _markers[index] = {
                      'name': nameController.text,
                      'offset': Offset(newX, newY),
                    };
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save')),
            ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Tap image to place markers')),
        body: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    RenderBox box = context.findRenderObject() as RenderBox;
                    Offset localPosition = box.globalToLocal(details.globalPosition);
                    setState(() {
                      _markers.add({
                        'offset': localPosition,
                        'name': 'Marker ${_markers.length + 1}',
                      });
                    });
                  },
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: _opacity,
                        // child: Image.asset('assets/landscape.jpeg'),
                        child: ColorFiltered(
                            colorFilter: ColorFilter.matrix([
                              _contrast, 0, 0, 0, _brightness * 255,
                              0, _contrast, 0, 0, _brightness * 255,
                              0, 0, _contrast, 0, _brightness * 255,
                              0, 0, 0, 1, 0,
                            ]),
                          child: ColorFiltered(
                              colorFilter: ColorFilter.matrix([
                                0.2126 + 0.7874 * _saturation, 0.7152 - 0.7152 * _saturation, 0.0722 - 0.0722 * _saturation, 0, 0,
                                0.2126 - 0.2126 * _saturation, 0.7152 + 0.2848 * _saturation, 0.0722 - 0.0722 * _saturation, 0, 0,
                                0.2126 - 0.2126 * _saturation, 0.7152 - 0.7152 * _saturation, 0.0722 + 0.9278 * _saturation, 0, 0,
                                0, 0, 0, 1, 0,
                                
                              ]),
                            child: Image.asset('assets/landscape.jpeg'),
                          ),
                        ),
                      ),
                      ..._markers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final marker = entry.value;
                        return Positioned(
                            left: marker['offset'].dx - 5,
                            top: marker['offset'].dy - 5,
                            child: GestureDetector(
                              onPanUpdate: (DragUpdateDetails details) {
                                RenderBox box = context.findRenderObject() as RenderBox;
                                Offset newOffset = box.globalToLocal(details.globalPosition);
                                setState(() {
                                  _markers[index]['offset'] = newOffset;
                                });
                              },
                              child: const Icon(Icons.circle, color: Colors.red, size: 10,),
                            ));
                      })
                    ],
                  ),

                );
              },
            ),
            Padding(
              padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildAdjustmentSliders(),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Opacity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),),
                  ),
                  Slider(
                    value: _opacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: (_opacity * 100).round().toString(),
                    onChanged: (v) => setState(() => _opacity = v )
                  ),
                ],
              ),

            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Your Markers',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold
                      ),),

                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.grey,),
                  Expanded(
                    child: ListView.builder(
                    itemCount: _markers.length,
                    itemBuilder: (context, index) {
                      final marker = _markers[index];
                      return ListTile(
                        title: Text(marker['name']),
                        subtitle: Text('''
    X is ${marker['offset'].dx.toStringAsFixed(2)}
    Y is ${marker['offset'].dy.toStringAsFixed(2)}'''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => setState(() => _markers.removeAt(index)),
                              ),
                            IconButton(
                              onPressed: () => _editMarkerDetails(index),
                              icon: const Icon(Icons.edit)
                              ),
                            ],),
                        onTap: () {
                          setState(() {
                            _selectedMarkerIndex = index;
                          });
                        },
                  );
                },
              ),
                  ),
                ],
              ),

            ),
          ],
        ));
  }
}


