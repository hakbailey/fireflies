class Tree {
  ArrayList branchCoords;
  float dtheta = 0.1;
  float x1, y1, z1, x2, y2, z2;
  int probBranch;
  int treeDepth;
  float xBase, yBase, zBase;
  int numSides = 10;
  PImage bark = loadImage("bark_03.jpg");
  
  Tree(float x, float y, float z, int pb, int td) {
    branchCoords = new ArrayList();
    probBranch = pb;
    treeDepth = td;
    xBase = x;
    yBase = y;
    zBase = z;
    generateBranch(0);
  }
  
  // Recursively creates branches and stores x,y,z coordinates of branch endpoint
  void generateBranch(int depth) {
    if (depth < treeDepth) {
      x1 = modelX(0, 0, 0);
      y1 = modelY(0, 0, 0);
      z1 = modelZ(0, 0, 0);
      translate(0, -height/(depth+6), 0);
      x2 = modelX(0, 0, 0);
      y2 = modelY(0, 0, 0);
      z2 = modelZ(0, 0, 0);
      float[] tempArray = { x1, y1, z1, x2, y2, z2, depth };
      branchCoords.add(tempArray);
      rotate(random(-dtheta, dtheta));
      
      if (random(10) < probBranch) {
//        scale(0.8);
        rotate(0.3);
      
        pushMatrix();
          generateBranch(depth + 1);
        popMatrix();
      
        rotate(-0.6);
        
        pushMatrix();
          generateBranch(depth + 1);
        popMatrix();
      }
    
      else {
        generateBranch(depth + 1);
      }
    }
  }
  
  // Draws the tree branches using stored x, y, and z coordinates
  void display() {
    for (int i = 0; i < branchCoords.size(); i++) {
      float[] tempArray = (float[])branchCoords.get(i);
      float weight = treeDepth - (float)tempArray[6];
      drawCylinder(numSides, weight+1, weight + 2, tempArray[0], tempArray[1], tempArray[2], tempArray[3], tempArray[4], tempArray[5]);
    }
  }
  
  void drawCylinder(int sides, float tr, float br, float _x1, float y1, float _z1, float _x2, float y2, float _z2) {
    float angle = 360 / sides;
    beginShape(QUAD_STRIP);
    texture(bark);
    for (int i = 0; i < sides + 1; i++) {
      float x1 = _x1 + cos( radians( i * angle ) ) * br;
      float z1 = _z1 + sin( radians( i * angle ) ) * br;
      float x2 = _x2 + cos( radians( i * angle ) ) * tr;
      float z2 = _z2 + sin( radians( i * angle ) ) * tr;
      if (i % 2 == 0) {
        vertex(x1, y1, z1, 0, 4);
        vertex(x2, y2, z2, 0, 0);  
      } else {
          vertex(x1, y1, z1, 1, 4);
          vertex(x2, y2, z2, 1, 0);
      }  
    }
    endShape(CLOSE);
  }
}
