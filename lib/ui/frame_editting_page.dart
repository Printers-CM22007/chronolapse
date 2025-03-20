// import 'dart:ui';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:chronolapse/ui/export_page.dart';
import 'package:chronolapse/ui/shared/instant_page_route.dart';
import 'package:flutter/material.dart';
import 'package:chronolapse/ui/dashboard_page.dart';
import 'package:chronolapse/ui/settings_page.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/frame_data.dart';
import 'package:chronolapse/ui/photo_taking_page.dart';
import 'package:chronolapse/ui/shared/instant_page_route.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../backend/settings_storage/settings_store.dart';
import '../backend/timelapse_storage/frame/timelapse_frame.dart';
import '../backend/timelapse_storage/timelapse_data.dart';
import '../backend/timelapse_storage/timelapse_store.dart';

// OUTDATED-GOAL: the code crashes if a page with markers on it is deleted
// TODO: there is an unhandled error when the project is exited sometimes

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


// class VideoEditorPageIcons extends DashboardPageIcons {
//
//   @override
//   // VideoEditorPageIcons._();
//
//   static const fontFamily = 'icomoon';
//
//   static const IconData dashboard = IconData(0xe986, fontFamily: fontFamily);
//
//   // static const IconData camera = Icon(Icons.camera_alt)//IconData(0xe130, fontFamily: fontFamily);
// }
class FrameEditor extends StatefulWidget {
  final String _projectName;
  final String _uuid;

  const FrameEditor(this._projectName, this._uuid, {super.key});

  @override
  _FrameEditorState createState() => _FrameEditorState();
}

class _FrameEditorState extends State<FrameEditor> with SingleTickerProviderStateMixin{
  double opacity = 0.3;
  double brightness = 0.0;
  double contrast = 1.0;
  double saturation = 1.0;
  double balanceFactor = 0.0;

  final GlobalKey _boundaryKey = GlobalKey();



  // final List<Map<String, dynamic>> markers = [];
  int? selectedMarkerIndex;
  bool showMarkers = true;
  bool isDragging = false;

  late TabController tabController;

  int currentIndex = 0;
  int currentImageIndex = 0;

  String? theImage;
  File? photoFile;


  String _pageTitle = 'Tap image to place markers';
  late String _respectiveName;

  final List<List<Map<String, dynamic>>> markersForEachImage = [];

  Future<String?> getPathForIndex(String uuid) async{
    // await TimelapseStore.deleteAllProjects();

    var fromExisting = TimelapseFrame.fromExisting(widget._projectName, uuid);
    return (fromExisting).then((x) => x.getFramePng().path);
  }

  //The stuff below is experimental
  late ProjectTimelapseData _project;
  late List<String> _projectFrameUuidList;
  int currentFrameIndex = 0;
  String currentFramePath = "none";
  bool _projectLoaded = false;

  Future<TimelapseFrame> pleaseGetPhoto() async {
    final frame = await TimelapseFrame.fromExisting(widget._projectName, widget._uuid);

    File photoFile = frame.getFramePng();

    if (!(photoFile.existsSync())) {
      print("Photo file not found!");
    }

    return frame;
  }

  @override
  void initState() {
    super.initState();
    // TimelapseFrame.get
    // _getFrameImageFile

    // getPathForIndex(widget._uuid);

    List<String> imagePaths = ['assets/frames/landscape.jpeg'];

    Future<String?> futureString = getPathForIndex(widget._uuid);
    // futureString.then((value) {
    //   print("Hey it worked: ${value}");
    //   imagePaths[0] = (value!);
    // });

    final test = TimelapseFrame.fromExisting(widget._projectName, widget._uuid);

    print("picture path is ${widget._uuid}");
    print("imagePaths is ${imagePaths}");
    pleaseGetPhoto();

    // accessBackendPhotos();
    tabController = TabController(length: 2, vsync: this);

    for (int i = 0; i < imagePaths.length; i++) {
        markersForEachImage.add([]);
    }
  }

