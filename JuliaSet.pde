boolean mouseControlled = false;
boolean cursorVisible = true;
boolean animating = false;
boolean colored = true;
boolean mandelbrot = false;

float cardioidAngle = PI * 1.5;
float cardioidRadius = 0.2625;
float cardioidCenter = -0.0125;
float animationSpeed = 0.005;

float zoomIncrement = 1.02;

int maxIterations = 56;
int maxIterationLimit = 120;
float minX = -2;
float maxX = 2;
float minY = -2;
float maxY = 2;
float c1 = -0.8;
float c2 = 0;

int minColor = 0;
int maxColor = 200;
int colorRange = 200;
int colorIntensity = 6;

void setup() {
  size(400, 400);
  float screenRatio = (float) height / width;
  minY *= screenRatio;
  maxY *= screenRatio;
  frameRate(50);
  cursor(CROSS);
  colorMode(HSB, colorRange);
  background(maxColor, colorRange, colorRange);
  resetJuliaSet();
}

void draw() {
  if (animating) {
    animate(true);
  } else {
    noLoop();
  }
  generateImage();
}

void generateImage() {
  background(maxColor, colorRange, colorRange);
  loadPixels();
  int aggregate = 0;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int iterations = getIterations(x, y);
      pixels[aggregate + x] = getPixelColor(iterations);
    }
    aggregate += width;
  }
  updatePixels();
}

int getIterations(int x, int y) {
  float a = map(x, 0, width, minX, maxX);
  float b = map(y, 0, height, minY, maxY);
  if (mandelbrot) {
    c1 = a;
    c2 = b;
  }
  int n = 0;
  while (n < maxIterations) {
    float aa = a * a - b * b;
    float bb = 2 * a * b;
    a = aa + c1;
    b = bb + c2;
    if (abs(a + b) > 2) {
      break;
    }
    n++;
  }
  return n;
}

color getPixelColor(int n) {
  if (n == maxIterations) {
    return color(0);
  } else {
    if (colored) {
      return color((((maxIterations - n) * colorIntensity) % maxColor), colorRange, colorRange);
    } else {
      return color((n * colorIntensity) % maxColor);
    }
  }
}

void keyPressed() {
  if (key == '2' && maxIterations < maxIterationLimit) {
    maxIterations++;
  } else if (key == '1' && maxIterations > 0) {
    maxIterations--;
  } else if (key == '+') {
    zoom(true);
  } else if (key == '-') {
    zoom(false);
  } else if (key == 'm') {
    mouseControlled = !mouseControlled;
  } else if (key == 'n') {
    toggleCursorVisible();
  } else if (key == ' ') {
    toggleAnimating();
  } else if (keyCode == RIGHT) {
    animate(true);
  } else if (keyCode == LEFT) {
    animate(false);
  } else if (key == 'c') {
    toggleColored();
  } else if (key == '.') {
    resetMandelbrotSet();
  } else if (key == ',') {
    resetJuliaSet();
  } else if (key == 'r') {
    resetPosition();
  }
  loop();
}

void toggleAnimating() {
  animating = !animating;
}

void toggleCursorVisible() {
  if (cursorVisible) {
    noCursor();
  } else {
    cursor(CROSS);
  }
  cursorVisible = !cursorVisible;
}

void animate(boolean direction) {
  if (mandelbrot) {
    animating = false;
    return;
  }
  cardioidAngle += animationSpeed * (direction ? 1 : -1);
  float rads2 = cardioidAngle * 2 + PI / 2;
  float tempX = cardioidRadius * 2 * sin(cardioidAngle) + cardioidCenter;
  float tempY = cardioidRadius * 2 * cos(cardioidAngle);
  c1 = tempX + sin(rads2) * cardioidRadius;
  c2 = tempY + cos(rads2) * cardioidRadius;
}

void zoom(boolean in) {
  float midX = (minX + maxX) / 2;
  float midY = (minY + maxY) / 2;
  float zoomRatio = (in ? 1.0 / zoomIncrement : zoomIncrement);
  minX = midX - (midX - minX) * zoomRatio;
  maxX = midX + (maxX - midX) * zoomRatio;
  minY = midY - (midY - minY) * zoomRatio;
  maxY = midY + (maxY - midY) * zoomRatio;
}

void mouseDragged() {
  float xDiff = map((float) (pmouseX - mouseX), 0, width, 0, maxX - minX);
  float yDiff = map((float) (pmouseY - mouseY), 0, height, 0, maxY - minY);
  minX += xDiff;
  maxX += xDiff;
  minY += yDiff;
  maxY += yDiff;
  loop();
}

void mouseClicked() {
  float newMidX = map(mouseX, 0, width, minX, maxX);
  float newMidY = map(mouseY, 0, height, minY, maxY);
  float xFromMid = maxX - ((maxX + minX) / 2);
  float yFromMid = maxY - ((maxY + minY) / 2);
  minX = newMidX - xFromMid;
  maxX = newMidX + xFromMid;
  minY = newMidY - yFromMid;
  maxY = newMidY + yFromMid;
  loop();
}

// for Julia Set
void mouseMoved() {
  if (mouseControlled && !animating && !mandelbrot) {
    trackMouse();
    loop();
  }
}

void toggleColored() {
  colored = !colored;
}

void trackMouse() {
  c1 = map(mouseX, 0, width, -1, 1);
  c2 = map(mouseY, 0, height, -1, 1);
}

void resetJuliaSet() {
  mandelbrot = false;
  resetPosition();
  resetAnimation();
  c1 = -0.8;
  c2 = 0;
}

void resetMandelbrotSet() {
  mandelbrot = true;
  resetPosition();
}

void resetPosition() {
  minX = -2;
  maxX = 2;
  minY = -2;
  maxY = 2;
}

void resetAnimation() {
  cardioidAngle = PI * 1.5;
}
