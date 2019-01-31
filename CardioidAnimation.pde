class CardioidAnimation {
  private final float defaultAngle = PI * 1.5;
  private final float angleIncrement = 0.001;
  private final float center = -0.0125;
  private final float radius = 0.2625;
  private float angle;
  private float c1;
  private float c2;

  public CardioidAnimation() {
    this.angle = this.defaultAngle;
  }

  void setNextFrame(int direction) {
    angle += angleIncrement *  direction;
    float tempAngle = angle * 2 + PI / 2;
    float tempX = radius * 2 * sin(angle) + center;
    float tempY = radius * 2 * cos(angle);
    c1 = tempX + sin(tempAngle) * radius;
    c2 = tempY + cos(tempAngle) * radius;
  }

  void reset() {
    angle = defaultAngle;
    animate(0);
  }

  public float getC1() {
    return c1;
  }

  public float getC2() {
    return c2;
  }
}
