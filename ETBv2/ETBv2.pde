import controlP5.*; //<>//
import javax.swing.JOptionPane; 
import javax.swing.JDialog;
import javax.swing.JOptionPane.*;
import processing.serial.*;

/*Development Tools*/
final boolean debug = false;
final boolean debug1 = true;
final boolean showCrosshair = false;
boolean noHardware = false;
/*Development Tools*/

ControlP5 cp5;
int myColor = color(0);
int c1, c2;
float n, n1;
JSONObject configJSON;
JSONArray  buttonData;
JSONArray sliderData;
PImage buttonImage, buttonImage1, buttonImage2;
PFont buttonFont;
Slider abc;
float Command = 33;
int chartDataWidth;
float m1FeedBack;
float  m2FeedBack;
float m1Current;
float m2Current;
Chart[] myChart; 
Button[] myButton;
String portName ;
String tempPortName;
Roboteq motor1, motor2;
Analog analog1;
int exitCount = 2;
int exitCounter =0;
float motorTimer=0;
float runDuration = 5000;
color[] myColors= {#EF4F37, #458304};//build an array for pointer colors
Serial myPort;
float defaultCommand=33;
boolean runToPosition=false;
boolean scriptRunning=false;
int numButtons;

void setup() {
  size(1920, 1000);
  noStroke();
  cp5 = new ControlP5(this);
  configJSON = loadJSONObject("Config.json");
  buttonData = configJSON.getJSONArray("buttons");
  loadButtons();
  loadSlider();
  loadScope();
  addTraces();
  analog1 = new Analog(3*width/4, 300, 0, 5, 200, 30, 150, "A");
  analog1.setColors(#1E445B, #EF4F37, #EF4F37, #ED1313, myColors, #FFFFFF);
  String roboPort = getRoboteqPort();
  if (roboPort!=null) {
    myPort= new Serial(this, roboPort, 115200);
    motor1 = new Roboteq(1, myPort);
    motor2 = new Roboteq(2, myPort);
    motor1.init();
  } else {
    exit();
  }
}

void draw() {
  background(255);

  float m1Feedback = motor1.getMotorFeedback();
  //if (debug)println(m1Feedback);
  float m2Feedback = motor2.getMotorFeedback();
  //if (debug)println(m2Feedback);
  float  m1Amps = motor1.getMotorAmps();
  //if (debug)println(m1Amps);
  float  m2Amps = motor2.getMotorAmps();
  //if (debug)println(m2Amps);
  float m1Comm = motor1.getMotorCommand();
  //float m2Comm = motor2.getMotorCommand();

  if (noHardware) {
    m1Feedback = Command-10;
    m2Feedback = Command+10;
    m1Amps = Command-10;
    m2Amps = Command+10;
  }

  //Command = m1Comm;

  int userVal = motor1.getUserVar(8);
  if (userVal==1) {
    scriptRunning=true;
  } else {
    scriptRunning=true;
  }
  println(m1Comm);

  //println(Command);
  if (scriptRunning ) {
    cp5.getController("Command").setValue(m1Comm/10+10);
  }

  myChart[0].push("0", m1Comm);
  myChart[0].push("1", m1Feedback);
  myChart[0].push("2", m2Feedback);
  myChart[1].push("3", m1Comm/10);
  myChart[1].push("4", m1Amps);
  myChart[1].push("5", m2Amps);


  if (debug)if (noHardware && runToPosition)text("Run for " + runDuration + " timer " + (millis()-motorTimer), 50, 60);

  if (runToPosition && runDuration + motorTimer <= millis()) {
    motor1.eStop();
    if (noHardware)println("Stopped");
    runToPosition = false;
    unlockButtons();
    myButton[1].unlock();
    cp5.getController("Command").setValue(33);
  } else if (runToPosition) {
    fill(0); 
    if (noHardware) {
      text("Running...", 50, 50); 
      //println("Running..."); 
      cp5.getController("Command").setValue(Command);
      Command = 25*sin(map(millis()-motorTimer, 0, 50, 0, 1))+55; 
      //myButton[1].lock();
    }
  }
}
void unlockButtons() {
  for (int i=0; i<numButtons; i++) {
    myButton[i].unlock();
  }
}
void lockButtons() {
  for (int i=0; i<numButtons; i++) {
    if (debug)println(myButton[i].isLock());
    if (debug)println(myButton[i].getName());

    if (myButton[i].getStringValue().equals("eStop")) {
      if (debug)println(" not locked");
      myButton[i].unlock();
    } else {
      myButton[i].lock();
      if (debug)println(" locked");
    }
    if (debug)println(myButton[i].isLock());
  }
  cp5.getController("eStop").unlock();
}

void Command(float position) {
  Command = position; 
  if (mousePressed)motor1.go(position);
  if (mousePressed)motor2.go(position);
  //if (debug1)println(position);
}
//public void controlEvent(ControlEvent theEvent) {
//  println(theEvent.getController().getName());
//  switch(theEvent.getController().getName()) {
//  case "turkey":
//    break;
//  }
//}

public void buttonPress(int index, String function, int value) {
  switch (function) {
  case "eStop" : 
    //hs1.setDefaultPos(map(int(defaultCommand), 4, 99, 0, width));
    motor1.eStop(); 
    runToPosition=false;
    if (noHardware)println("eStop"); 
    break; 
  case "exit" : 
    if (debug)println("Secret button pressed "+exitCounter+" times"); 
    if (exitCounter == exitCount) { 
      if (debug)println("Secret button used to exit"); 
      exit();
    } else {
      exitCounter ++;
    }
    break; 
  case "position" : 
    if (noHardware)println("position"); 
    exitCounter =0; 
    //lockButtons();
    //hs1.setDefaultPos(map(int(value), 4, 99, 0, width));
    motor1.Start(); 
    runToPosition = true; 
    motorTimer = millis(); 
    //fff
    break; 
  case "script" : 
    //hs1.setDefaultPos(map(int(defaultCommand), 4, 99, 0, width));
    if (noHardware)println("script"); 
    exitCounter =0; 
    motor1.startScript(value); 
    motor1.Start(); 
    //scriptRunning = true;
    break; 
  default : 
    if (noHardware)println("This Button Has No Valid Function"); 
    motor1.eStop(); 
    break;
  }

  if (debug)println("The "+ index + " button Works" ); 
  if (debug)println(function); 
  if (debug)println(value);
}




void loadButtons() {

  JSONArray  buttonData = configJSON.getJSONArray("buttons"); 
  myButton = new Button[buttonData.size()]; 
  numButtons=buttonData.size();
  for (int i = 0; i < buttonData.size(); i++) {
    JSONObject button = buttonData.getJSONObject(i); 
    JSONObject position = button.getJSONObject("position"); 
    JSONObject border =  button.getJSONObject("border"); 
    JSONObject size =  button.getJSONObject("size"); 
    if (debug)println(position); 
    String bImage = button.getString("buttonImage"); 
    buttonImage = loadImage(bImage); 
    String bImage1 = button.getString("buttonImageActive"); 
    buttonImage1 = loadImage(bImage1); 
    String bImage2 = button.getString("buttonImageClicked"); 
    buttonImage2 = loadImage(bImage2); 
    String bFont = button.getString("font"); 
    //int fontSize = button.getInt("fontsize");

    buttonFont = loadFont(bFont); 


    //color textColor = unhex("FF" +button.getString("textColor").substring(1));
    stroke(unhex("FF" + border.getString("color").substring(1))); 
    strokeWeight(border.getInt("thickness")); 
    myButton[i] = cp5.addButton(button.getString("label"))
      .setValue(float(button.getString("tag")))
      .setId(button.getInt("index"))
      .setPosition(position.getInt("x"), position.getInt("y"))
      .setImages(buttonImage, buttonImage1, buttonImage2)
      .setSize(size.getInt("width"), size.getInt("height"))
      .setFont(buttonFont)
      .setLabelVisible(true)//will need to be false if image i think
      .setStringValue(button.getString("function"))
      .setColorActive(unhex("FF" + button.getString("activeColor").substring(1))) 
      .setColorBackground(unhex("FF" + button.getString("buttonColor").substring(1)))
      .setColorCaptionLabel(unhex("FF" + button.getString("textColor").substring(1)))
      .setColorForeground(unhex("FF" + button.getString("hoverColor").substring(1)))

      .onRelease(new CallbackListener() {
      public void controlEvent(CallbackEvent ev) {
        buttonPress(ev.getController().getId(), ev.getController().getStringValue(), int(ev.getController().getValue()));
      }
    }
    );
  }
}
void loadSlider() {
  JSONArray  sliderData = configJSON.getJSONArray("sliders"); 

  for (int i = 0; i < sliderData.size(); i++) {
    JSONObject slider = sliderData.getJSONObject(i); 
    JSONObject position = slider.getJSONObject("position"); 
    JSONObject range = slider.getJSONObject("range"); 
    JSONObject size =  slider.getJSONObject("size"); 

    cp5.addSlider(slider.getString("label"))
      .setPosition(position.getInt("x"), position.getInt("y"))
      .setRange(range.getInt("min"), range.getInt("max")) // values can range from big to small as well
      .setSize(size.getInt("width"), size.getInt("height"))
      .setNumberOfTickMarks(17)
      .showTickMarks(true)
      .setSliderMode(Slider.FLEXIBLE)
      .setColorTickMark(0)
      .setValue(33)
      .setDefaultValue(33)
      .snapToTickMarks(false)
      .setImage(loadImage("bar.jpg"))
      .setHandleSize(75)
      .setColorLabel(75)
      .setColorBackground(#C6C6C6)
      .setColorForeground(#E8E8E8)
      .setColorActive(#D8D8D8)
      ; 
    //cp5.getController("Command").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    cp5.getController("Command").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
    
  }
}
void loadScope() {
  JSONArray  chartData = configJSON.getJSONArray("charts"); 
  myChart = new Chart[chartData.size()]; 
  for (int i = 0; i < chartData.size(); i++) {
    JSONObject chart = chartData.getJSONObject(i); 
    JSONObject position = chart.getJSONObject("position"); 
    JSONObject range = chart.getJSONObject("range"); 
    JSONObject size =  chart.getJSONObject("size"); 

    myChart[i] = cp5.addChart(chart.getString("label"))
      .setPosition(position.getInt("x"), position.getInt("y"))
      .setSize(size.getInt("width"), size.getInt("height"))
      .setRange(range.getInt("min"), range.getInt("max"))
      .setStrokeWeight(chart.getInt("strokeweight"))
      .setColorCaptionLabel(color(chart.getInt("ColorCaptionLabel")))
      .setColorBackground(#C6C6C6) 
      .setColorForeground(#E8E8E8)
      .setColorActive(#D8D8D8)
      ; 
    if (debug)println(chart.getString("type")); 
    switch(chart.getString("type")) {
    case "LINE" : 
      myChart[i].setView(Chart.LINE); 
      break; 
    case "PIE" : 
      myChart[i].setView(Chart.PIE); 
      break; 
    case"AREA" : 
      myChart[i].setView(Chart.AREA); 
      break; 
    case "BAR" : 
      myChart[i].setView(Chart.BAR_CENTERED); 
      break;
    }
  }
}
void addTraces() {
  if (debug)println("addingTraces"); 
  JSONArray  traceData = configJSON.getJSONArray("traces"); 
  for (int i = 0; i < traceData.size(); i++) {
    JSONObject trace = traceData.getJSONObject(i); 
    color traceColor = unhex("FF" + trace.getString("color").substring(1)); 

    myChart[trace.getInt("chart")].addDataSet(str(trace.getInt("id"))); 
    myChart[trace.getInt("chart")].setColors(str(trace.getInt("id")), traceColor); 
    myChart[trace.getInt("chart")].setData(str(trace.getInt("id")), new float[trace.getInt("dataWidth")]); 
    if (debug)println("trace on Chart " + trace.getInt("chart") + " Named "+ trace.getString("label")+ " with ID " + trace.getInt("id"));
  }
}


String getRoboteqPort() {
  //boolean debug = true;
  boolean debug = false; 

  JDialog dialog = new JDialog(); 
  dialog.setAlwaysOnTop(true); 
  try {
    if (debug) printArray(Serial.list()); //print the list of ports
    int i = Serial.list().length; //determine length of list
    if (i != 0) { //more than none 
      if (i >= 1) {// more than one port
        for (int j = 0; j < i; j++) {//itterate through list of ports
          try {
            Serial tempPort; 
            tempPortName = Serial.list()[j]; 
            tempPort= new Serial(this, tempPortName, 115200); // change baud rate to your liking
            tempPort.clear(); 
            tempPort.write("?TRN"+ '\r'); 
            delay(1200); 
            String serString = tempPort.readStringUntil('\r'); 
            if (noHardware)serString = "TRN=XXXX"; 
            if (debug) println("Checking " + tempPortName); 
            //Check response
            serString = serString.substring(0, 3); 
            serString = serString.toLowerCase(); 
            if (debug) println (serString); 
            if (serString.equals("trn")) {
              if (debug) println("Found It!"); 
              portName=tempPortName;
            }
            tempPort.clear(); 
            tempPort.stop();
          }
          catch (Exception e) {
            if (debug)println(tempPortName + " is busy");
          }
        }
      }
    } else {
      JOptionPane.showMessageDialog(frame, "Device is not connected to the PC"); 
      exit();
    }
  }
  catch (Exception e)
  { //Print the type of error
    println("Error:", e); 
    exit();
  }
  if (portName !=null) {
    return portName;
  } else {
    JOptionPane.showMessageDialog(frame, "The Roboteq is not connected to the PC or COM port is not available (may\nbe in use by another program)"); 
    exit(); 
    return null;
  }
}