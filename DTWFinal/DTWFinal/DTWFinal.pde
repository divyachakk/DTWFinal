/**
 * Divya Chakkaram
 * Dec 3, 2020
 * Final Project for CRCP 3300 - Uses processing and Wekinator software to manipulate Dynamic Time Warping 
 in order to display constellations on a starry night. Run and train wekinator with 2 inputs, the mousex and 
 mousey, as well as one Dynamic Time Warping model with 6 gestures for 6 constellations.
 
 * uses wek file "finalconstellationDTW"
 * http://www.wekinator.org/examples/ - DTW Mouse Explorer
 **/

int nStars = 2000; //set int nStars to number of stars to display
Stars[] allStars = new Stars[nStars]; //create Array of nStars
 

//import various libraries necessary for Wekinator and DTW
import controlP5.*; //library to help build toggles, buttons, etc in a Processing sketch
import oscP5.*; //library to aid communication between computers, sound synthesizers, and other multimedia devices (in this case Wekinator)
import netP5.*; //library to contain inetaddress of remote internet address, made up of an IP address and a port number (used to connect with Wekinator)

OscP5 oscP5;
NetAddress dest;
ControlP5 cp5;

PFont f, f2; //initializing two different fonts 
boolean isRecording = true; //creating and initializing boolean isRecording, set to true
boolean isRecordingNow = true; //creating and initializing boolean isRecordingNow, set to true

//create and initialize 6 different boolean variables for each constellation to display, set to false initially
boolean bigDip = false; 
boolean cassiopeia = false;
boolean cepheus = false;
boolean hercules = false;
boolean aries = false;
boolean phoenix = false;

//setting and creating int variables for drawing area and running/training area
int areaTopX = 219;
int areaTopY = 117;
int areaWidth = 703;
int areaHeight = 650;

int currentClass = 1; //creating and initializing int currentClass to -1

int alpha = 0;
String[] messageNames = {"/output_1", "/output_2", "/output_3", "/output_4", "/output_5", "/output_6" }; //message names for each DTW gesture type, based on what has been trained on Wekinator
int receivedClass = 1;


void setup() { //modified from Wekinator DTW mouse explorer code
  size(1000, 800, P2D);
  noStroke();

  oscP5 = new OscP5(this, 12000); //using oscP5, display output to port 12000
  dest = new NetAddress("127.0.0.1", 6448); //start listening to the netaddress, on port 6448

  f = createFont("Courier", 18); //creating fonts based on what DTW example provided
  textFont(f);
  f2 = createFont("Courier", 44);
  textAlign(LEFT, TOP);

  createControls(); //call method createControls()
  sendNames(); //call method sendNames()

  for (int i = 0; i < nStars; i++) { //creating new object Star for each star in array allStars 
    allStars[i] = new Stars(); 
  }

}

void sendNames() { //used from Wekinator DTW mouse explorer code
  OscMessage msg = new OscMessage("/wekinator/control/setInputNames");
  msg.add("mouseX"); 
  msg.add("mouseY");
  oscP5.send(msg, dest);
}

void createControls() { //modified and used from DTW Mouse Explorer
  cp5 = new ControlP5(this);
  cp5.addToggle("isRecording")
    .setPosition(10, 20)
    .setSize(75, 20)
    .setValue(true)
    .setCaptionLabel("record/run")
    .setMode(ControlP5.SWITCH)
    ;
}

