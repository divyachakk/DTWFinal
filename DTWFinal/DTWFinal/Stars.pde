/**
 * Divya Chakkaram
 * Dec 3, 2020
 * This class is created to display stars all over the screen of 
 * random size and placement. 
**/

class Stars {
  color c;
  float xpos;
  float ypos;
  float starSize;

  Stars() {
    c = 255;
    xpos = random(0, width);
    ypos = random(0, height);
    starSize = random(0,3);
  }
  
  void displayStars(){
    noStroke();
    fill(c, 75);
    ellipse(xpos,ypos, starSize, starSize);
  }
}
