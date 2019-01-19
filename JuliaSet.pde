int maxIterations = 20;
int threshold = 2;

boolean mouseControlled = false;
boolean animating = false;
float rads = PI * 1.5;
float radius = 0.2625;
float origoX = -0.0125;
float speed = 0.001;

float minX = -2;
float maxX = 2;

// FullScreen
float minY = -2 * 0.5625;
float maxY = 2 * 0.5625;

// Square Window
// float minY = -2;
// float maxY = 2;

float zoomIncrement = 0.05;

float c1 = -0.8;
float c2 = 0;

int minCol = 0;
int maxCol = 100;
int colRange = 100;

void setup() {
  // size(900, 900);
  fullScreen();
  frameRate(30);
  //cursor(CROSS);
  noCursor();
  colorMode(HSB, colRange);
  background(maxCol, 100, 100);
}

void draw() {
  if (animating) {
    animate(true);
  }
  background(maxCol, 100, 100);
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
      } else if (n > threshold) {
        pixels[yy + x] = color(map(maxIterations - n, 0, maxIterations, minCol, maxCol), colRange, colRange);
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
  }
  if (key == ',' && threshold > 2) {
    threshold--;
  }
  if (key == 's' && maxIterations > 0) {
    maxIterations--;
    println(maxIterations);
  }
  if (key == 'w' && maxIterations < 100) {
    maxIterations++;
    println(maxIterations);
  }
  if (key == '+' && maxX - minX > zoomIncrement * 3) {
    zoom(true);
  }
  if (key == '-' && maxX - minX < 4) {
    zoom(false);
  }
  if (keyCode == UP && minY > -2) {
    navigate(UP);
  }
  if (keyCode == DOWN && maxY < 2) {
    navigate(DOWN);
  }
  if (keyCode == LEFT && minX > -2) {
    navigate(LEFT);
  }
  if (keyCode == RIGHT && maxX < 2) {
    navigate(RIGHT);
  }
  if (key == 'm') {
    mouseControlled = !mouseControlled;
    trackMouse();
  }
  if (key == 'd') {
    animate(true);
  }
  if (key == 'a') {
    animate(false);
  }
  if (key == ' ') {
    toggleAnimating();
  }
  loop();
}

void toggleAnimating() {
  animating = ! animating;
}

void animate(boolean direction) {
  rads += speed * (direction ? 1 : -1);
  float rads2 = rads * 2 + PI / 2;
  float tempX = radius * 2 * sin(rads) + origoX;
  float tempY = radius * 2 * cos(rads);
  c1 = tempX + sin(rads2) * radius;
  c2 = tempY + cos(rads2) * radius;
}

void zoom(boolean in) {
  minX += zoomIncrement * (in ? 1 : -1);
  maxX += zoomIncrement * (in ? -1 : 1);
  minY += zoomIncrement * (in ? 1 : -1);
  maxY += zoomIncrement * (in ? -1 : 1);
}

void navigate(int direction) {
  int verticalDiff = (direction == UP ? -1 : (direction == DOWN ? 1 : 0));
  int horizontalDiff = (direction == LEFT ? -1 : (direction == RIGHT ? 1 : 0));
  minX += zoomIncrement * horizontalDiff;
  maxX += zoomIncrement * horizontalDiff;
  minY += zoomIncrement * verticalDiff;
  maxY += zoomIncrement * verticalDiff;
}

// for Julia Set
void mouseMoved() {
  if (mouseControlled) {
    println("c1:" + c1 + "   c2:" + c2);
    trackMouse();
    loop();
  }
}

void trackMouse() {
  c1 = map(mouseX, 0, width, -1, 1);
  c2 = map(mouseY, 0, height, -1, 1);
}