  //
  // List<String> imagePaths = [widget._picturePath];
  // List<String> imagePaths = [
  //   'assets/frames/landscape.jpeg',
  //   'assets/frames/clouds-country.jpg',
  //   'assets/frames/SaxonyLandscape.jpg',
  // ];


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

  // void deleteImage(int index) {
  //   setState(() {
  //     if (imagePaths.length == 1) {
  //       Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
  //     } else {
  //       imagePaths.removeAt(index);
  //     }
  //   });
  // }

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

  Future<void> addPhotoBackend(ProjectTimelapseData tProject, String imagePath) async {
    final baseFrame = TimelapseFrame.createNewWithData(
        tProject.projectName(), FrameData.initial(tProject.projectName()));
    await baseFrame.saveFrameFromPngBytes(
        (await rootBundle.load(imagePath))
        .buffer
        .asUint8List());

    // * Add frame to list of known frames
    tProject.data.knownFrameTransforms.frames
        .add(baseFrame.uuid()!); // uuid is known here as the frame has been saved
    await tProject.saveChanges();
  }

  Future<void> accessBackendPhotos() async {

    //When using this, make sure to delete previous projects when testing
    // await TimelapseStore.deleteAllProjects();
    // await SettingsStore.deleteAllSettings();

    // * Create test project
    final testProject = (await TimelapseStore.createProject(widget._projectName)) ?? (await TimelapseStore.getProject(widget._projectName));

    // addPhotoBackend(testProject, "assets/frames/landscape.jpeg");
    // addPhotoBackend(testProject, "assets/frames/clouds-country.jpg");
    // addPhotoBackend(testProject, "assets/frames/SaxonyLandscape.jpg");

    _loadProject(); // exp

  }

  Future<Uint8List?> captureEditedImage() async {
    try {

      if (_boundaryKey.currentContext == null) {
        print("RepaintBoundary key is not attached to the widget tree");
        return null;
      }
      RenderRepaintBoundary boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      if (boundary.size.isEmpty) {
        print("RepaintBoundary size is empty: ${boundary.size}");
        return null;
      }
      // Now we convert this to an image
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      //Then we can return the PNG in 'PNG bytes' format
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("There was a error. This is what it said: $e");
      return null;
    }
  }

  Future<void> saveEditedFrame(String projectName, String frameUuid) async {
    try {
      // final Uint8List? pngBytes = await captureEditedImage();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final Uint8List? pngBytes = await captureEditedImage();
        if (pngBytes != null) {
          // Proceed with saving
          final frame = await TimelapseFrame.fromExisting(projectName, frameUuid);

          await frame.saveFrameFromPngBytes(pngBytes);
        } else {
          print("Nooooooo");
        }
      });

      // if (pngBytes == null) {
      //   print("Failed to capture the edited image =(");
      //   return;
      // }
      


      print("Yipee");
    } catch (e) {
      print("You can't do ML once you solve this: $e");
    }
  }

  // The below text is from the ViewPage branch


