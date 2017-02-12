import codeanticode.syphon.*;

import megamu.mesh.*;
 
import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

int NUM_PARTICLES = 500;

float[][] points;

VerletPhysics2D physics;
AttractionBehavior attractor;
AttractionBehavior mouseAttractor;

Vec2D mousePos;
Vec2D pos;

float t;
float o;

boolean moving;

SyphonServer server;

void setup() {
  points = new float[NUM_PARTICLES][2];
  
  mousePos = new Vec2D(0,0);
  
  size(1280, 720,P3D);
  frameRate(30);
  // setup physics with 10% drag
  physics = new VerletPhysics2D();
  physics.setDrag(0.05f);
  physics.setWorldBounds(new Rect(0, 0, width, height));
  // the NEW way to add gravity to the simulation, using behaviors
  //physics.addBehavior(new GravityBehavior(new Vec2D(0, 0.15f)));
  
  for (int i = 0; i < NUM_PARTICLES;i++) {
    addParticle();
  }
  
  pos =  new Vec2D(0,0);
  attractor = new AttractionBehavior(pos, 450, 0.1f);
 // physics.addBehavior(attractor);
 
   // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
}

void addParticle() {
  VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(5).addSelf(width / 2, 0));
  physics.addParticle(p);
  // add a negative attraction force field around the new particle
  physics.addBehavior(new AttractionBehavior(p, 40, -0.6f, 0.01f));
  

}

void draw() {
  fill(0,25);
  rect(0,0,width,height);
  background(0);
  noStroke();
  fill(255);
  t+=0.05;
  
  
 
  //pos.set(noise(t)*width, noise(t+362.1746)*height);
  pos.set(mouseX, mouseY);
 
  
  physics.update();
  for (int i = 0; i < NUM_PARTICLES; i++) {
    VerletParticle2D p = physics.particles.get(i);
    points[i][0]=p.x;
    points[i][1]=p.y;
  }
    
  Delaunay myDelaunay = new Delaunay( points );

  int[][] myLinks = myDelaunay.getLinks();

  for(int i=0; i<myLinks.length; i++){
    int startIndex = myLinks[i][0];
    int endIndex = myLinks[i][1];
    float startX = points[startIndex][0];
    float startY = points[startIndex][1];
    float endX = points[endIndex][0];  
    float endY = points[endIndex][1];

    float d =  dist(startX, startY, endX, endY);
    
   
    stroke(255,255-d*6);    
    strokeWeight(2);  
    line( startX, startY, endX, endY);
    
    
    float rad = 10;
    noStroke();
    float opacity = 255 - d*6;
    if(opacity == 255)
      opacity = 0;
    fill(255,opacity);
    ellipse(startX, startY, rad,rad);
    //text(i,startX+5, startY);
  }
  
  if(frameCount%240==0){
   // moverStart();
  }

  if(frameCount%240==120){
   // moverEnd();
  }
  
 // mover();
  
 // if(frameCount>240*5 && frameCount <240*9){
  //  saveFrame("net_###.png");
 // }
    
    server.sendScreen();
    
    fill(255,255);
    text(frameRate,10,10);
}

void mousePressed() {
  mousePos = new Vec2D(mouseX, mouseY);
  // create a new positive attraction force field around the mouse position (radius=250px)
  mouseAttractor = new AttractionBehavior(mousePos, 450, 0.4f);
  physics.addBehavior(mouseAttractor);

}

void mouseDragged() {
  // update mouse attraction focal point
  mousePos.set(mouseX, mouseY);
}

void mouseReleased() {
  // remove the mouse attraction when button has been released
  physics.removeBehavior(mouseAttractor);
}


void mover(){
  mousePos.set(noise(t)*width, noise(t+123782)*height);
}

void moverStart() {
  mousePos = new Vec2D(noise(t)*width, noise(t+123782)*height);
  // create a new positive attraction force field around the mouse position (radius=250px)
  mouseAttractor = new AttractionBehavior(mousePos, 450, 0.9f);
  physics.addBehavior(mouseAttractor); 
}

void moverEnd() {
 physics.removeBehavior(mouseAttractor); 

}
