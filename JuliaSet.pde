boolean mouseControl = false;
boolean cursorVisible = true;
boolean colored = true;
boolean mandelbrot = false;

int animating = 0;
int zooming = 0;

int maxIterations = 32;
int escapeValue = 8;

double constantX = -0.8;
double constantY = 0;
double minX = -2;
double maxX = 2;
double minY = -2;
double maxY = 2;

float cardioidAngle = PI * 1.5;
float cardioidRadius = 0.2625;
float cardioidCenter = -0.0125;

float animationIncrement = 0.001;
float zoomIncrement = 4;
float navigationIncrement = 0.01;
int iterationIncrement = 100;

double defaultX = -0.5;
double defaultY = 0;

float screenRatio;
int colorRange = 360;

void setup() {
  size(800, 800);
  screenRatio = (float) height / width;
  resetScope();
  frameRate(50);
  cursor(CROSS);
  colorMode(HSB, colorRange);
  background(0);
  noLoop();
}

void draw() {
  if (animating != 0) {
    animate(animating);
  }
  if (zooming != 0) {
    zoom(zooming);
  }
  generateImage();
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
    constantX = a;
    constantY = b;
  }

  int counter = 0;
  while (counter < maxIterations) {
    double aa = a * a;
    double bb = b * b;
    double ab2 = a * b * 2;
    a = aa - bb + constantX;
    b = ab2 + constantY;
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
    maxIterations += iterationIncrement;
  } else if (key == '1' && maxIterations - iterationIncrement > 0) {
    maxIterations -= iterationIncrement;
  } else if (key == 'w') {
    zoom(-1);
  } else if (key == 'q') {
    zoom(1);
  } else if (key == '+') {
    escapeValue++;
  } else if (key == '-' && escapeValue > 0) {
    escapeValue--;
  } else if (key == 'm' && !mandelbrot) {
    toggleMouseControl();
  } else if (key == 'n') {
    toggleCursorVisible();
  } else if (key == 'x') {
    toggleAnimating(1);
  } else if (key == 'z') {
    toggleAnimating(-1);
  } else if (keyCode > 36 && keyCode < 41) {
    navigate();
  } else if (key == 'c') {
    toggleColored();
  } else if (key == '.') {
    resetMandelbrotSet();
  } else if (key == ',') {
    resetJuliaSet();
  } else if (key == 'i') {
    toggleZooming(-1);
  } else if (key == 'o') {
    toggleZooming(1);
  } else if (key == ' ') {
    freeze();
  }
  setLoop();
  redraw();
}

void toggleMouseControl() {
  mouseControl = !mouseControl;
  mapMouseToConstant();
  freeze();
  resetAnimation();
}

void toggleAnimating(int direction) {
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

void toggleZooming(int direction) {
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
  cardioidAngle += animationIncrement *  direction;
  float tempAngle = cardioidAngle * 2 + PI / 2;
  float tempX = cardioidRadius * 2 * sin(cardioidAngle) + cardioidCenter;
  float tempY = cardioidRadius * 2 * cos(cardioidAngle);
  constantX = tempX + sin(tempAngle) * cardioidRadius;
  constantY = tempY + cos(tempAngle) * cardioidRadius;
}

void zoom(int direction) {
  double midX = (minX + maxX) / 2;
  double midY = (minY + maxY) / 2;
  double zoomRatio = pow(zoomIncrement, direction);
  minX = midX - (midX - minX) * zoomRatio;
  maxX = midX + (maxX - midX) * zoomRatio;
  minY = midY - (midY - minY) * zoomRatio;
  maxY = midY + (maxY - midY) * zoomRatio;
}

void mouseDragged() {
  dragPicture();
  redraw();
}

void dragPicture() {
  double xDiff = mapper(pmouseX - mouseX, 0, width, 0, maxX - minX);
  double yDiff = mapper(pmouseY - mouseY, 0, height, 0, maxY - minY);
  minX += xDiff;
  maxX += xDiff;
  minY += yDiff;
  maxY += yDiff;
}

void mouseClicked() {
  double selectedX = mapper(mouseX, 0, width, minX, maxX);
  double selectedY = mapper(mouseY, 0, height, minY, maxY);
  setCenter(selectedX, selectedY);
  redraw();
}

void setCenter(double selectedX, double selectedY) {
  double xDistance = maxX - ((maxX + minX) / 2);
  double yDistance = maxY - ((maxY + minY) / 2);
  minX = selectedX - xDistance;
  maxX = selectedX + xDistance;
  minY = selectedY - yDistance;
  maxY = selectedY + yDistance;
  println("X:" + selectedX + " Y:" + selectedY);
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
  constantX = mapper(mouseX, 0, width, -1, 1);
  constantY = mapper(mouseY, 0, height, -1, 1);
}

void navigate() {
  int xDirection = (keyCode == RIGHT ? 1 : keyCode == LEFT ? -1 : 0);
  int yDirection = (keyCode == DOWN ? 1 : keyCode == UP ? -1 : 0);
  double xTotal = maxX - minX;
  double yTotal = maxY - minY;
  double xDiff = xTotal * navigationIncrement * xDirection; 
  double yDiff = yTotal * navigationIncrement * yDirection;
  minX += xDiff;
  maxX += xDiff;
  minY += yDiff;
  maxY += yDiff;
}

void resetJuliaSet() {
  mandelbrot = false;
  freeze();
  resetScope();
  resetAnimation();
  constantX = -0.8;
  constantY = 0;
}

void resetMandelbrotSet() {
  mandelbrot = true;
  mouseControl = false;
  freeze();
  resetScope();
  setCenter(defaultX, defaultY);
}

void resetScope() {
  minX = -2;
  maxX = 2;
  minY = -2 * screenRatio;
  maxY = 2 * screenRatio;
}

void freeze() {
  zooming = 0;
  animating = 0;
}

void resetAnimation() {
  cardioidAngle = PI * 1.5;
}

double mapper(double value, double start1, double stop1, double start2, double stop2) {
  return (value - start1) / (stop1 - start1) * (stop2 - start2) + start2;
}
