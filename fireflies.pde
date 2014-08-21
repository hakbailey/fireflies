import processing.video.*;
import neurosky.*;
//import org.json.*;
 
ThinkGearSocket neuroSocket;
MindSetSerial[] headsets = new MindSetSerial[2];
//int attention = 0;
//int meditation = 0;
//int blink = 0;
//float delta = 0;
ArrayList<Fly> flies = new ArrayList<Fly>();
Tree[] trees = new Tree[6];
ArrayList<PVector> forces = new ArrayList<PVector>();
ArrayList<Fly> greenFlies = new ArrayList<Fly>();
ArrayList<Fly> yellowFlies = new ArrayList<Fly>();
Tree ttemp;
color cTemp;

// Serial headset
final boolean useThinkGear = false;
final int portOne = 2;
final int portTwo = 18;

boolean sync = false;
boolean wind = false;
boolean delta_mode = false;
boolean meditate = false;
boolean attention = false;
PVector w;
int numFlies = 150;
int signal;
int t = 10000;
PImage bg;

void setup() {
  size(displayWidth, displayHeight, P3D);
  colorMode(HSB, 360);
  smooth();
  noStroke();
  textureMode(NORMAL);
  textureWrap(REPEAT);
  println(Serial.list());
  bg = loadImage("mountains_08_cc.jpg");
  bg.resize(width, height);

  for (int i = 0; i < trees.length; i++) {
    pushMatrix();
      trees[i] = (new Tree(random(width), height, random(-150, 0), (int)random(6, 8), (int)random(12, 14)));
    popMatrix();
  }
  
  for (int i = 0; i < numFlies; i++) {
    flies.add(new Fly(random(width), random(height-100), random(-20, 20), random(1000, 3500), random(2500, 7000)));
  }
  if(useThinkGear) {
    ThinkGearSocket neuroSocket = new ThinkGearSocket(this);
    try {
      neuroSocket.start();
    } catch (Exception e) {
      e.printStackTrace();
    }
  } else {
    headsets[0] = new MindSetSerial(portOne,this, 0);
    headsets[0].start();
    headsets[1] = new MindSetSerial(portTwo,this, 1);
    headsets[1].start();
  }
}

void draw() {
  headsets[0].update();
  headsets[1].update();
  lights();
  background(235, 120, 79);
  background(bg);
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
  
  if (headsets[0].signal) {
    for (int i = 0; i < greenFlies.size(); i++) {
      if (delta_mode) {
        if (headsets[0].delta >= 25000) {
          greenFlies.get(i).flash = true;
        } else {
          greenFlies.get(i).flash = false;
        }
      }
      
      float hue = hue(greenFlies.get(i).cFlash);
      if (attention) {
        float brightness = map(headsets[0].attention, 0, 100, 100, 300);
        greenflies.get(i).cFlash = color(hue, 300, brightness);
      } else {
        greenFlies.get(i).cFlash = color(hue, 300, 360);
      }
    }
  }
      
  if (headsets[1].signal) {
    for (int i = 0; i < yellowFlies.size(); i++) {
      if (delta_mode) {
        if (headsets[1].delta >= 25000) {
          yellowFlies.get(i).flash = true;
        } else {
          yellowFlies.get(i).flash = false;
        }
      }
      
      float hue = hue(yellowFlies.get(i).cFlash);
      if (attention) {
        float brightness = map(headsets[1].attention, 0, 100, 100, 300);
        yellowFlies.get(i).cFlash = color(hue, 300, brightness);
      } else {
        yellowFlies.get(i).cFlash = color(hue, 300, 360);
      }

    }
  }
  
  for (int i = 0; i < flies.size(); i++) {
    flies.get(i).applyForces(forces);
    flies.get(i).update();
    flies.get(i).flash();
    flies.get(i).display();
    flies.get(i).checkEdges();
  }
}

// Mode changes
void keyPressed() {
  switch(key) { 
  case 'a':
    if(attention) {
      attention = false;
    } else {
      attention = true;
    }
  case 's':
    if (!sync) {
      sync = true;
      syncFlash(flies, random(1000, 3000), random(2000, 5000));
    } else if (sync) {
      sync = false;
      unSyncFlash(flies);
    }
    break;
  case 'd':
    if (delta_mode) {
      delta_mode = false;
    } else if (!delta_mode) {
      delta_mode = true;
    }
    break;
  case 'g':
    if (!sync) {
      sync = true;
      syncFlash(greenFlies, random(1000, 3000), random(2000, 5000));
    } else if (sync) {
      sync = false;
      unSyncFlash(greenFlies);
    }
    break;
  case 'm':
    if (meditate) {
      meditate = false;
    } else {
      meditate = true;
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
  case 'y':
    if (!sync) {
      sync = true;
      syncFlash(yellowFlies, random(1000, 3000), random(2000, 5000));
    } else if (sync) {
      sync = false;
      unSyncFlash(yellowFlies);
    }
    break;
  default:
    break;
  }
}

public void poorSignalEvent(int sig) {
  signal = sig;
}

public void eegEvent(int _delta, int _theta, int _low_alpha, int _high_alpha, int _low_beta, int _high_beta, int _low_gamma, int _mid_gamma) {
  //delta = _delta;
  //  eeg = "Delta: " + delta + ", theta: " + theta + ", low alpha: " + low_alpha + ", high alpha: " + high_alpha;
}

//public void attentionEvent(int attentionLevel) {
//  attention = attentionLevel;
//}

public void meditationEvent(int meditationLevel) {
  //meditation = meditationLevel;
}

void stop() {
  neuroSocket.stop();
  super.stop();
}

void syncFlash(ArrayList<Fly> flyList, float newFlash, float newDim) {
  for (int i = 0; i < flyList.size(); i++) {
    flyList.get(i).flashLength = newFlash;
    flyList.get(i).dimLength = newDim;
    flyList.get(i).timer = millis();
    flyList.get(i).flash = true;
  }
}

void unSyncFlash(ArrayList<Fly> flyList) { 
  for (int i = 0; i < flyList.size(); i++) {
    flyList.get(i).flashLength = flyList.get(i).initFlashLength;
    flyList.get(i).dimLength = flyList.get(i).initDimLength;
  }
}