void drawText() { //drawing text displayed on run and training screens
  fill(255);
  textFont(f);
  if (isRecording) { //if the boolean isRecording is true, display all the text below
    text("Run Wekinator with 2 inputs (mouse x,y), 1 DTW output", 150, 28);
    text("Click and drag to record constellation #" + currentClass + " (press number to change)", 150, 53);
    fill(#FAFAAE);
    text("draw a P to display the Big Dipper!", 400, 100);
    text("draw a W to display cassiopeia!", 300, 200);
    text("draw a triangle to display cepheus!", 200, 300);
    text("draw a square to display hercules!", 250, 400);
    text("draw a vertical line to display aries!", 350, 500);
    text("draw a sin wave to display phoenix!", 450, 600);
  } else { //else if isRecording isn't true, display text below
    text("Click and drag to draw constellations!", 150, 28);
  } 

}

void draw() {
  background(0);
  smooth();
  drawText(); //call method drawText

  drawChild(); //call method drawChild
  drawTelescope(); //call method drawTelescope

  for (int i = 0; i< nStars; i++) { //for loop to display array of stars
    allStars[i].displayStars();
  }

//in order to display each of the constellations based on Wekinator DTW matches, if global boolean variables are true, display corresponding constellation method
  if (bigDip) {
    bigDipper();
  }

  if (cassiopeia) {
    cassiopeia();
  }

  if (cepheus) {
    cepheus();
  }

  if (hercules) {
    hercules();
  }

  if (aries) {
    aries();
  }

  if (phoenix) {
    phoenix();
  }

  if (mousePressed) {
    noStroke();
    fill(255, 0, 0);
    ellipse(mouseX, mouseY, 10, 10);
  }

  if (mousePressed && frameCount % 2 == 0) {
    sendOsc(); 
  }

  alpha -= 10;
}

boolean inBounds(int x, int y) { //modified from Wekinator DTW mouse explorer code - this method is used to keep mouse tracking within certain boundaries
  if (x < areaTopX || y < areaTopY) {
    return false;
  }
  if (x > areaTopX + areaWidth || y > areaTopY + areaHeight) {
    return false;
  } 
  return true;
}

void mousePressed() { //modified and used from Wekinator DTW Mouse Explorer code
  if (! inBounds(mouseX, mouseY)) {
    return;
  }
  if (isRecording) { //if boolean isRecording = true, do all below with mousePressed
    isRecordingNow = true;
    OscMessage msg = new OscMessage("/wekinator/control/startDtwRecording");
    msg.add(currentClass); //adding the current trained mouse shaping
    oscP5.send(msg, dest);
  } else { //otherwise if isRecording isn't = true
    OscMessage msg = new OscMessage("/wekinator/control/startRunning");
    oscP5.send(msg, dest);
  }
}

void mouseReleased() { //used from Wekinator DTW mouse explorer code - when the mouse is being released, recording of training for shapes is stopped 
  if (isRecordingNow) { //if boolean isRecordingNow = true
    isRecordingNow = false; //after mouse has been released, set isRecordingNow = false
    OscMessage msg = new OscMessage("/wekinator/control/stopDtwRecording");
    oscP5.send(msg, dest);
  }
}



void keyPressed() { //modified from Wekinator DTW mouse explorer code
  int keyIndex = -1;
  if (key >= '1' && key <= '7') {
    currentClass = key - '1' + 1;
  }
}

void sendOsc() { //used from Wekinator DTW mouse explorer code
  OscMessage msg = new OscMessage("/wek/inputs");
  msg.add((float)mouseX); 
  msg.add((float)mouseY);
  oscP5.send(msg, dest);
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) { //modified from Wekinator DTW mouse explorer code
  
  if (theOscMessage.checkAddrPattern(messageNames[0]) == true) { //if first mouse explorer trained shape is recognized...
    bigDip = true; //set boolean bigDip to true, and display the constellation big dipper
    cassiopeia = false; //set all the other constellation booleans to false, in order to only display one constellation at a time.
    cepheus = false;
    hercules = false;
    aries = false;
    phoenix = false;
  } 

  if (theOscMessage.checkAddrPattern(messageNames[1]) == true) { //if second mouse explorer trained shape is recognized...
    cassiopeia = true; //set boolean cassiopeia to true, and display the constellation cassiopeia
    bigDip = false; //set all the other constellation booleans to false, in order to only display one constellation at a time.
    cepheus = false;
    hercules = false;
    aries = false;
    phoenix = false;
  }

  if (theOscMessage.checkAddrPattern(messageNames[2]) == true) { //if third mouse explorer trained shape is recognized...
    cepheus = true; //set boolean cepheus to true, and display the constellation cepheus
    cassiopeia = false; //set all the other constellation booleans to false, in order to only display one constellation at a time.
    bigDip = false;
    hercules = false;
    aries = false;
    phoenix = false;
  }

  if (theOscMessage.checkAddrPattern(messageNames[3]) == true) { //if fourth mouse explorer trained shape is recognized...
    hercules = true; //set boolean hercules to true, and display the constellation hercules
    cepheus = false; //set all the other constellation booleans to false, in order to only display one constellation at a time.
    cassiopeia = false;
    bigDip = false;
    aries = false;
    phoenix = false;
  }

  if (theOscMessage.checkAddrPattern(messageNames[4]) == true) { //if fifth mouse explorer trained shape is recognized...
    aries = true; //set boolean aries to true, and display the constellation aries
    hercules = false; //set all the other constellation booleans to false, in order to only display one constellation at a time.
    cepheus = false;
    cassiopeia = false;
    bigDip = false;
    phoenix = false;
  }
  if (theOscMessage.checkAddrPattern(messageNames[5]) == true) { //if sixth mouse explorer trained shape is recognized...
    phoenix = true; //set boolean phoenix to true, and display the constellation phoenix
    aries = false; //set all the other constellation booleans to false, in order to only display one constellation at a time.
    hercules = false;
    cepheus = false;
    cassiopeia = false;
    bigDip = false;
  }
}

void drawChild() { //method to display little person looking up at the starry night and the constellations
  noStroke();
  fill(209, 187, 114, 255);
  circle(400, 752, 80);
  fill(209, 187, 114, 240);
  rect(385, 790, 30, 90);
  quad (450, 750, 480, 750, 420, 900, 400, 900);
  arc(425, 726, 20, 20, 0, TWO_PI);
  noFill();
  stroke(0); 
  strokeWeight(2);
  curve(390, 723, 400, 725, 410, 715, 420, 705);
}

void drawTelescope() { //method to display the telescope used to observe and look up at the starry night and the constellations
  noStroke();
  fill(192, 192, 191);
  quad(450, 720, 475, 710, 485, 730, 450, 740);
  quad(470, 705, 510, 690, 525, 715, 485, 730);
  quad(500, 690, 610, 630, 635, 670, 520, 725);
}

void bigDipper() { //method to draw and display the Big Dipper constellation
  noStroke();
  fill(#FAFAAE);
  ellipse(100, 120, 5, 5);
  ellipse(187, 135, 5, 5);
  ellipse(230, 175, 5, 5);
  ellipse(295, 220, 5, 5);
  ellipse(290, 285, 5, 5);
  ellipse(405, 325, 5, 5);
  ellipse(445, 260, 5, 5);
  stroke(#FAFAAE);
  strokeWeight(0.5);
  line(100, 120, 187, 135);
  line(187, 135, 230, 175);
  line(230, 175, 295, 220);
  line(295, 220, 290, 285);
  line(290, 285, 405, 325);
  line(405, 325, 445, 260);
  line(445, 260, 295, 220);
}

void cassiopeia() { //method to draw and display the Cassiopeia constellation
  noStroke();
  fill(#FAFAAE);
  ellipse(295, 120, 5, 5);
  ellipse(360, 155, 5, 5);
  ellipse(410, 120, 5, 5);
  ellipse(460, 170, 5, 5);
  ellipse(510, 100, 5, 5);
  stroke(#FAFAAE);
  strokeWeight(0.5);
  line(295, 120, 360, 155);
  line(360, 155, 410, 120);
  line(410, 120, 460, 170);
  line(460, 170, 510, 100);
}

void cepheus() { //method to draw and display the Cepheus constellation
  noStroke();
  fill(#FAFAAE);
  ellipse(80, 180, 5, 5);
  ellipse(70, 295, 5, 5);
  ellipse(165, 255, 5, 5);
  ellipse(125, 380, 5, 5);
  ellipse(200, 340, 5, 5);
  stroke(#FAFAAE);
  strokeWeight(0.5);
  line(80, 180, 70, 295);
  line(70, 295, 165, 255);
  line(165, 255, 80, 180);
  line(70, 295, 125, 380);
  line(125, 380, 200, 340);
  line(200, 340, 165, 255);
}

void hercules() { //method to draw and display the Hercules constellation
  noStroke();
  fill(#FAFAAE);
  ellipse(650, 120, 5, 5);
  ellipse(610, 200, 5, 5);
  ellipse(695, 197, 5, 5);
  ellipse(730, 270, 5, 5);
  ellipse(695, 340, 5, 5);
  ellipse(660, 332, 5, 5);
  ellipse(630, 322, 5, 5);
  ellipse(607, 305, 5, 5);
  ellipse(590, 310, 5, 5); //end of leg 2
  ellipse(785, 260, 5, 5);
  ellipse(820, 365, 5, 5);
  ellipse(710, 435, 5, 5); //end of leg 3
  ellipse(780, 170, 5, 5);
  ellipse(795, 130, 5, 5);
  ellipse(810, 95, 5, 5);
  ellipse(860, 120, 5, 5);
  stroke(#FAFAAE);
  strokeWeight(0.5);
  line(650, 120, 610, 200);
  line(610, 200, 695, 197);
  line(695, 197, 730, 270);
  line(730, 270, 695, 340);
  line(695, 340, 660, 332);
  line(660, 332, 630, 322);
  line(630, 322, 607, 305);
  line(607, 305, 590, 310);
  line(730, 270, 785, 260);
  line(785, 260, 820, 365);
  line(820, 365, 710, 435);
  line(785, 260, 780, 170);
  line(780, 170, 795, 130);
  line(795, 130, 810, 95);
  line(810, 95, 860, 120);
  line(780, 170, 695, 197);
}

void aries() { //method to draw and display the Aries constellation
  noStroke();
  fill(#FAFAAE);
  ellipse(900, 200, 5, 5);
  ellipse(920, 220, 5, 5);
  ellipse(915, 275, 5, 5);
  ellipse(865, 385, 5, 5);
  stroke(#FAFAAE);
  strokeWeight(0.5);
  line(900, 200, 920, 220);
  line(920, 220, 915, 275);
  line(915, 275, 865, 385);
}

void phoenix() { //method to draw and display the Phoenix constellation
  noStroke();
  fill(#FAFAAE);
  ellipse(350, 400, 5, 5);
  ellipse(380, 415, 5, 5);
  ellipse(380, 360, 5, 5);
  ellipse(410, 380, 5, 5);
  ellipse(418, 387, 5, 5);
  ellipse(450, 360, 5, 5);
  ellipse(482, 383, 5, 5);
  ellipse(525, 360, 5, 5);
  ellipse(520, 400, 5, 5);
  ellipse(517, 430, 5, 5);
  ellipse(465, 495, 5, 5);
  ellipse(420, 480, 5, 5);
  stroke(#FAFAAE);
  strokeWeight(0.5);
  line(350, 400, 380, 415);
  line(380, 415, 380, 360);
  line(380, 360, 410, 380);
  line(410, 380, 418, 387);
  line(418, 387, 450, 360);
  line(450, 360, 482, 383);
  line(482, 383, 525, 360);
  line(525, 360, 520, 400);
  line(520, 400, 517, 430);
  line(465, 495, 420, 480);
  line(465, 495, 482, 383);
  line(420, 480, 418, 387);
}
