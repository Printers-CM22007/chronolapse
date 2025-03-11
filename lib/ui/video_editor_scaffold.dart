import 'package:chronolapse/ui/example_page_one.dart';
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

class _ManualMarkerPlacerPageState extends State<ManualMarkerPlacerPage> with SingleTickerProviderStateMixin{
  double _opacity = 1.0;
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;

  final List<Map<String, dynamic>> _markers = [];
  int? _selectedMarkerIndex;
  bool _showMarkers = true;
  bool _isDragging = false;

  late TabController _tabController;

  int _currentIndex = 0;
  int _currentImageIndex = 0;

  final List<List<Map<String, dynamic>>> _markersForEachImage = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    for (int i = 0; i < _imagePaths.length; i++) {
        _markersForEachImage.add([]);
    }
  }

  final List<String> _imagePaths = [
    'assets/frames/landscape.jpeg',
    'assets/frames/clouds-country.jpg'
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Opacity',
            style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: _opacity,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: (_opacity * 100).round().toString(),
            onChanged: (v) => setState(() => _opacity = v)
        ),
      ],
    );
  }

  void _deleteImage(int index) {
    setState(() {
      if (_imagePaths.length == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ExamplePageOne(title: '',)));
      } else {
        _imagePaths.removeAt(index);
      }
    });
  }

  void _editMarkerDetails(int index) {
    final marker = _markersForEachImage[_currentImageIndex][index];
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
                    _markersForEachImage[_currentImageIndex][index] = {
                      'name': nameController.text,
                      'offset': Offset(newX, newY),
                      'colour': marker['colour'],
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

    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Tap image to place markers'),
              actions: [
                IconButton(
                    icon: Icon(_showMarkers ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() {_showMarkers = !_showMarkers;})
                )],
            ),

            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapUp: (details) {
                          if (!_showMarkers || _isDragging) return;
                          RenderBox box = context.findRenderObject() as RenderBox;
                          Offset localPosition = box.globalToLocal(details.globalPosition);
                          setState(() {
                            _markersForEachImage[_currentImageIndex].add({
                              'offset': localPosition,
                              'name': 'Marker ${_markersForEachImage[_currentImageIndex].length + 1}',
                              'colour': Colors.red,
                            });
                          });
                        },
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: _opacity,
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
                                  child: Image.asset(
                                      _imagePaths[_currentImageIndex],
                                      fit: BoxFit.cover,
                                  ),
                              ),
                            ),
                            ),
                            if (_showMarkers)
                              ..._markersForEachImage[_currentImageIndex].asMap().entries.map((entry) {
                                final index = entry.key;
                                final marker = entry.value;
                                final isSelectedMarker = index == _selectedMarkerIndex;
                                return Positioned(
                                    left: marker['offset'].dx - (isSelectedMarker ? 10 : 5),
                                    top: marker['offset'].dy - (isSelectedMarker ? 10 : 5),
                                    child: GestureDetector(
                                      onPanStart: (details) {
                                        setState(() {
                                          _isDragging = true;
                                        });
                                      },
                                      onPanUpdate: (DragUpdateDetails details) {
                                        RenderBox box = context.findRenderObject() as RenderBox;
                                        Offset newOffset = box.globalToLocal(details.globalPosition);
                                        setState(() {
                                          _markersForEachImage[_currentImageIndex][index]['offset'] = newOffset;
                                        });
                                      },
                                      onPanEnd: (details) {
                                        setState(() {
                                          _isDragging = false;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Icon(Icons.circle, color: marker['colour'], size: isSelectedMarker ? 20 : 10,),
                                          if (isSelectedMarker)
                                            Text(marker['name'], style: TextStyle(color: Colors.white, backgroundColor: Colors.black.withValues(alpha: 0.5)),)
                                        ],
                                      ),
                                    ));
                              }),

                          ],
                        ),
                      );
                    },
                  ),
                ),
                TabBar (
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Sliders'),
                    Tab(text: 'Markers'),
                    Tab(text: 'Frames',)
                  ],
                ),
                Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildAdjustmentSliders(),
                            ],
                          ),
                        ),
                        Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

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
                                      itemCount: _markersForEachImage[_currentImageIndex].length,
                                      itemBuilder: (context, index) {
                                        final marker = _markersForEachImage[_currentImageIndex][index];
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
                                                onPressed: () => setState(() => _markersForEachImage[_currentImageIndex].removeAt(index)),
                                              ),
                                              IconButton(
                                                  onPressed: () => _editMarkerDetails(index),
                                                  icon: const Icon(Icons.edit)
                                              ),
                                            ],),
                                          tileColor: _selectedMarkerIndex == index ? Colors.grey : null,
                                          onTap: () {
                                            setState(() {
                                              if (_selectedMarkerIndex != null) {
                                                _markersForEachImage[_currentImageIndex][_selectedMarkerIndex!]['colour'] = Colors.red;
                                              }

                                              _selectedMarkerIndex = index;

                                              _markersForEachImage[_currentImageIndex][index]['colour'] = Colors.orange;
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
                        ),
                        GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: _imagePaths.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                child: Card(
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                      contentPadding: EdgeInsets.all(8.0),
                                      leading: Image.asset(
                                        _imagePaths[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      title: Text('Image ${index + 1}'),
                                      trailing: IconButton(
                                        onPressed: () => _deleteImage(index),
                                        icon: Icon(Icons.delete),
                                      ),

                                    ),
                                ),
                              );
                            },
                        )
                      ],
                    )
                ),
                ]),
            bottomNavigationBar: BottomNavigationBar(
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });

                  if (index == 0) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ExamplePageOne(title: 'Huh?')));
                  }
                },
                items: const[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Settings'
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.camera_alt),
                      label: 'Take a photo'
                  ),
                ]
            ),
            ),

        );

  }
}
