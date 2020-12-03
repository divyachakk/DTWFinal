/**
 * Divya Chakkaram
 * Dec 3, 2020
 * This class is created to display stars all over the screen of 
 * random size and placement. 
**/

class Stars {
  color c; //initializing color variable
  float xpos; //initializing xpos variable
  float ypos; //initializing ypos variable
  float starSize; //initializing starSize variable

  Stars() { //Stars default constructor
    c = 255; //setting the color of the stars
    xpos = random(0, width); //randomizing the xpos of stars from 0 to the width of the screen
    ypos = random(0, height); //randomizing ypos of stars from 0 to the height of the screen
    starSize = random(0,3); //randomizing starSize (width and height) from values of 0 to 3
  }
  
  void displayStars(){ //method to display the stars
    noStroke(); 
    fill(c, 75); //filling the stars with an alpha value for transparancy
    ellipse(xpos,ypos, starSize, starSize); //star shape is an ellipse
  }
}
