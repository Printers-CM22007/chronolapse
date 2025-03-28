part of 'dashboard_page.dart';

extension CreateNewButton on DashboardPageState {
  void _onCreateNewProject() {
    setState(() {
      _projectCreateError =
          TimelapseStore.checkProjectName(_projectNameController.text);
    });

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                  title: const Text("New Project"),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        //pop the box
                        Navigator.pop(context);

                        //clear the controller and error
                        setState(() {
                          _projectNameController.clear();
                          _projectCreateError = null;
                        });
                      },
                      child: const Text("Cancel"),
                    ),
                    MaterialButton(
                      onPressed: _projectCreateError == null
                          ? () {
                              // close the box
                              Navigator.pop(context);
                              // create the project in the backend
                              _onCompleteCreateProjectDialogue(
                                  _projectNameController.text.trim());

                              //clear the controller and error
                              setState(() {
                                _projectNameController.clear();
                                _projectCreateError = null;
                              });
                            }
                          : null,
                      child: const Text("Create"),
                    )
                  ],
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //User input for project name
                      TextField(
                        controller: _projectNameController,
                        onChanged: (newVal) {
                          setState(() {
                            _projectCreateError =
                                TimelapseStore.checkProjectName(newVal);
                          });
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        decoration: InputDecoration(
                            hintText: "Enter project name",
                            hintStyle: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white38),
                            errorText: _projectCreateError),
                      )
                    ],
                  ));
            },
          );
        });
  }

  SizedBox _createNewButton() {
    return SizedBox(
      width: 150,
      child: Padding(
        padding: const EdgeInsets.only(left: 18),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            _onCreateNewProject();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                DashboardPageIcons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              Text(
                "Create New",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
