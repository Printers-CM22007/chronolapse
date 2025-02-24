import 'package:chronolapse/ui/models/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DashboardPage extends StatefulWidget {

  const DashboardPage( {super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class DashboardPageIcons {
  DashboardPageIcons._();

  static const fontFamily = 'icomoon';

  static const IconData search =
      IconData(0xe986, fontFamily: fontFamily);

  static const IconData edit =
    IconData(0xe905, fontFamily: fontFamily);

  static const IconData projects =
    IconData(0xe920, fontFamily: fontFamily);

  static const IconData notifications =
    IconData(0xe951, fontFamily: fontFamily);

  static const IconData export =
    IconData(0xe968, fontFamily: fontFamily);

  static const IconData settings =
    IconData(0xe994, fontFamily: fontFamily);

  static const IconData bin =
    IconData(0xe9ac, fontFamily: fontFamily);

  static const IconData import =
    IconData(0xe9c5, fontFamily: fontFamily);

  static const IconData add =
    IconData(0xea0a, fontFamily: fontFamily);

  static const IconData dots =
    IconData(0xeaa3, fontFamily: fontFamily);
}



class _DashboardPageState extends State<DashboardPage>{
  Color blackColour = const Color(0xff08070B);
  Color greyColour = const Color(0xff131316);
  Color whiteColour = const Color(0xffCCCCCC);
  Color blueColour1 = const Color(0xff11373B);
  Color blueColour2 = const Color(0xff384547);
  Color redColour = const Color(0xff3A0101);

  List<ProjectCard> projects = [];
  void _getProjects(){
    projects = ProjectCard.getProjects();
  }
  @override
  Widget build(BuildContext context){
    _getProjects();
    return Scaffold(
      backgroundColor: greyColour,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.

      backgroundColor: greyColour,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
      ),
      body: Column(
        children: [
          searchBar(),
          SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              createNewButton(),
              importButton()
          ],),
          SizedBox(height: 15,),
          Divider(thickness: 1.2, color: whiteColour, indent: 20, endIndent: 20,),
          SizedBox(height: 15,),
          projectsContainer(),

        ],
      ),
      bottomNavigationBar: bottomNavBar(),
    );
  }

  Container bottomNavBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 10,left: 10, right: 10),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(35),
        //   topRight: Radius.circular(35)
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade600,
            blurRadius: 1
          )
        ]
      ),
      child: NavigationBar(
        shadowColor: whiteColour,
        height: 60,
        backgroundColor: blueColour2,
        elevation: 0,
        selectedIndex: 0,
        indicatorColor: greyColour,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(
            color: whiteColour
        )),
        //onDestinationSelected: (index) =>   ,
        destinations: [
          NavigationDestination(icon: Icon(DashboardPageIcons.projects, color: whiteColour,), label: "Projects"),
          NavigationDestination(icon: Icon(DashboardPageIcons.settings, color: whiteColour,), label: "Settings")
        ]
      ),
    );
  }

  Container importButton() {
    return Container(
                width: 120,
                padding: EdgeInsets.only(right:25),
                child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: blueColour2),
                  onPressed: (){},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(DashboardPageIcons.import, color: whiteColour,),
                      Text("Import", style: TextStyle(
                        color: whiteColour,

                      ),)
                    ],
                  ),
                ),
              );
  }

  Container createNewButton() {
    return Container(
                width: 150,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: TextButton(
                    style: TextButton.styleFrom(backgroundColor: blueColour1),
                    onPressed: (){},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(DashboardPageIcons.add, color: whiteColour,),
                        Text("Create New", style: TextStyle(
                          color: whiteColour,

                        ),)
                      ],
                    ),
                  ),
                ),
              );
  }

  Container projectsContainer() {
    return Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            height: 445,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 10,),
              scrollDirection: Axis.vertical,
              itemCount: projects.length,
              itemBuilder: (context,index){
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: projects[index].boxColor,
                    borderRadius: BorderRadius.circular(18)
                  ),
                  child: LayoutBuilder(
                    builder: (BuildContext bContext, BoxConstraints constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.025,),
                          Container(
                            width: constraints.maxWidth * 0.9,
                            height: constraints.maxHeight * 0.65,
                            child: Image.asset(projects[index].previewPicturePath),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.025,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                //color: Colors.yellow,
                                width: constraints.maxWidth * 0.45,
                                height: constraints.maxHeight * 0.1,
                                padding: EdgeInsets.only(left: constraints.maxWidth * 0.1),
                                child: Text(
                                  projects[index].projectName,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: blueColour1,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                //color: Colors.yellow,
                                width: constraints.maxWidth * 0.4,
                                height: constraints.maxHeight * 0.1,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Last edited ${projects[index].lastEdited} ago",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white38,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: constraints.maxHeight * 0.025,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                //color: Colors.yellow,
                                width: constraints.maxWidth * 0.35,
                                height: constraints.maxHeight * 0.125,
                                padding: EdgeInsets.only(left: constraints.maxWidth * 0.1),
                                child: TextButton(
                                  onPressed: (){
                                    //Open the project to be edited here
                                  },
                                  style: TextButton.styleFrom(backgroundColor: blueColour1),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(DashboardPageIcons.edit, color: whiteColour,),
                                      Text("Edit", style: TextStyle(
                                        color: whiteColour,
                                      ),)
                                    ],
                                  ),
                                )
                              ),
                              Container(
                                //color: Colors.yellow,
                                width: constraints.maxWidth * 0.4,
                                height: constraints.maxHeight * 0.1,
                                alignment: Alignment.centerRight,
                                child: MenuAnchor(
                                  style: MenuStyle(
                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                    //maximumSize: WidgetStatePropertyAll(Size.fromHeight(40)),
                                    fixedSize: const WidgetStatePropertyAll(Size(100,80)),
                                    backgroundColor: WidgetStatePropertyAll(whiteColour),
                                  ),
                                  alignmentOffset: const Offset(-60,-100),
                                  builder: (_, MenuController controller, Widget? child){
                                    return IconButton(
                                      onPressed: (){
                                        if(controller.isOpen){
                                          controller.close();
                                        } else {
                                          controller.open();
                                        }
                                      },
                                      icon: Icon(DashboardPageIcons.dots, color: whiteColour,),
                                    );
                                  },
                                  menuChildren: <Widget>[
                                    Container(
                                      width: 100,
                                      height: 30,
                                      child: MenuItemButton(
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStatePropertyAll(whiteColour),
                                          fixedSize: const WidgetStatePropertyAll(Size(100,40)),
                                        ),
                                        onPressed: (){
                                          //Add Export Functionality here
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(DashboardPageIcons.export, color: blackColour,),
                                            Text("Export", style: TextStyle(
                                              color: blackColour,
                                            ),),

                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 100,
                                      height: 30,
                                      child: MenuItemButton(
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStatePropertyAll(whiteColour),
                                          fixedSize: const WidgetStatePropertyAll(Size(100,40)),

                                        ),
                                        onPressed: (){
                                          //Add delete functionality here
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(DashboardPageIcons.bin, color: redColour,),
                                            Text("Delete", style: TextStyle(
                                              color: blackColour,

                                            ),),

                                          ],
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  )
                );
              },
            )
          );
  }

  Container searchBar() {
    return Container(
            margin: EdgeInsets.only(top:20,left: 20,right: 20),
            child: TextField(
              style: TextStyle(
                color: whiteColour
              ),
              cursorColor: whiteColour,
              decoration: InputDecoration(
                filled: true,
                fillColor: blackColour,
                hintText: "Search Project",
                hintStyle: TextStyle(color: whiteColour),
                hoverColor: whiteColour,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    DashboardPageIcons.search,
                    color: whiteColour,
                  )
                ),
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none
                )
              ),
            ),
          );
  }
}