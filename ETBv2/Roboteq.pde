class Roboteq {
  //default motorNumber to 1
  int motorNum =1;
  //setup 4 analog channels
  int anaFeedbackM1 = 1;
  int anaCommandM1 = 3;
  int anaFeedbackM2 = 2;
  int anaCommandM2 = 4;
  boolean isRunning=false;


  //bring serial port over
  Serial mySerial;

  Roboteq(int mNum, Serial PortName) {
    motorNum = mNum;
    mySerial = PortName;
    //println(mySerial);
  }

  void init() {
    //disable serial echo
    mySerial.write("^ECHOF 1" + '\r');
    //set serial timeout
    mySerial.write("^RWD 0"  + '\r');
    //set Emergency Stop off
    //mySerial.write("!MG" + '\r');
    for (int i=0; i==8; i++) {
      writeUserVar(i, 0);
    }
  } 

  void Start() {
    //set Emergency Stop off
    mySerial.write("!MG" + '\r');
  }

  public float getMotorAmps() {
    float motorAmps=-1;
    String serString = "nothing";
    String comMessage = "?A " + motorNum + '\r'; 
    mySerial.write(comMessage);
    serString = mySerial.readStringUntil(61); // recieve the resopnse from the Roboteq
    serString = mySerial.readStringUntil('\r'); // recieve the resopnse from the Roboteq
    if (serString != null) {
      serString = trim(serString);
      motorAmps = float(serString);
      motorAmps = motorAmps /2;
      //println("Motor "+ motorNum + " Current: " + motorAmps);
    }

    return motorAmps;
  } //end getMotorAmps

  public float getBatteryVolts() {
    float batteryVolts=-1;
    String serString = "nothing";
    mySerial.write("?V 2" + '\r');
    serString = mySerial.readStringUntil(61); // recieve the resopnse from the Roboteq
    serString = mySerial.readStringUntil('\r'); // recieve the resopnse from the Roboteq
    if (serString != null) { 
      serString = trim(serString);
      batteryVolts = float(serString);
      batteryVolts = batteryVolts / 10;
      //println("Battery Volts: " + batteryVolts);
    }
    return batteryVolts;
  } //end getMotorAmps

  public float getMotorFeedback() {
    float motorFeedback =-1;
    String serString = "nothing";
    mySerial.write("?F "+ motorNum + '\r');
    serString = mySerial.readStringUntil(61); // recieve the resopnse from the Roboteq
    serString = mySerial.readStringUntil('\r'); // recieve the resopnse from the Roboteq
    if (serString != null) { 
      serString = trim(serString);
      motorFeedback = float(serString);
      //println("Motor " + motorNum +" Feedback: "+ motorFeedback);
      //println("Motor " + motorNum +" Feedback: "+ motorFeedback);
    } 
    return motorFeedback;
  } //end getMotorfeedback

  public float getMotorCommand() {
    float motorCommand =-1;
    String serString = "nothing";
    mySerial.write("?M " + motorNum +'\r');
    serString = mySerial.readStringUntil(61); // recieve the resopnse from the Roboteq
    serString = mySerial.readStringUntil('\r'); // recieve the resopnse from the Roboteq
    if (serString != null) { 
      serString = trim(serString);
      motorCommand = float(serString);
      //println("Motor " + motorNum + " Command: " + motorCommand);
    }
    return motorCommand;
  } //end getMotorfeedback

  public float getMotorSpeed() {
    float motorSpeed=-1;
    String serString = "nothing";
    mySerial.write("?BS " + motorNum + '\r');
    serString = mySerial.readStringUntil(61); // recieve the resopnse from the Roboteq
    serString = mySerial.readStringUntil('\r'); // recieve the resopnse from the Roboteq
    if (serString != null) { 
      serString = trim(serString);
      motorSpeed = float(serString);
      //println("Motor Speed: " + motorSpeed);
    }
    return motorSpeed;
  } //end getMotorSpeed



  void go(float myValue) {
    mySerial.write("!G "+ motorNum +" " + myValue +'\r');
  }
  void eStop() {
    mySerial.write("!R 0" + '\r');
    writeUserVar(8, 0);
    myPort.write("!EX" + '\r');
  }



  int getUserVar(int Var) {
    String serString = "nothing";
    int VarVal = -1;
    mySerial.write("?VAR "+ Var +'\r');
    serString = mySerial.readStringUntil(61); // recieve the resopnse from the Roboteq
    serString = mySerial.readStringUntil('\r'); // recieve the resopnse from the Roboteq
    if (serString != null) { 
      serString = trim(serString);
      VarVal = int(serString);
      //println("User Val "+ Var + ": " + VarVal);
    }

    return VarVal;
  }
  void writeUserVar(int varNUM, int varValue) {
    mySerial.write("!VAR "+varNUM +" " + varValue + '\r');
  }

  void startScript(int scriptNum) {
    if (noHardware)println("Running Script number "+scriptNum);
    writeUserVar(3, scriptNum);
    delay(100);
    Start();
    mySerial.write("!R 2" + '\r');
  }
  
} //end class





