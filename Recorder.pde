class Recorder {
  
  // .png and size(400, 400) for smooth recording
  private final String videoDirectoryTemplate = "./recordings/frames/$$$/frame-#######.png";
  private String videoDirectory;
  private String videoName;
  private boolean recording;

  public Recorder() {
    this.recording = false;
  }

  void toggleRecording() {
    recording = !recording;
    if (recording) {
      videoName = "video_" + nf((int) random(100000), 6);
      videoDirectory = videoDirectoryTemplate.replace("$$$", videoName);
      println("Recording...");
    } else {
      println("...Stopped Recording\nSaved as " + videoName);
    }
  }

  void captureFrame(int zooming) {
    if (zooming != 0) {
      saveFrame(videoDirectory);
    }
    drawRecordingDot();
  }

  void drawRecordingDot() {
    stroke(colorRange);
    strokeWeight(2);
    fill(0, colorRange, colorRange);
    ellipse(30, 30, 30, 30);
  }
  
  boolean isRecording() {
    return recording;
  }
}
