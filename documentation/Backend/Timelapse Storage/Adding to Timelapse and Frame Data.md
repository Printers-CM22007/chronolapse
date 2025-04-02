[Back](Timelapse%20Storage.md)

Both `TimelapseData` and `FrameData` are serialised as JSON on disk. You can add data to be stored by adding attributes to `TimelapseData` and `FrameData` in `lib/backend/timelapse_storage/timelapse_data.dart` and `lib/backend/timelapse_storage/frame/frame_data.dart` respectively.

```dart
...
class TimelapseData {  
  TimelapseMetaData metaData;  
  // <-- Here

  TimelapseData({required this.metaData});  
  
  factory TimelapseData.initial(String projectName) {  
    return TimelapseData(metaData: TimelapseMetaData.initial(projectName));  
  }  

  ...
}
...
```

You will then need to update the constructor and `inital` method to include your attribute.

>[!note] 
> Not currently certain if `FrameData` should use this `initial` system. Might change later.
> \- Robert
## JSON Serialisability
The added data must also be JSON-serialisable such as the `TimelapseMetaData` in the above example:
```dart
import 'package:json_annotation/json_annotation.dart';  
  
part 'timelapse_metadata.g.dart';  
  
@JsonSerializable()  
class TimelapseMetaData {  
  final String projectName;  
  final List<String> frames;  
  
  TimelapseMetaData({required this.projectName, required this.frames});  
  
  factory TimelapseMetaData.initial(String projectName) {  
    return TimelapseMetaData(projectName: projectName, frames: []);  
  }  
  
  factory TimelapseMetaData.fromJson(Map<String, dynamic> json) =>  
      _$TimelapseMetaDataFromJson(json);  
  Map<String, dynamic> toJson() => _$TimelapseMetaDataToJson(this);  
}
```

Steps to get JSON working:
1. Add `part '[file].g.dart'` below imports
2. Add the `@JsonSerializable()` decorator to your class
3. Add the `fromJson` method (copy it from above or a different existing one and change the relevant parts)
4. Run `flutter pub run build_runner build`

