class GeneratorOptions {
  String destination;
  String codec;
  double fps;

  GeneratorOptions.defaultSettings(this.destination)
      : codec = "H.256",
        fps = 60;
}
