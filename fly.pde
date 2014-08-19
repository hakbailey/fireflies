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
  int topspeed = 3;
  float n, m;
  
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
    if (random(1) < 0.5) {
      cFlash = color(125, 300, 360); //green flash
      greenFlies.add(this);
    } else {
      cFlash = color(50, 300, 360); //yellow flash
      yellowFlies.add(this);
    }
    cDim = color(0, 0, 84, 80);
    if (random(1) < 0.5) {
      flash = false;
    } else {
      flash = true;
    }
  }
  
  // Update firefly location
  void update() {
    PVector v = PVector.add(velocity, acceleration);
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
  
  // Set firefly flashlength
  void setFlash(float nf) {
    flashLength = nf;
  }
  
  // Draw firefly
  void display() {
    pushMatrix();
      translate(location.x, location.y, location.z);
      if (flash) {
        for (float i=0; i<1.0; i+=0.01) {
          cTemp = lerpColor(cDim, cFlash, i);
          fill(cTemp);
        }
      } else {
          for (float i=0; i<1.0; i+=0.01) {
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
    
//    // Randomize acceleration direction and set its magnitude based on meditation state
//    acceleration = PVector.random3D();
//    acceleration.mult(0.01);
//    
//    if (meditation != 0) {
//      med2 = 100-meditation;
//      if (meditation >= 60) {
//        m = map(med2, 0, 40, -1, -0.0001);
//      } else {
//        m = map(med2, 40, 100, 0.0001, 1);
//      }
////      acceleration = new PVector(velocity.x*m, velocity.y*m, velocity.z*m);
//     acceleration.setMag(m);
//    }
//    println("m = " + m);
//    println("acceleration = " + acceleration);
//  }
    
}
