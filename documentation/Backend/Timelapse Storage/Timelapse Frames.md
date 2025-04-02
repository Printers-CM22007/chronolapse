[Back](Timelapse%20Storage.md)

To create a frame with default data:
```dart
final frame = TimelapseFrame.createNew(projectName);
```
Or with specified data:
```dart
final frame = TimelapseFrame.createNewWithData(projectName, frameData);
```

Both of these will not create anything on-disk and the frame will not have a UUID (accessible through `frame.uuid()`) until saved.

To load a frame from disk (this frame will have a UUID):
```dart 
final frame = TimelapseFrame.fromExisting(projectName, uuid);
```

You can then modify the frame's data through `frame.data`.

You can save a frame with:
```dart
await frame.saveFrameFromPngFile(imageFile);
```

Or to save only the changes to the file's data:
```dart
await frame.saveFrameDataOnly();
```
> This requires the frame to have been saved once before or loaded from disk as saving a frames data without the frame itself (the image file) is not allowed.


>[!warning] 
>You are recommended not to maintain/store references to `TimelapseFrame`s as they might change on disk. If the data changes on disk while you're holding the reference, the changes will not be automatically reflected in `frame.data` and calling a method to save the frame will replace the changes on disk with whatever is in `frame.data`