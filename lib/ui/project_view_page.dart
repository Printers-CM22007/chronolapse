import 'dart:ffi';
import 'dart:io';


import 'package:chronolapse/backend/timelapse_storage/timelapse_data.dart';
import 'package:chronolapse/backend/timelapse_storage/frame/timelapse_frame.dart';
import 'package:chronolapse/backend/timelapse_storage/timelapse_store.dart';
import 'package:flutter/material.dart';

class ProjectViewPage extends StatefulWidget {
  final String _projectName;

  const ProjectViewPage(this._projectName, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProjectViewPageState();
  }
}

class ProjectViewPageIcons {
  ProjectViewPageIcons._();

  static const fontFamily = 'icomoon';

  static const IconData next = IconData(0xe986, fontFamily: fontFamily);

  static const IconData previous = IconData(0xe986, fontFamily: fontFamily);

  static const IconData edit = IconData(0xe905, fontFamily: fontFamily);
}

class _ProjectViewPageState extends State<ProjectViewPage> {

  late ProjectTimelapseData _project;
  late List<String> _projectFrameUuidList;
  @override
  int currentFrameIndex = 0;
  String currentFramePath = "none";
  bool _projectLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }




  void _loadProject() async {
    _project = await TimelapseStore.getProject(widget._projectName);
    _projectLoaded = true;
    _projectFrameUuidList = _project.data.metaData.frames;

    // Assumed if you can view the Project it must have at least 1
    currentFrameIndex = -1;
    _getNextFrame();
    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getPathForIndex() async{
      var fromExisting = TimelapseFrame.fromExisting(widget._projectName, _projectFrameUuidList[currentFrameIndex]);
      return (fromExisting).then((x) => x.getFramePng().path);
  }
  bool _getNextFrame() {
    if (currentFrameIndex < _projectFrameUuidList.length - 1) {
      currentFrameIndex += 1;
      Future<String?> pathForIndex = getPathForIndex();
      pathForIndex.then((p){
        if (p != null) {
          setState(() {
            currentFramePath = p;
          });
        }} );
      return true;
    } return false;
  }
  bool _getPreviousFrame() {
    if (currentFrameIndex > 0) {
      currentFrameIndex -= 1;
      Future<String?> pathForIndex = getPathForIndex();
      pathForIndex.then((p){
        if (p != null) {
          setState(() {
            currentFramePath = p;
          });
        }} );
      return true;
    } return false;
  }

  void _playAll(){
    bool next = true;
    while(next){
      next = _getNextFrame();
    }
  }




  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget._projectName == null
              ? "Project View"
              : "Project View - ${widget._projectName}",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              )),

          centerTitle: true,
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
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                  'Frame $currentFrameIndex of Project ${widget._projectName}',
                  style: Theme.of(context).textTheme.headlineSmall
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Container(
                  width: 200,
                  height: 200,
                  child: FittedBox(
                    child: Image.file(File(currentFramePath)),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),

            ]
        ),
              const Divider(),
              Text(// prints location of where frame got pulled from
                "\n(Found at location $currentFramePath)",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: currentFrameIndex > 0 ? _getPreviousFrame : null,
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary),
                    child: Text("Prevoius Frame"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: currentFrameIndex < _projectFrameUuidList.length - 1 ? _getNextFrame : null,
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary),
                    child: Text("Next Frame"),
                  ),
                ],
              ),
            ],
          ),
        )

    );
  }
  /*Container imageDisplay(){
    return Container(
      height: 300,
      decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(18)),
      child: LayoutBuilder(
          builder: (BuildContext bContext, BoxConstraints constraints) {

          }
      ),
    );
  }*/
}
