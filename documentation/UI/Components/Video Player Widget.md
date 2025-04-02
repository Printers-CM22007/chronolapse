[Back](Video%20Player%20Widget.md)

# Video Player Widget

## Usage
Use the player with:
```dart
VideoPlayerWidget(videoPlayerController);
```

It accepts a `VideoPlayerController` e.g.:
```dart
VideoPlayerWidget(
	VideoPlayerController.networkUrl(
		Uri.parse(  
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
	    )
	)
)
```

`VideoPlayerController` can also be created from a file, asset, content URI, or, as shown above, a network URL - see the [VideoPlayerController Documentation](https://pub.dev/documentation/video_player/latest/video_player/VideoPlayerController-class.html)

>[!warning] 
>Don't call `VideoPlayerController.initialize()`. This method is called automatically by the `VideoPlayerWidget` and the widget shows loading indicator while it is initialising.

You can force a specific aspect ratio by setting `forcedAspectRatio`:
```dart
VideoPlayerWidget(
	VideoPlayerController.networkUrl(
		Uri.parse(  
		    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
		)
	), 
	forcedAspectRatio: 2.0/1.0
)
```
## Appearance
The widget will appear at `forcedAspectRatio` while loading or playing regardless of the video ratio (if set):
![image](../../attachments/Pasted%20image%2020250220182613.png)

Otherwise - 

The widget appears as a 16:9 rectangle while loading:
![image](../../attachments/Pasted%20image%2020250220182218.png)

This is replaced with a video player matching the aspect ratio of the video when it loads:
![image](../../attachments/Pasted%20image%2020250220182332.png)