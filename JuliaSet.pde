boolean mouseControl = false;
boolean cursorVisible = true;
boolean colored = true;
boolean mandelbrot = false;
int animating = 0;
int zooming = 0;

float cardioidAngle = PI * 1.5;
float cardioidRadius = 0.2625;
float cardioidCenter = -0.0125;
float animationSpeed = 0.001;

float zoomIncrement = 1.1;
float navigationSpeed = 0.01;

int maxIterations = 32;
// int maxIterationsLimit = 1000;
// int colorRotations = 10;
// int colorRange = maxIterationsLimit / colorRotations;
int colorRange = 200;
int escapeValue = 8;
float c1 = -0.8;
float c2 = 0;

float minX = -2;
float maxX = 2;
float minY = -2;
float maxY = 2;

float screenRatio;

void setup() {
  // size(200, 200);
  fullScreen();
  screenRatio = (float) height / width;
  resetPosition();
  frameRate(50);
  cursor(CROSS);
  colorMode(HSB, colorRange);
  background(0);
  
}

void draw() {
  setLoop();
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
  float a = map(x, 0, width, minX, maxX);
  float b = map(y, 0, height, minY, maxY);
  
  if (mandelbrot) {
    c1 = a;
    c2 = b;
  }

  int counter = 0;
  while (counter < maxIterations) {
    float aa = sq(a);
    float bb = sq(b);
    float ab2 = a * b * 2;
    a = aa - bb + c1;
    b = ab2 + c2;
    if (abs(a + b) > escapeValue) {
      break;
    }
    counter++;
  }
  return counter;
}

color getPixelColor(int n) { 
  int x = maxIterations - n;
  if (colored && x != 0) {
    return color(x % colorRange, colorRange, colorRange);
  } else {
    return color(x % colorRange);
  }
}

void keyPressed() {
  if (key == '2') {
    maxIterations += 5;
  } else if (key == '1' && maxIterations > 0) {
    maxIterations -= 5;
  } else if (key == '+') {
    escapeValue++;
  } else if (key == '-') {
    if (escapeValue > 0) {
     escapeValue--; 
    }
  } else if (key == 'm') {
    mouseControl = !mouseControl;
    trackMouse();
    freeze();
    resetAnimation();
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
  } else if (key == 'r') {
    resetPosition();
  } else if (key == 'i') {
    toggleZooming(-1);
  } else if (key == 'o') {
    toggleZooming(1);
  } else if (key == ' ') {
    freeze();
  }
  redraw();
  setLoop();
}

void toggleAnimating(int direction) {
  if (mandelbrot) {
    return;
  }
  if (animating == direction) {
    animating = 0;
  } else {
    animating = direction; 
  }
  setLoop();
}

void toggleZooming(int direction) {
  if (zooming == direction) {
    zooming = 0;
  } else {
    zooming = direction;
  }
  setLoop();
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
  cardioidAngle += animationSpeed *  direction;
  float tempAngle = cardioidAngle * 2 + PI / 2;
  float tempX = cardioidRadius * 2 * sin(cardioidAngle) + cardioidCenter;
  float tempY = cardioidRadius * 2 * cos(cardioidAngle);
  c1 = tempX + sin(tempAngle) * cardioidRadius;
  c2 = tempY + cos(tempAngle) * cardioidRadius;
}

void zoom(int direction) {
  float midX = (minX + maxX) / 2;
  float midY = (minY + maxY) / 2;
  float zoomRatio = pow(zoomIncrement, direction);
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
  float selectedX = map(mouseX, 0, width, minX, maxX);
  float selectedY = map(mouseY, 0, height, minY, maxY);
  float xDistance = maxX - ((maxX + minX) / 2);
  float yDistance = maxY - ((maxY + minY) / 2);
  minX = selectedX - xDistance;
  maxX = selectedX + xDistance;
  minY = selectedY - yDistance;
  maxY = selectedY + yDistance;
  loop();
}

void mouseMoved() {
  if (mouseControl && animating == 0 && !mandelbrot) {
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

void navigate() {
  int xDirection = (keyCode == RIGHT ? 1 : keyCode == LEFT ? -1 : 0);
  int yDirection = (keyCode == DOWN ? 1 : keyCode == UP ? -1 : 0);
  float xTotal = maxX - minX;
  float yTotal = maxY - minY;
  float xDiff = xTotal * navigationSpeed * xDirection; 
  float yDiff = yTotal * navigationSpeed * yDirection;
  minX += xDiff;
  maxX += xDiff;
  minY += yDiff;
  maxY += yDiff;
}

void resetJuliaSet() {
  mandelbrot = false;
  freeze();
  resetPosition();
  resetAnimation();
  c1 = -0.8;
  c2 = 0;
}

void resetMandelbrotSet() {
  mandelbrot = true;
  mouseControl = false;
  freeze();
  resetPosition();
}

void resetPosition() {
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
