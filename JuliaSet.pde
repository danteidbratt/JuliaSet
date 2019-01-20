int maxIterations = 20;
int threshold = 1;

boolean mouseControlled = false;
boolean cursorVisible = true;
boolean animating = false;

float rads = PI * 1.5;
float radius = 0.2625;
float cardioidCenter = -0.0125;
float speed = 0.005;

float minX = -2;
float maxX = 2;
float minY = -2;
float maxY = 2;

float screenRatio;
float zoomIncrement = 2.0;

float c1 = -0.8;
float c2 = 0;

int minCol = 0;
int maxCol = 180;
int colRange = 200;

void setup() {
  // size(800, 800);
  fullScreen();
  screenRatio = (float) height / width;
  minY *= screenRatio;
  maxY *= screenRatio;
  frameRate(30);
  cursor(CROSS);
  colorMode(HSB, colRange);
  background(maxCol, colRange, colRange);
}

void draw() {
  if (animating) {
    animate(true);
  }
  background(maxCol, colRange, colRange);
  loadPixels();
  for (int y = 0; y < height; y++) {
    int yy = y * width;

    for (int x = 0; x < width; x++) {
      int n = 0;
      float a = map(x, 0, width, minX, maxX);
      float b = map(y, 0, height, minY, maxY);

      // For Mandelbrot Set
      // c1 = a;
      // c2 = b;

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

      if (n == maxIterations) {
        pixels[yy + x] = color(0);
      } else {
        pixels[yy + x] = color(((maxIterations - n) * 5) % maxCol, colRange, colRange);
      }
    }
  }
  updatePixels();
  if (!animating) {
    noLoop();
  }
}

void keyPressed() {
  if (key == '.' && threshold < maxIterations) {
    threshold++;
  } else if (key == ',' && threshold > 0) {
    threshold--;
  } else if (key == 's' && maxIterations > 0) {
    maxIterations--;
  } else if (key == 'w' && maxIterations < colRange) {
    maxIterations++;
  } else if (key == '+' && maxX - minX > zoomIncrement * 3) {
  } else if (key == '-' && maxX - minX < 4) {
  } else if (keyCode == UP) {
    zoom(true);
  } else if (keyCode == DOWN) {
    zoom(false);
  } else if (keyCode == LEFT && minX > -2) {
  } else if (keyCode == RIGHT && maxX < 2) {
  } else if (key == 'm') {
    mouseControlled = !mouseControlled;
  } else if (key == 'c') {
    toggleCursor();
  } else if (key == 'd') {
    animate(true);
  } else if (key == 'a') {
    animate(false);
  } else if (key == ' ') {
    toggleAnimating();
  }
  loop();
}

void toggleAnimating() {
  animating = !animating;
}

void toggleCursor() {
  if (cursorVisible) {
    noCursor();
  } else {
    cursor(CROSS);
  }
  cursorVisible = !cursorVisible;
}

void animate(boolean direction) {
  rads += speed * (direction ? 1 : -1);
  float rads2 = rads * 2 + PI / 2;
  float tempX = radius * 2 * sin(rads) + cardioidCenter;
  float tempY = radius * 2 * cos(rads);
  c1 = tempX + sin(rads2) * radius;
  c2 = tempY + cos(rads2) * radius;
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
  if (mouseControlled && !animating) {
    trackMouse();
    loop();
  }
}

void trackMouse() {
  c1 = map(mouseX, 0, width, -1, 1);
  c2 = map(mouseY, 0, height, -1, 1);
}
