import gab.opencv.*;

OpenCV opencv;
PImage img;

PFont font;

void setup() {
  size(320*3, 240);
  font = loadFont("Monospaced-14.vlw");
  textFont(font);
  opencv = new OpenCV(this, width/3, height);
}

void draw() {
    background(0);
    
    noStroke();  
    fill(255);
    rectMode(CENTER);
    pushMatrix();
      translate(width/6, height/2);
      scale((2*frameCount%100)/50.0);  // zoom in
//      scale(2 - ((2*frameCount%100)/50.0));  // zoom out
//      rotate(2*radians(frameCount%(width/3))); // rotate
      rect(0, 0, 150, 150);
    popMatrix();
  //  fill(255);
  //  ellipse(mouseX, mouseY, 50, 50);
    img = get(0, 0, width/3, height);

    
    opencv.loadImage(img);
    opencv.calculateOpticalFlow();

    image(img, 0, 0);
    translate(img.width,0);
    stroke(255,0,0);
    opencv.drawOpticalFlow();
    
    PVector test = getZoomOpticFlow();
   //println("z_vector - (" + test.x + ", " + test.y + ", " + test.z + ")");
  
    int flowScale = 10;
    PVector avgFlow = opencv.getAverageFlow();
    // draw average flow in the center of the flow field
//    stroke(0,0,255);
//    strokeWeight(2);
//    pushMatrix();
//      translate(video.width/2, video.height/2);
//      line(0, 0, avgFlow.x*flowScale,avgFlow.y*flowScale);
//    popMatrix();
        
    for(int i=0; i<3; i++){
      for(int j=0; j<3; j++){
        int x = j*img.width/3;
        int y = i*img.height/3;        
        PVector regionFlow = opencv.getAverageFlowInRegion(x,y,img.width/3,img.height/3);
        // draw region flow values
//        stroke(255);
//        strokeWeight(2);
//        pushMatrix();
//          translate((j+0.5)*video.width/3, (i+0.5)*video.height/3);
//          line(0, 0, 9*regionFlow.x*flowScale, 9*regionFlow.y*flowScale);
//        popMatrix();
        // draw region flow values - avgFlow value
        stroke(0,255,0);
        strokeWeight(2);
        pushMatrix();
          translate((j+0.5)*img.width/3, (i+0.5)*img.height/3);
          line(0, 0, (9*regionFlow.x)*flowScale, (9*regionFlow.y)*flowScale);
        popMatrix();
      }
    }
}


// subtract average flow vector from each 9 grid vector
// cross-product every other exterior 9 grid vector
// sum cross-products yield z direction
PVector getZoomOpticFlow(){
  PVector[][] origin = new PVector[3][3];
  PVector[][] flow = new PVector[3][3];
  PVector sumFlow;
  
  PVector avgFlow = opencv.getAverageFlow();
  
  for(int i=0; i<3; i++){
    for(int j=0; j<3; j++){
      int x = j*img.width/3;
      int y = i*img.height/3;        
      PVector regionFlow = opencv.getAverageFlowInRegion(x,y,img.width/3,img.height/3);
      int flowScale = 10;
      flow[j][i] = new PVector(9*regionFlow.x*flowScale, 9*regionFlow.y*flowScale, 0);
      origin[j][i] = new PVector(x + img.width/6 - img.width/2, y + img.height/6 - img.height/2, 0);
    }
  }
  
  float tl = origin[0][0].dot(flow[0][0]);
  float t =  origin[1][0].dot(flow[1][0]);
  float tr = origin[2][0].dot(flow[2][0]);
  float r =  origin[2][1].dot(flow[2][1]);
  float br = origin[2][2].dot(flow[2][2]);
  float b =  origin[1][2].dot(flow[1][2]);
  float bl = origin[0][2].dot(flow[0][2]);
  float l =  origin[0][1].dot(flow[0][1]);
  
  pushMatrix();
    translate(width/3, 0);
    int lineHeight = 20;
    setColorBasedOnPolarity(tl);
    text("tl - " + int(tl), 10, lineHeight*1);
    setColorBasedOnPolarity(t);
    text("t  - " + int(t), 10, lineHeight*2);
    setColorBasedOnPolarity(tr);
    text("tr - " + int(tr), 10, lineHeight*3);
    setColorBasedOnPolarity(r);
    text("r  - " + int(r), 10, lineHeight*4);
    setColorBasedOnPolarity(br);
    text("br - " + int(br), 10, lineHeight*5);
    setColorBasedOnPolarity(b);
    text("b  - " + int(b), 10, lineHeight*6);
    setColorBasedOnPolarity(bl);
    text("bl - " + int(bl), 10, lineHeight*7);
    setColorBasedOnPolarity(l);
    text("l  - " + int(l), 10, lineHeight*8);
  popMatrix();
  
  sumFlow = new PVector();

  return sumFlow;
}

void setColorBasedOnPolarity(float v){
  if(int(v) > 0)
    fill(0,255,153);
  else if( int(v) < 0)
    fill(255, 153, 0);
  else
    fill(255); 
}
