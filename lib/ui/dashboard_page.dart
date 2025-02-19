import 'package:chronolapse/ui/models/project_card.dart';
import 'package:flutter/material.dart';

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
                Container(

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
                ),
                Container(
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
                )
            ],),
            SizedBox(height: 15,),
            Divider(thickness: 0.5, color: whiteColour, indent: 20, endIndent: 20,),
            SizedBox(height: 15,),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              height: 450,
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
                  );
                },
              )
            )
          ],
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