//  //This stuff is for styling the page
// class ProjectViewPageIcons {
//   ProjectViewPageIcons._();
//
//   static const fontFamily = 'icomoon';
//
//   static const IconData next = IconData(0xe986, fontFamily: fontFamily);
//
//   static const IconData previous = IconData(0xe986, fontFamily: fontFamily);
//
//   static const IconData edit = IconData(0xe905, fontFamily: fontFamily);
// }


  void _loadProject() async {
    TimelapseStore.initialise();
    _project = await TimelapseStore.getProject(widget._projectName);
    _projectLoaded = true;
    _projectFrameUuidList = _project.data.metaData.frames;

    print("Chromo");
    print(_projectFrameUuidList.length);

    // // Assumed if you can view the Project it must have at least 1
    // currentFrameIndex = -1;
    // _getNextFrame();
    // if (mounted) {
    //   setState(() {});
    // }
  }
  //
  // Future<String?> getPathForIndex() async{
  //   var fromExisting = TimelapseFrame.fromExisting(widget._projectName, _projectFrameUuidList[currentFrameIndex]);
  //   return (fromExisting).then((x) => x.getFramePng().path);
  // }
  // bool _getNextFrame() {
  //   if (currentFrameIndex < _projectFrameUuidList.length - 1) {
  //     currentFrameIndex += 1;
  //     Future<String?> pathForIndex = getPathForIndex();
  //     pathForIndex.then((p){
  //       if (p != null) {
  //         setState(() {
  //           currentFramePath = p;
  //         });
  //       }} );
  //     return true;
  //   } return false;
  // }
  // bool _getPreviousFrame() {
  //   if (currentFrameIndex > 0) {
  //     currentFrameIndex -= 1;
  //     Future<String?> pathForIndex = getPathForIndex();
  //     pathForIndex.then((p){
  //       if (p != null) {
  //         setState(() {
  //           currentFramePath = p;
  //         });
  //       }} );
  //     return true;
  //   } return false;
  // }
  //
  // void _playAll(){
  //   bool next = true;
  //   while(next){
  //     next = _getNextFrame();
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    Future<TimelapseFrame> frame = pleaseGetPhoto();

    frame.then((value) {
      if (mounted) {
        setState(() {
          photoFile = value.getFramePng();
          theImage = photoFile?.path ?? 'No path available';
          // print("the image is $theImage");
        });
      }
    });


    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: Text(_pageTitle),
              actions: [
                IconButton(
                    onPressed: () => setState(() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(widget._projectName)));
                    }),
                    icon: Icon(Icons.settings)),
                IconButton(
                    icon: Icon(showMarkers ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() {showMarkers = !showMarkers;})
                )],
            ),

            body: Column(
              children: [
                Container(
                  // width: 100,
                  height: 300,
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
                        child: RepaintBoundary(
                          key: _boundaryKey,
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
                                      child: theImage != null ? Image.file(File(theImage!), fit: BoxFit.cover) : Text('Image at $theImage is loading...'),
                                    ),


                                  ),
                                ),
                              ),
                              if (currentImageIndex != 0)
                                Opacity(
                                  opacity: opacity,
                                  child: Image.asset(
                                    widget._uuid[currentImageIndex - 1],
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
                    // Tab(text: 'Frames',)
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
                        // GridView.builder(
                        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        //       crossAxisCount: 3,
                        //       crossAxisSpacing: 8.0,
                        //       mainAxisSpacing: 8.0,
                        //     ),
                        //     itemCount: imagePaths.length,
                        //     itemBuilder: (context, index) {
                        //       return GestureDetector(
                        //         onTap: () {
                        //           setState(() {
                        //             currentImageIndex = index;
                        //             if (currentImageIndex == 0) {
                        //               _pageTitle = 'Tap image to place markers';
                        //             }
                        //             else if (markersForEachImage[currentImageIndex].isEmpty) {
                        //               _pageTitle = 'Place marker "${markersForEachImage[currentImageIndex - 1][markersForEachImage[currentImageIndex].length]['name']}"';
                        //             } else {
                        //               if (markersForEachImage[currentImageIndex]
                        //                   .length !=
                        //                   markersForEachImage[currentImageIndex -
                        //                       1].length) {
                        //                 _pageTitle =
                        //                 'Place marker "${(markersForEachImage[currentImageIndex -
                        //                     1][markersForEachImage[currentImageIndex ]
                        //                     .length]['name'])}"';
                        //               } else {
                        //                 _pageTitle =
                        //                 'Drag the markers into place'; // or move to the next frame';
                        //               }
                        //             }
                        //           });
                        //         },
                        //         // child: ListTile(
                        //         //       contentPadding: const EdgeInsets.all(8.0),
                        //         //       leading: Image.asset(
                        //         //         imagePaths[index],
                        //         //         width: 100,
                        //         //         height: 100,
                        //         //         fit: BoxFit.cover,
                        //         //       ),
                        //         //     title: Text('Image ${index + 1}'),
                        //         //     trailing: IconButton(
                        //         //         onPressed: () => deleteImage(index),
                        //         //         icon: const Icon(Icons.delete),
                        //         //       ),
                        //         //     ),
                        //         child: GridTile(
                        //           child: Image.asset(
                        //               imagePaths[index],
                        //               fit: BoxFit.cover,
                        //             ),
                        //         ),
                        //         );
                        //     },
                        // )
                      ],
                    )
                ),
                ]),
            bottomNavigationBar: Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                ),
                  onPressed: () async {
                  //   frame.then(
                  //       onValue
                  //   )
                    await saveEditedFrame(widget._projectName, widget._uuid);
                    print("Save button pressed");
                    frame.then((value) {
                      setState(() {
                        if (mounted) {
                          value.saveFrameFromPngFile(photoFile!);
                          photoFile = value.getFramePng();
                          theImage = photoFile?.path ?? 'No path available';
                          // print("the image is $theImage");
                        }
                      });
                    });
                    Navigator.of(context).pushReplacement(InstantPageRoute(
                        builder: (context) => const DashboardPage()));
                  },
                  child: Text(
                      'Save and exit',
                  style: TextStyle(fontSize: 18.0),),

                ),
              ),
            ),

            // BottomNavigationBar(
            //     onTap: (index) {
            //       setState(() {
            //         currentIndex = index;
            //       });
            //
            //       switch (index) {
            //         case 0:
            //           Navigator.of(context).pushReplacement(InstantPageRoute(
            //               builder: (context) => const DashboardPage()));
            //         case 1:
            //           Navigator.push(context, MaterialPageRoute(builder: (context) => ExportPage(widget._projectName)));
            //         case 2:
            //           // Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoTakingPage(widget._projectName)));
            //           Navigator.of(context).pushReplacement(InstantPageRoute(
            //               builder: (context) => PhotoTakingPage(widget._projectName)));
            //
            //       }
            //
            //
            //       // if (index == 0) {
            //       //   Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
            //       // } else if (index == 1) {
            //       //   Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(widget._projectName)));
            //       // }
            //       // else if (index == 2) {
            //       //   Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoTakingPage(widget._projectName)));
            //       // }
            //     },
            //     items: const[
            //       BottomNavigationBarItem(
            //           icon: Icon(Icons.home),
            //           label: 'Dashboard',
            //       ),
            //       BottomNavigationBarItem(
            //           icon: Icon(Icons.upload),
            //           label: 'Export'
            //       ),
            //       BottomNavigationBarItem(
            //           icon: Icon(Icons.camera_alt),
            //           label: 'Take photo'
            //       ),
            //     ]
            // ),
            ),

        );

  }
}

class VideoEditorNavigationBar extends StatelessWidget {
  final int selectedIndex;

  final dynamic _projectName;

  const VideoEditorNavigationBar(this.selectedIndex, this._projectName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(35),
        //   topRight: Radius.circular(35)
        // ),
        // boxShadow: [BoxShadow(color: Colors.grey.shade600, blurRadius: 1)]
      ),
      child: NavigationBar(
          shadowColor: Theme.of(context).colorScheme.onInverseSurface,
          height: 60,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          selectedIndex: selectedIndex,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:

                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => const DashboardPage()));
                break;

              case 1:
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExportPage(_projectName)));
                break;

              case 2:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoTakingPage(widget._projectName)));
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => PhotoTakingPage(_projectName)));
                break;

            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.dashboard,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Dashboard",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.share,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Export",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Take Photo",
            ),
          ]),
    );
  }
}
