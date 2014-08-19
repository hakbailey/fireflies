import processing.video.*;
import neurosky.*;
import org.json.*;
 
ThinkGearSocket neuroSocket;
int attention = 0;
int meditation = 0;
int blink = 0;
float delta = 0;
Fly[] flies = new Fly[200];
Tree[] trees = new Tree[6];
ArrayList<PVector> forces = new ArrayList<PVector>();
ArrayList<Fly> greenFlies = new ArrayList<Fly>();
ArrayList<Fly> yellowFlies = new ArrayList<Fly>();
Tree ttemp;
color cTemp;
boolean sync = false;
boolean wind = false;
PVector w;

void setup() {
  size(displayWidth, displayHeight, P3D);
  colorMode(HSB, 360);
  smooth();
  noStroke();
  textureMode(NORMAL);
  textureWrap(REPEAT);

  for (int i = 0; i < trees.length; i++) {
    pushMatrix();
      trees[i] = (new Tree(random(width), height, random(-150, 0), (int)random(6, 8), (int)random(12, 14)));
    popMatrix();
  }
  
  for (int i = 0; i < flies.length; i++) {
    flies[i] = new Fly(random(width), random(height-100), random(-20, 20), random(1000, 3500), random(2500, 7000));
  }

  ThinkGearSocket neuroSocket = new ThinkGearSocket(this);
  try {
    neuroSocket.start();
  } catch (Exception e) {
    e.printStackTrace();
  }
}

void draw() {
  lights();
  background(235, 120, 79);
  for (int i = 0; i < trees.length; i++) {
    ttemp = trees[i];
    float zVal = map(ttemp.zBase, -150, 0, 80, 160);
    cTemp = color(20, 95, (int)zVal);
    tint(cTemp);
    fill(cTemp);
    pushMatrix();
      translate(ttemp.xBase, ttemp.yBase, ttemp.zBase); 
      ttemp.display();
    popMatrix();
  }
  
  for (int i = 0; i < flies.length; i++) {
    flies[i].applyForces(forces);
    flies[i].update();
    flies[i].flash();
    flies[i].display();
    flies[i].checkEdges();
  }
}

// Mode changes
void keyPressed() {
  switch(key) { 
  case 's':
    if (!sync) {
      for (int i = 0; i < flies.length; i++) {
        flies[i].flashLength = 2000;
        flies[i].dimLength = 3000;
        flies[i].timer = millis();
        flies[i].flash = true;
      }
      sync = true;
    } else if (sync) {
      for (int i = 0; i < flies.length; i++) {
        flies[i].flashLength = flies[i].initFlashLength;
        flies[i].dimLength = flies[i].initDimLength;
      }
      sync = false;
    }
    break;
  case 'w':
    if (wind) {
      int i = forces.indexOf(w);
      forces.remove(i);
      wind = false;
    } else {
      w = new PVector(1, 0, 0);
      forces.add(w);
      wind = true;
    }
    break;
  default:
    break;
  }
}

//public void eegEvent(int _delta, int theta, int low_alpha, int high_alpha, int low_beta, int high_beta, int low_gamma, int mid_gamma) {
//  delta = _delta;
//  //  eeg = "Delta: " + delta + ", theta: " + theta + ", low alpha: " + low_alpha + ", high alpha: " + high_alpha;
//}

//public void attentionEvent(int attentionLevel) {
//  attention = attentionLevel;
//}

public void meditationEvent(int meditationLevel) {
  meditation = meditationLevel;
}

void stop() {
  neuroSocket.stop();
  super.stop();
}
