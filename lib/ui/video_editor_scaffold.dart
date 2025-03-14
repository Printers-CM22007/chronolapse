import 'package:chronolapse/ui/shared/instant_page_route.dart';
import 'package:flutter/material.dart';
import 'package:chronolapse/ui/dashboard_page.dart';
import 'package:chronolapse/ui/settings_page.dart';
import 'package:chronolapse/ui/photo_taking_page.dart';

// TODO: change the main file to show the dashboard first, not the editting page
// TODO: the code crashes if a page with markers on it is deleted

// class VideoEditor extends StatelessWidget {
//   const VideoEditor({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Editor Scaffold',
//       theme: ThemeData(
//         primarySwatch: Colors.purple,
//       ),
//       home: const FrameEditor("sampleProject"),
//     );
//   }
// }

class FrameEditor extends StatefulWidget {
  final String _projectName;

  const FrameEditor(this._projectName, {super.key});

  @override
  _FrameEditorState createState() => _FrameEditorState();
}

class _FrameEditorState extends State<FrameEditor> with SingleTickerProviderStateMixin{
  double opacity = 0.3;
  double brightness = 0.0;
  double contrast = 1.0;
  double saturation = 1.0;
  double balanceFactor = 0.0;



  // final List<Map<String, dynamic>> markers = [];
  int? selectedMarkerIndex;
  bool showMarkers = true;
  bool isDragging = false;

  late TabController tabController;

  int currentIndex = 0;
  int currentImageIndex = 0;


  String _pageTitle = 'Tap image to place markers';
  late String _respectiveName;