/**
 
 
 Runtime Queries start with ?
 ***Start ocommann page 228
 A Channel Read Motor Amps
 AI InputNbr Read Analog Inputs
 AIC InputNbr Read Analog Input after Conversion
 ANG Channel Read Rotor Angle
 ASI Channel Read Raw Sin/Cos sensor
 B VarNbr Read User Boolean Variable
 BA Channel Read Battery Amps
 BCR Channel Read Brushless Count Relative
 BS Channel Read BL Motor Speed in RPM
 BSR Channel Read BL Motor Speed as 1/1000 of Max RPM
 C Channel Read Encoder Counter Absolute
 CAN Element Read Raw CAN frame
 CB Channel Read Absolute Brushless Counter
 CF None Read Raw CAN Received Frames Count
 CIA Channel Read Converted Analog Command
 CIP Channel Read Internal Pulse Command
 CIS Channel Read Internal Serial Command
 CL Group Read RoboCAN Alive Nodes Map
 CR Channel Read Encoder Count Relative
 D None Read Digital Inputs
 DI InputNbr Read Individual Digital Inputs
 DO None Read Digital Output Status
 DR Channel Read Destination Reached
 E Channel Read Closed Loop Error
 F Channel Read Feedback
 FC Channel Read FOC Angle Adjust
 FF None Read Fault Flags
 FID None Read Firmware ID
 FM Channel Read Runtime Status Flag
 FS None Read Status Flags
 HS Channel Read Hall Sensor States
 ICL NodeId Is RoboCAN Node Alive
 K Channel Read Spektrum Receiver
 LK None Read Lock status
 M Channel Read Motor Command Applied
 MA AmpsChannel Read Field Oriented Control Motor Amps
 MGD [SensorNumber] Read Magsensor Track Detect
 MGM [SensorNumber] Read Magsensor Markers
 MGS [SensorNumber] Read Magsensor Status
 MGT [Channel] Read Magsensor Track Position
 MGY [Channel] Read Magsensor Gyroscope
 P Channel Read Motor Power Output Applied
 PI InputNbr Read Pulse Inputs
 PIC InputNbr Read Pulse Input after Conversion
 S Channel Read Encoder Motor Speed in RPM
 SCC None Read Script Checksum
 SR Channel Read Encoder Speed Relative
 T SensorNbr Read Temperature
 TM [Element] Read Time
 TR [Channel] Read Position Relative Tracking
 TRN None Read Control Unit type and Controller Model
 UID Element Read MCU Id
 V SensorNumber Read Volts
 VAR VarNumber Read User Integer Variable
 
 
 Runtime Commands begin with !
 ***start on page 210
 AC Channel Acceleration Set Acceleration
 AX Channel Acceleration Next Acceleration
 B VarNbr Value Set User Boolean Variable
 BND [Channel] Mutli-purpose Bind
 C Channel Value Set Encoder Counters
 CB Channel Value Set Brushless Counter
 CG Channel Value Set Motor Command via CAN
 CS Element Value CAN Send
 D0 OutputNbr Reset Individual Digital Out bits
 D1 OutputNbr Set Individual Digital Out bits
 DC Channel Deceleration Set Deceleration
 DS Value Set all Digital Out bits
 DX Channel Value Next Decceleration
 EES None Save Configuration in EEPROM
 EX None Emergency Shutdown
 G Channel Value Go to Speed or to Relative Position
 H Channel Load Home counter
 MG None Emergency Stop Release
 MS Channel Stop in all modes
 P Channel Destination Go to Absolute Desired Position
 PR Channel Delta Go to Relative Desired Position
 PRX Channel Delta Next Go to Relative Desired Position
 PX Channel Delta Next Go to Absolute Desired Position
 R [Option] MicroBasic Run
 RC Channel Value Set Pulse Out
 S Channel Value Set Motor Speed
 SX Channel Value Next Velocity
 VAR VarNbr Value Set User Variable
 
 Maintenance Commands start with %
 ***Start on page 265
 CLMOD Key Calibrate Sin/Cos sensors
 CLRST Key Reset configuration to factory defaults
 CLSAV Key Save calibrations to Flash
 DFU Key Update Firmware via USB
 EELD None Load Parameters from EEPROM
 EERST Key Reset Factory Defaults
 EESAV None Save Configuration in EEPROM
 LK Key Lock Configuration Access
 RESET Key Reset Controller
 SLD Key Script Load
 STIME Time Set Time
 UK Key Unlock Configuration Access
 
 Set/Read Configuration Commands start with ~ (read) or ^ (set)
 ***start on 269
 General Safety and Configuration commands 
 ***start on 271
 ACS Enable Analog Center Safety
 AMS Enable Analog within Min & Max Safety
 BEE Address Value User Storage in Battery Backed RAM
 BRUN Enable MicroBasic Auto Start
 CLIN Channel Linearity Command Linearity
 CPRI Level Command Command Priorities
 DFC Channel Value Default Command value
 ECHOF OffOn Enable/Disable Serial Echo
 EE Address Data Store User Data in Flash
 RSBR BitRate Set RS232 bit rate
 RWD Timeout Serial Data Watchdog
 SCRO Port Select Print output port for scripting
 SKCTR Channel Center Spektrum Center
 SKDB Channel Deadband Spektrum Deadband
 SKLIN Channel Linearity Spektrum Linearity
 SKMAX Channel Max Spektrum Max
 SKMIN Channel Min Spektrum Min
 SKUSE Channel Port Assign Spektrum port to
 motor command
 TELS String Telemetry string
 
 Analog, Digital, Pulse IO Configurations
 ***start on 284
 ACTR InputNbr Center Set Analog Input Center (0) Level
 ADB InputNbr Deadband Analog Deadband
 AINA InputNbr Use Analog Input Use
 ALIN InputNbr Linearity Analog Linearity
 AMAX InputNbr Max Set Analog Input Max Range
 AMAXA InputNbr Action Action at Analog Max
 AMIN InputNbr Min Set Analog Input Min Range
 AMINA InputNbr Action Action at Analog Min
 AMOD InputNbr Mode Enable and Set Analog Input Mode
 APOL InputNbr Polarity Analog Input Polarity
 DINA InputNbr Action Digital Input Action
 DINL ActiveLevels Digital Input Active Level
 DOA OutputNbr Action Digital Output Action
 DOL ActiveLevels Digital Outputs Active Level
 PCTR InputNbr Center Pulse Center Range
 PDB InputNbr Deadband Pulse Input Deadband
 PINA InputNbr Use Pulse Input Use
 PLIN InputNbr Linearity Pulse Linearity
 PMAX InputNbr Max Pulse Max Range
 PMAXA InputNbr Action Action on Pulse Max
 PMIN InputNbr Min Pulse Min Range
 PMINA InputNbr Action Action on Pulse Min
 PMOD InputNbr Mode Pulse Mode Select
 PPOL InputNbr Polarity Pulse Input Polarity
 
 Motor Configuration
 ***start on 305
 ALIM Channel Limit Amp Limit
 ATGA Channel Action Amps Trigger Action
 ATGD Channel Delay Amps Trigger Delay
 ATRIG Channel Level Amps Trigger Level
 BKD Delay Brake activation delay in ms
 BLFB Channel Sensor Encoder or Hall Sensor Feedback for closed loop
 BLSTD Channel Mode Stall Detection
 CLERD Channel Mode Close Loop Error Detection
 EHL Channel Value Encoder High Count Limit
 EHLA Channel Action Encoder High Limit Action
 EHOME Channel Value Encoder Counter Load at Home Position
 ELL Channel Value Encoder Low Count Limit
 ELLA Channel Action Encoder Low Limit Action
 EMOD Channel Use Encoder Usage
 EPPR Channel Value Encoder PPR Value
 ICAP Channel Cap PID Integral Cap
 KD Channel Gain PID Differential Gain
 KI Channel Gain PID Integral Gain
 KP Channel Gain PID Proportional Gain
 MAC Channel Acceleration Motor Acceleration Rate
 MDEC Channel Deceleration Motor Deceleration Rate
 MMOD Channel Mode Operating Mode
 MVEL Channel Velocity Default Position Velocity
 MXMD Mode Separate or Mixed Mode Select
 MXPF Channel MaxPower Motor Max Power Forward
 MXPR Channel MaxPower Motor Max Power Reverse
 MXRPM Channel RPM Max RPM Value
 MXTRN Channel Turns Number of turns between limits
 OVH Voltage Overvoltage hysteresis
 OVL Voltage Overvoltage Cutoff Limit
 PWMF Frequency PWM Frequency
 THLD Threshold Short Circuit Detection Threshold
 UVL Voltage Undervoltage Limit
 
 
 for furture script potential
 The bytecodes in the .hex file can also be loaded in the controller by any microcomputer
 using the following sequence:
 Send the string:
 %sld 321654987
 the controller will reply with
 HLD
 to indicate it is waiting for data
 then send the hex file, one line at a time. At the end of each line received, the controller
 will send a +
 Beware that if no data is received for more than 1s, the controller will exit the HLD mode.
 
 
 
 
 */