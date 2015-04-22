import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Capture video;

void setup() {
  size(320*2, 240);
  video = new Capture(this, width/2, height);
  opencv = new OpenCV(this, width/2, height);
  video.start();  
}

void draw() {
  if (video.available()) {
    background(0);
    video.read();
    video.loadPixels();
    
    opencv.loadImage(video);
    opencv.calculateOpticalFlow();

    image(video, 0, 0);
    translate(video.width,0);
    stroke(255,0,0);
    opencv.drawOpticalFlow();
    
    PVector test = getZoomOpticFlow();
    println("z_vector - (" + test.x + ", " + test.y + ", " + test.z + ")");
  
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
        int x = j*video.width/3;
        int y = i*video.height/3;        
        PVector regionFlow = opencv.getAverageFlowInRegion(x,y,video.width/3,video.height/3);
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
          translate((j+0.5)*video.width/3, (i+0.5)*video.height/3);
          line(0, 0, (9*regionFlow.x)*flowScale, (9*regionFlow.y)*flowScale);
        popMatrix();
      }
    }
  }
}


// subtract average flow vector from each 9 grid vector
// cross-product every other exterior 9 grid vector
// sum cross-products yield z direction
PVector getZoomOpticFlow(){
  PVector[][] flow = new PVector[3][3];
  PVector sumFlow;
  
  PVector avgFlow = opencv.getAverageFlow();
  
  for(int i=0; i<3; i++){
    for(int j=0; j<3; j++){
      int x = j*video.width/3;
      int y = i*video.height/3;        
      PVector regionFlow = opencv.getAverageFlowInRegion(x,y,video.width/3,video.height/3);
      int flowScale = 10;
      flow[j][i] = new PVector((9*regionFlow.x-avgFlow.x)*flowScale, (9*regionFlow.y-avgFlow.y)*flowScale, 0);
    }
  }
  
  PVector t = flow[0][0].cross(flow[2][0]);
  PVector r = flow[2][0].cross(flow[2][2]);
  PVector b = flow[2][2].cross(flow[0][2]);
  PVector l = flow[0][2].cross(flow[0][0]);
  PVector tl = flow[0][1].cross(flow[1][0]);
  PVector tr = flow[1][0].cross(flow[2][1]);
  PVector br = flow[2][1].cross(flow[1][2]);
  PVector bl = flow[1][2].cross(flow[0][1]);
  
//  println("t - (" + t.x + ", " + t.y + ", " + t.z + ")");
  
  sumFlow = new PVector();
  sumFlow.add(t);
  sumFlow.add(r);
  sumFlow.add(b);
  sumFlow.add(l);
  sumFlow.add(tl);
  sumFlow.add(tr);
  sumFlow.add(br);
  sumFlow.add(bl);

  return sumFlow;
}