  final List<List<Map<String, dynamic>>> markersForEachImage = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);

    for (int i = 0; i < imagePaths.length; i++) {
        markersForEachImage.add([]);
    }
  }

  final List<String> imagePaths = [
    'assets/frames/landscape.jpeg',
    'assets/frames/clouds-country.jpg',
    'assets/frames/SaxonyLandscape.jpg',
  ];

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }


  Widget buildAdjustmentSliders() {
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
            value: brightness,
            min: -1.0,
            max: 1.0,
            divisions: 200,
            label: (brightness * 100).round().toString(),
            // label: 'Brightness: ${_brightness.toStringAsFixed(2)}',
            onChanged: (v) => setState(() => brightness = v)

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
            value: contrast,
            min: 0.0,
            max: 2.0,
            divisions: 200,
            label: ((contrast * 100) - 100).round().toString(),
            onChanged: (v) => setState(() => contrast = v)
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'White Balance',
            style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: balanceFactor,
            min: -0.4,
            max: 0.4,
            divisions: 20,
            // label: ((contrast * 100) - 100).round().toString(),
            onChanged: (v) => setState(() => balanceFactor = v)
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
              'Saturation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: saturation,
            min: 0.0,
            max: 2.0,
            divisions: 200,
            label: ((saturation * 100) - 100).round().toString(),
            onChanged: (v) => setState(() => saturation = v)
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Overlay Opacity Control',
            style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Slider(
            value: opacity,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: (opacity * 100).round().toString(),
            onChanged: (v) => setState(() => opacity = v)
        ),
      ],
    );
  }

  void deleteImage(int index) {
    setState(() {
      if (imagePaths.length == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
      } else {
        imagePaths.removeAt(index);
      }
    });
  }

  void editMarkerDetails(int index) {
    final marker = markersForEachImage[currentImageIndex][index];
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
                    markersForEachImage[currentImageIndex][index] = {
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
              title: Text(_pageTitle),
              actions: [
                IconButton(
                    icon: Icon(showMarkers ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() {showMarkers = !showMarkers;})
                )],
            ),

            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapUp: (details) {
                          if (!showMarkers || isDragging) return;// || !(currentImageIndex == 0)) return;
                          RenderBox box = context.findRenderObject() as RenderBox;
                          Offset localPosition = box.globalToLocal(details.globalPosition);
                          setState(() {
                            if (currentImageIndex == 0) {
                              _respectiveName = 'Marker ${markersForEachImage[currentImageIndex].length + 1}';
                              markersForEachImage[currentImageIndex].add({
                                'offset': localPosition,
                                'name': _respectiveName,
                                'colour': Colors.red,
                              });
                            }
                            if (currentImageIndex > 0) {
                              _respectiveName = (markersForEachImage[currentImageIndex - 1][markersForEachImage[currentImageIndex ].length]['name']);
                              markersForEachImage[currentImageIndex].add({
                              'offset': localPosition,
                              'name': _respectiveName,
                              'colour': Colors.red,
                              });
                              if (markersForEachImage[currentImageIndex].length != markersForEachImage[currentImageIndex - 1].length) {
                                _respectiveName = (markersForEachImage[currentImageIndex - 1][markersForEachImage[currentImageIndex ].length]['name']);
                              _pageTitle = 'Place marker "$_respectiveName"';
                              } else {
                              _pageTitle = 'Drag the markers into place';// or move to the next frame';
                              }
                            }


                          });
                        },
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: 1,
                              child: ColorFiltered(
                                colorFilter: ColorFilter.matrix([
                                  contrast, 0, 0, 0, brightness * 255,
                                  0, contrast, 0, 0, brightness * 255,
                                  0, 0, contrast, 0, brightness * 255,
                                  0, 0, 0, 1, 0,
                                ]),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.matrix([
                                    0.2126 + 0.7874 * saturation, 0.7152 - 0.7152 * saturation, 0.0722 - 0.0722 * saturation, 0, 0,
                                    0.2126 - 0.2126 * saturation, 0.7152 + 0.2848 * saturation, 0.0722 - 0.0722 * saturation, 0, 0,
                                    0.2126 - 0.2126 * saturation, 0.7152 - 0.7152 * saturation, 0.0722 + 0.9278 * saturation, 0, 0,
                                    0, 0, 0, 1, 0,

                                  ]),

                                  child: ColorFiltered(
                                      colorFilter: ColorFilter.matrix([
                                        1.0 + balanceFactor, 0, 0, 0, 0,
                                        0, 1.0 , 0, 0, 0,
                                        0, 0, 1.0 - balanceFactor, 0, 0,
                                        0, 0, 0, 1, 0,

                                      ]),
                                      child: Image.asset(
                                        imagePaths[currentImageIndex],
                                        fit: BoxFit.cover,
                                      ),
                                  ),


                                ),
                              ),
                            ),
                            if (currentImageIndex != 0)
                              Opacity(
                                opacity: opacity,
                                child: Image.asset(
                                  imagePaths[currentImageIndex - 1],
                                  fit: BoxFit.cover,
                                ),
                              ),


                            if (showMarkers)
                              ...markersForEachImage[currentImageIndex].asMap().entries.map((entry) {
                                final index = entry.key;
                                final marker = entry.value;
                                final isSelectedMarker = index == selectedMarkerIndex;
                                return Positioned(
                                    // TODO: The marker tends to jump by a fixed offset when its ListTile is selected
                                    left: marker['offset'].dx - (isSelectedMarker ? 10 : 5),
                                    top: marker['offset'].dy - (isSelectedMarker ? 10 : 5),
                                    child: GestureDetector(
                                      onPanStart: (details) {
                                        setState(() {
                                          isDragging = true;
                                        });
                                      },
                                      onPanUpdate: (DragUpdateDetails details) {
                                        RenderBox box = context.findRenderObject() as RenderBox;
                                        Offset newOffset = box.globalToLocal(details.globalPosition);
                                        setState(() {
                                          markersForEachImage[currentImageIndex][index]['offset'] = newOffset;
                                        });
                                      },
                                      onPanEnd: (details) {
                                        setState(() {
                                          isDragging = false;
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
                            if (showMarkers && currentImageIndex != 0)
                              ...markersForEachImage[currentImageIndex - 1].asMap().entries.map((entry) {
                                final index = entry.key;
                                final marker = entry.value;
                                final isSelectedMarker = index == selectedMarkerIndex;
                                return Positioned(
                                left: marker['offset'].dx - (isSelectedMarker ? 10 : 5),
                                top: marker['offset'].dy - (isSelectedMarker ? 10 : 5),
                                child: Icon(Icons.circle, color: Colors.yellowAccent, size: 10,),
                                );
                                }),


                          ],
                        ),
                      );
                    },
                  ),
                ),
                TabBar (
                  controller: tabController,
                  tabs: const [
                    Tab(text: 'Sliders'),
                    Tab(text: 'Markers'),
                    Tab(text: 'Frames',)
                  ],
                ),
                Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              buildAdjustmentSliders(),
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your Markers',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 20, fontWeight: FontWeight.bold
                                          ),),
                                        Text(
                                          'Please name the markers for future reference',
                                          style: TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.normal
                                          ),
                                        ),
                                      ],
                                    ),


                                  ),
                                  const Divider(height: 1, thickness: 1, color: Colors.grey,),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: markersForEachImage[currentImageIndex].length,
                                      itemBuilder: (context, index) {
                                        final marker = markersForEachImage[currentImageIndex][index];
                                        return ListTile(
                                          title: Text(marker['name']), //_respectiveName == null ? Text(_respectiveName) : Text('Sam'),
                                          subtitle: Text('''
      X is ${marker['offset'].dx.toStringAsFixed(2)}
      Y is ${marker['offset'].dy.toStringAsFixed(2)}'''),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                // TODO: replacing delete with 'undo' makes it easier to track the path the user takes within the app
                                                icon: const Icon(Icons.delete),
                                                onPressed: () => setState(() => markersForEachImage[currentImageIndex].removeAt(index)),
                                              ),
                                              IconButton(
                                                  onPressed: () => editMarkerDetails(index),
                                                  icon: const Icon(Icons.edit)
                                              ),
                                            ],),
                                          tileColor: selectedMarkerIndex == index ? Colors.grey : null,
                                          onTap: () {
                                            setState(() {
                                              if (selectedMarkerIndex != null) {
                                                markersForEachImage[currentImageIndex][selectedMarkerIndex!]['colour'] = Colors.red;
                                              }

                                              selectedMarkerIndex = index;

                                              markersForEachImage[currentImageIndex][index]['colour'] = Colors.orange;
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
                            itemCount: imagePaths.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentImageIndex = index;
                                    if (currentImageIndex == 0) {
                                      _pageTitle = 'Tap image to place markers';
                                    }
                                    else if (markersForEachImage[currentImageIndex].isEmpty) {
                                      _pageTitle = 'Place marker "${markersForEachImage[currentImageIndex - 1][markersForEachImage[currentImageIndex].length]['name']}"';
                                    } else {
                                      if (markersForEachImage[currentImageIndex]
                                          .length !=
                                          markersForEachImage[currentImageIndex -
                                              1].length) {
                                        _pageTitle =
                                        'Place marker "${(markersForEachImage[currentImageIndex -
                                            1][markersForEachImage[currentImageIndex ]
                                            .length]['name'])}"';
                                      } else {
                                        _pageTitle =
                                        'Drag the markers into place'; // or move to the next frame';
                                      }
                                    }
                                  });
                                },
                                child: Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                      contentPadding: const EdgeInsets.all(8.0),
                                      leading: Image.asset(
                                        imagePaths[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                     title: Text('Image ${index + 1}'),
                                      trailing: IconButton(
                                        onPressed: () => deleteImage(index),
                                        icon: const Icon(Icons.delete),
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
                    currentIndex = index;
                  });

                  switch (index) {
                    case 0:
                      Navigator.of(context).pushReplacement(InstantPageRoute(
                          builder: (context) => const DashboardPage()));
                    case 1:
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(widget._projectName)));
                    case 2:
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoTakingPage(widget._projectName)));
                      Navigator.of(context).pushReplacement(InstantPageRoute(
                          builder: (context) => PhotoTakingPage(widget._projectName)));

                  }


                  // if (index == 0) {
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
                  // } else if (index == 1) {
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(widget._projectName)));
                  // }
                  // else if (index == 2) {
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoTakingPage(widget._projectName)));
                  // }
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
