boolean mouseControl = false;
boolean cursorVisible = true;
boolean colored = true;
boolean mandelbrot = false;
int animating = 0;
int zooming = 0;

int defaultMaxIterations = 64;
int maxIterations = defaultMaxIterations;
int escapeValue = 8;

double c1;
double c2;

double defaultSize = 2;
double size;

double centerX;
double centerY;
double minX;
double maxX;
double minY;
double maxY;

float zoomIncrementAuto = 1.1;
float zoomIncrementStep = 4;
float navigationIncrement = 0.01;
int maxIterationIncrement = 100;

float screenRatio;
int colorRange = 360;

CardioidAnimation animation = new CardioidAnimation();
Recorder recorder = new Recorder();

void setup() {
  size(400, 400);
  screenRatio = (float) height / width;
  frameRate(30);
  cursor(CROSS);
  colorMode(HSB, colorRange);
  background(0);
  noLoop();
  resetJuliaSet();
}

void draw() {
  if (animating != 0) {
    animate(animating);
  }
  if (zooming != 0) {
    zoom(zooming, zoomIncrementAuto);
  }
  generateImage();
  if (recorder.isRecording()) { 
    recorder.captureFrame(zooming);
  }
}

void generateImage() {
  loadPixels();
  int counter = 0;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int formulaOutput = applyFormula(x, y);
      pixels[counter + x] = getPixelColor(formulaOutput);
    }
    counter += width;
  }
  updatePixels();
}

int applyFormula(int x, int y) {
  double a = mapper(x, 0, width, minX, maxX);
  double b = mapper(y, 0, height, minY, maxY);

  if (mandelbrot) {
    c1 = a;
    c2 = b;
  }

  int counter = 0;
  while (counter < maxIterations) {
    double aa = a * a;
    double bb = b * b;
    double ab2 = a * b * 2;
    a = aa - bb + c1;
    b = ab2 + c2;
    double result = a + b;
    if (result > escapeValue || result < -escapeValue) {
      break;
    }
    counter++;
  }
  return counter;
}

color getPixelColor(int n) { 
  if (colored && n != maxIterations) {
    return color(n % colorRange, colorRange, colorRange);
  } else {
    return color((maxIterations - n) % colorRange);
  }
}

void keyPressed() {
  if (key == '2') {
    maxIterations += maxIterationIncrement;
  } else if (key == '1' && maxIterations - maxIterationIncrement > 0) {
    maxIterations -= maxIterationIncrement;
  } else if (key == 'w') {
    zoom(-1, zoomIncrementStep);
  } else if (key == 'q') {
    zoom(1, zoomIncrementStep);
  } else if (key == 'r') {
    recorder.toggleRecording();
  } else if (key == '+') {
    escapeValue++;
  } else if (key == '-' && escapeValue > 0) {
    escapeValue--;
  } else if (key == 'm' && !mandelbrot) {
    toggleMouseControl();
  } else if (key == 'n') {
    toggleCursorVisible();
  } else if (key == 's') {
    setAnimating(1);
  } else if (key == 'a') {
    setAnimating(-1);
  } else if (keyCode > 36 && keyCode < 41) {
    navigate();
  } else if (key == 'c') {
    toggleColored();
  } else if (key == '.') {
    resetMandelbrotSet();
  } else if (key == ',') {
    resetJuliaSet();
  } else if (key == 'i') {
    setZooming(-1);
  } else if (key == 'o') {
    setZooming(1);
  } else if (key == ' ') {
    freeze();
  } else if (key == 'p') {
    resetPosition();
  } else if (key == 'z') {
    resetZoom(); 
  }
  setLoop();
  redraw();
}

void toggleMouseControl() {
  mouseControl = !mouseControl;
  mapMouseToConstant();
  freeze();
  animation.reset();
}

void setAnimating(int direction) {
  if (mandelbrot) {
    return;
  }
  if (animating == direction) {
    animating = 0;
  } else {
    animating = direction;
    mouseControl = false;
  }
}

void setZooming(int direction) {
  if (zooming == direction) {
    zooming = 0;
  } else {
    zooming = direction;
  }
}

void setLoop() {
  if (animating != 0 || zooming != 0) {
    loop();
  } else {
    noLoop();
  }
}

void toggleCursorVisible() {
  if (cursorVisible) {
    noCursor();
  } else {
    cursor(CROSS);
  }
  cursorVisible = !cursorVisible;
}

void animate(int direction) {
  if (mandelbrot) {
    animating = 0;
    return;
  }
  animation.setNextFrame(direction);
  c1 = animation.getC1();
  c2 = animation.getC2();
}

void zoom(int direction, float increment) {
  size *= pow(increment, direction);
  println(size);
  setFrame();
}

void mouseDragged() {
  dragPicture();
}

void dragPicture() {
  centerX += mapper(pmouseX - mouseX, 0, width, 0, size * 2);
  centerY += mapper(pmouseY - mouseY, 0, height, 0, size * 2 * screenRatio);
  setFrame();
  redraw();
}

void mouseClicked() {
  centerX = mapper(mouseX, 0, width, minX, maxX);
  centerY = mapper(mouseY, 0, height, minY, maxY);
  setFrame();
  redraw();
}

void mouseMoved() {
  if (mouseControl && animating == 0 && !mandelbrot) {
    mapMouseToConstant();
    redraw();
  }
}

void toggleColored() {
  colored = !colored;
}

void mapMouseToConstant() {
  c1 = mapper(mouseX, 0, width, -1, 1);
  c2 = mapper(mouseY, 0, height, -1, 1);
}

void navigate() {
  centerX += size * navigationIncrement * (keyCode == RIGHT ? 1 : keyCode == LEFT ? -1 : 0);
  centerY += size * navigationIncrement * (keyCode == DOWN ? 1 : keyCode == UP ? -1 : 0);
  setFrame();
}

void resetJuliaSet() {
  mandelbrot = false;
  mouseControl = false;
  freeze();
  resetAll();
  resetMaxIterations();
  animation.reset();
}

void resetMandelbrotSet() {
  mandelbrot = true;
  mouseControl = false;
  freeze();
  resetAll();
  resetMaxIterations();
}

void freeze() {
  zooming = 0;
  animating = 0;
}

double mapper(double value, double start1, double stop1, double start2, double stop2) {
  return (value - start1) / (stop1 - start1) * (stop2 - start2) + start2;
}

void resetAll() {
  resetPosition();
  resetZoom();
  setFrame();
}

void resetZoom() {
  size = defaultSize;
  setFrame();
}

void resetPosition() {
  centerX = mandelbrot ? -0.5 : 0;
  centerY = 0;
  setFrame();
}

void setFrame() {
  minX = centerX - size;
  maxX = centerX + size;
  minY = centerY - size * screenRatio;
  maxY = centerY + size * screenRatio;
}

void resetMaxIterations() {
  maxIterations = defaultMaxIterations;
}
