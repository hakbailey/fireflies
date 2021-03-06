class Fly {
  float initFlashLength, flashLength;
  float initDimLength, dimLength;
  PVector location;
  PVector velocity;
  PVector acceleration; 
  int r = 2;
  boolean flash;
  int timer, med2;
  color cFlash, cDim, cTemp;
  int topspeed = 6;
  float n, m;
  int headset = 2;
  
  Fly(float x, float y, float z, float f, float p) {
    // Initialize variables for motion
    location = new PVector(x, y, z);
    velocity = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
    acceleration = new PVector();
    
    // Initialize variables for flash pattern and color
    initFlashLength = f;
    flashLength = f;
    initDimLength = p;
    dimLength = p;
    timer = millis();
    float r = random(1);
    if (r < 0.25) {
//      cFlash = color(125, 300, 360); //green flash
//      cFlash = color(92, 151, 360); //old single color flash
        cFlash = color(108, 190, 360); //new single color flash
      greenFlies.add(this);
      headset = 0;
    } else if (r > 0.75) {
//      cFlash = color(50, 300, 360); //yellow flash
//      cFlash = color(92, 151, 360); //single color flash
        cFlash = color(108, 190, 360); //new single color flash
      yellowFlies.add(this);
      headset = 1;
    } else {
      cFlash = color(108, 190, 360); //new single color flash
    }
    cDim = color(0, 0, 84, 80);
    if (random(1) < 0.3) {
      flash = false;
    } else {
      flash = true;
    }
  }
  
  // Update firefly location
  void update() {
    PVector v = PVector.add(velocity, acceleration);
    if (meditate) {
//      if (headset < 2) {
        if (headsets[0].meditation != 0) {
          v.mult(map(100  - headsets[0].meditation, 0, 100, 0.1, 6));
        } else if( headsets[1].meditation != 0) {
          v.mult(map(100  - headsets[1].meditation, 0, 100, 0.1, 6));
        }
//      }
    }
    v.limit(topspeed);
    location.add(v);
    acceleration.mult(0);
  }
  
  // Update firefly flashes
  void flash() {
    if (flash) {
      if (millis() - timer >= flashLength) {
        flash = !flash;
        timer = millis();
      }
    } else {
      if (millis() - timer >= dimLength) {
        flash = !flash;
        timer = millis();
      }
    }
  }
  
  // Draw firefly
  void display() {
    pushMatrix();
      translate(location.x, location.y, location.z);
      if (flash) {
        for (float i=0; i<2.0; i+=0.001) {
          cTemp = lerpColor(cDim, cFlash, i);
          fill(cTemp);
        }
      } else {
          for (float i=0; i<2.0; i+=0.001) {
            cTemp = lerpColor(cFlash, cDim, i);
            fill(cTemp);
          }
      }
      sphere(r);
    popMatrix();
  }
  
  // Keep firefly in sight
  void checkEdges() {
    if (location.x < 0 + r || location.x > width - r) {
      velocity.x *= -1;
    }
    if (location.y < 0 + r || location.y > height - 100) {
      velocity.y *= -1;
    }
    if (location.z < -150 || location.z > 20 ) {
      velocity.z *= -1;
    }
  }
  
  void applyForces(ArrayList<PVector> forces) {
    for (int i=0; i<forces.size(); i++) {
      acceleration.add(forces.get(i));
    }
  }    
}
