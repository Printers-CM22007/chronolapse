[Back](Timelapse%20Storage.md)

## Creating/Managing Projects
You can create project using:
```dart
final projectData = await TimelapseStore.createProject("myProjectName");
```
The name must be unique and alphanumeric (spaces are allowed) - the function will return `null` if either of these conditions are not met.

>[!note]-
>Might change this returning `null` behaviour to a proper error at some point.
>\- Robert 

You can list existing projects with:
```dart
TimelapseStore.getProjectList()
```

See the other methods under `TimelapseStore` for other operations - such as deletion - which you can perform on projects.

## Project Data
You can obtain a reference to project data like so:
```dart
final projectData = await TimelapseStore.getProject(projectName);
```

You can then access data about a project through `projectData.data` e.g.
```dart
print(projectData.data.metaData.frames);
```
> This particular example gives you the list of all the frames

If you make changes to the data you can save it:
```dart
await projectData.saveChanges();
```

If you are aware that the data may be changed while you are maintaining a reference to it you can load the changes with:
```dart
await projectData.reloadFromDisk();
```
e.g.
```dart
print("Creating project");  
const projectName = "myProjectName";  
final projectData = (await TimelapseStore.createProject(projectName))!;  
  
print("Frames before:");  
print(projectData.data.metaData.frames);  
  
final testFrame = TimelapseFrame.createNew(projectName);  
await testFrame.saveFrameFromFile(...);  
  
await projectData.reloadFromDisk();  
print("Frames after:");  
print(projectData.data.metaData.frames);
```

>[!warning] 
>You are recommended not to maintain/store references to `ProjectTimelapseData` (called project data above) as they might change on disk. If the data changes on disk while you're holding the reference, the changes will not be automatically reflected in `projectData.data` and calling `await projectData.saveChanges()` will replace the changes on disk with whatever is in `projectData.data`

