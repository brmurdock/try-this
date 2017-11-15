
//make text size scale with size
/***************************************************************************/

class Analog {
  float xPos, yPos;       // x and y position of bar
  float[] curVal = {0};
  // Set the font and its size (in units of pixels)
  PFont dialFont = loadFont("ArialMT-25.vlw");
  PFont digitallFont = loadFont("ArialMT-25.vlw");
  float dialFontSize = 15;
  float digitalFontSize = 15;
  float centerX;
  float centerY;
  float minVal;
  float maxVal;
  color dialColor = 80;
  color textColor = 255;
  color smallTickColor = 255;
  color largeTickColor = 255;
  color[] pointerColor = {255};
  color dialTextColor = 255;
  float dialSize = 160;
  int startDegree = 120;
  int endDegree = 420;
  //dial text interval
  boolean doubleLine = false;
  String units = "";
  float digitCount = 5;


  Analog(float xPos, float yPos, float minV, float maxV, float size, int startPos, int endPos, String dispUnits) {
    centerX = xPos;
    centerY = dialSize/2 + yPos-30;
    minVal = minV;
    maxVal = maxV;
    dialSize = size;
    startDegree = startPos-180;
    endDegree = endPos-180;
    units = dispUnits;
  }

  void display() {
    //draw dial background
    textAlign(LEFT, BASELINE);
    fill(dialColor);

    stroke(0);
    strokeWeight(1);
    fill(255);
    arc(centerX, centerY, 1.5*dialSize, 1.5*dialSize, radians(startDegree-10), radians(endDegree+10), PIE ); 
    noStroke();
    fill(dialColor);
    arc(centerX, centerY, 1.5*dialSize*.95, 1.5*dialSize*.95, radians(startDegree-10), radians(endDegree+10), PIE ); 
    fill(255);
    arc(centerX, centerY, 1.5*dialSize*.70, 1.5*dialSize*.70, radians(startDegree-10), radians(endDegree+10), PIE ); 
    fill(dialColor);
    arc(centerX, centerY, 1.5*dialSize*.21875, 1.5*dialSize*.21875, radians(startDegree-10), radians(endDegree+10), PIE ); 
    fill(255);
    arc(centerX, centerY, 1.5*dialSize*.20625, 1.5*dialSize*.20625, radians(startDegree-10), radians(endDegree+10), PIE ); 


    //ellipse(centerX, centerY, dialSize, dialSize);


    //draw digital display
    stroke(128);
    strokeWeight(1);
    rect(centerX-55, centerY+5, 110, 20, 7);
    fill(textColor);
    textFont(digitallFont, digitalFontSize);
    for (int i =0; i<curVal.length; i++) {
      String curNum = nfc(curVal[i], 2);
      text( curNum + units, centerX-45 + 50 *i, centerY+20);
    }
    strokeWeight(2);



    // dial text
    float numDeg= endDegree - startDegree;
    float interval = numDeg/digitCount;
    for (int a = startDegree; a <= endDegree; a+=interval) {
      float x = centerX + (dialSize *.6) * ( cos(radians(a)));
      float y = centerY + 3 + (dialSize *.6) * ( sin(radians(a)));
      textFont(dialFont, dialFontSize);
      fill(dialTextColor);
      text((ceil(map(a, startDegree, endDegree, minVal, maxVal))), x - 10, y);
    }

    //Small Ticks
    for (int a = startDegree; a <= endDegree; a+=(interval/2)) {
      float x = centerX + (dialSize *.45) * ( cos(radians(a)));
      float y = centerY + (dialSize *.45) * ( sin(radians(a)));
      stroke(smallTickColor);
      point(x, y);
    }

    // Large Ticks

    for (int a = startDegree; a <= endDegree; a+=interval) {
      float x = centerX + (dialSize *.45) * ( cos(radians(a)));
      float y = centerY + (dialSize *.45) * ( sin(radians(a)));
      strokeWeight(5);
      stroke(largeTickColor);
      point(x, y);
    }

    //draw pointers

    for (int i =0; i<curVal.length; i++) {
      float s = map(curVal[i], minVal, maxVal, startDegree, endDegree);//- radians(90);
      float endX = cos(radians(s)) * dialSize/2.1 + centerX;
      float endY = sin(radians(s)) * dialSize/2.1 + centerY;
      strokeWeight(3);
      stroke(pointerColor[i]);
      line(centerX, centerY, endX, endY);
      if (doubleLine) {
        endX = cos(radians(s-180)) * dialSize/2.1 + centerX;
        endY = sin(radians(s-180)) * dialSize/2.1 + centerY;
        line(centerX, centerY, endX, endY);
      }
      fill(255);
      //println("Analog Current Val " + curVal[i]);
    }
  }


  void update(int channelNum, float cVal) {
    //println(channelNum);
    //println(curVal.length);
    cVal = constrain(cVal, minVal, maxVal); 

    if (channelNum +1 > curVal.length) {
      curVal = append(curVal, cVal);
    } else {
      curVal[channelNum] = cVal;
    }
  }

  void addDoubleLine() {
    doubleLine = true;
  }


  //void dialText(float minVal, float  maxVal, color myColor){
  //  int myValue;
  //  stroke(pointerColor);
  // }


  void setColors(color dColor, color tColor, color sTickColor, color lTickColor, color[] pColor, color dTColor) {
    dialColor = dColor;
    textColor = tColor;
    smallTickColor = sTickColor;
    largeTickColor = lTickColor;
    pointerColor = pColor;
    dialTextColor = dTColor;
  }
}