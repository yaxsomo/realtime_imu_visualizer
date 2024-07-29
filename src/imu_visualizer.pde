/**
Visualize a cube which will assumes the orientation described
in a quaternion coming from the serial port.

INSTRUCTIONS: 
You need to run this program when the data transmission of quaternions ha already started from your setup.

---------
Here's how I transmit data (via UART to COM7 port of my Windows PC) :
// Assuming you have already read quaternions from your sensor
char quaternionStr[100];
sprintf(quaternionStr, "%.6f,%.6f,%.6f,%.6f,%.6f\r\n", data->quaternion.w, data->quaternion.x, data->quaternion.y, data->quaternion.z, 0.1);
HAL_UART_Transmit(&huart1, (uint8_t*)quaternionStr, strlen(quaternionStr), HAL_MAX_DELAY);
------

Copyright (C) 2024 Yassine DEHHANI - https://www.yassine-dehhani.com/

*/

import processing.serial.*;
import processing.opengl.*;

Serial myPort;  // Create object from Serial class

final String serialPort = "COM7"; // replace this with your serial port. On windows you will need something like "COM1".

float [] q = new float [4];
float lama = 0.0;
float [] hq = null;
float [] Euler = new float [3]; // psi, theta, phi

int lf = 10; // 10 is '\n' in ASCII
byte[] inBuffer = new byte[22]; // this is the number of chars on each line from the Arduino (including /r/n)

PFont font;
final int VIEW_SIZE_X = 800, VIEW_SIZE_Y = 600;

//final int burst = 1;
final int burst = 32;
int count = 0;

void myDelay(int time) {
  try {
    Thread.sleep(time);
  } catch (InterruptedException e) { }
}
String versi = "";
void setup() 
{
  //size(VIEW_SIZE_X, VIEW_SIZE_Y, OPENGL);
  size(800, 600, OPENGL); //<>//
  myPort = new Serial(this, serialPort, 115200);
  
  // The font must be located in the sketch's "data" directory to load successfully
  font = loadFont("CourierNew36.vlw"); 
  
  println("Waiting IMU..");
  
  myPort.clear();
  
    myDelay(1000);
  //while (myPort.available() == 0) {
    myPort.write("v");
    myDelay(1000);
  //}
  versi = myPort.readStringUntil('\n');
  println("Data: " + versi);
  myPort.write("q" + char(burst));
  myPort.bufferUntil('\n');
}


void serialEvent(Serial p) {
  if (p.available() >= 18) {
    String inputString = p.readStringUntil('\n');
    if (inputString != null && inputString.length() > 0) {
      //println("Data not null");
      if (inputString.indexOf(',') != -1) {
        String[] inputStringArr = split(inputString.trim(), ','); // Trim to remove extra whitespace
        println("Split data: " + join(inputStringArr, " | ")); // Debugging: Print the split data
        //String[] inputStringArr = split(inputString, ",");
        if (inputStringArr.length == 5) { // q1, q2, q3, q4, lama, \r\n so we have 5 elements
          try {
            q[0] = float(inputStringArr[0]);
            q[1] = float(inputStringArr[1]);
            q[2] = float(inputStringArr[2]);
            q[3] = float(inputStringArr[3]);
            lama = float(inputStringArr[4]);
            
          } catch (NumberFormatException e) {
            println("Error parsing input: " + inputString);
          }
        } else {
        println("Data length not correct");
        }
      } else {
        println("Problemoooosss");
        versi = inputString;
      }
    }
    count = count + 1;
    if (burst == count) { // ask for more data when burst completed
      p.write("q" + char(burst));
      count = 0;
    }
  }
}



void buildBoxShape() {
  //box(60, 10, 40);
  noStroke();
  beginShape(QUADS);
  
  //Z+ (to the drawing area)
  fill(#00ff00);
  vertex(-30, -5, 20);
  vertex(30, -5, 20);
  vertex(30, 5, 20);
  vertex(-30, 5, 20);
  
  //Z-
  fill(#0000ff);
  vertex(-30, -5, -20);
  vertex(30, -5, -20);
  vertex(30, 5, -20);
  vertex(-30, 5, -20);
  
  //X-
  fill(#ff0000);
  vertex(-30, -5, -20);
  vertex(-30, -5, 20);
  vertex(-30, 5, 20);
  vertex(-30, 5, -20);
  
  //X+
  fill(#ffff00);
  vertex(30, -5, -20);
  vertex(30, -5, 20);
  vertex(30, 5, 20);
  vertex(30, 5, -20);
  
  //Y-
  fill(#ff00ff);
  vertex(-30, -5, -20);
  vertex(30, -5, -20);
  vertex(30, -5, 20);
  vertex(-30, -5, 20);
  
  //Y+
  fill(#00ffff);
  vertex(-30, 5, -20);
  vertex(30, 5, -20);
  vertex(30, 5, 20);
  vertex(-30, 5, 20);
  
  endShape();
}


void drawCube() {  
  pushMatrix();
    translate(VIEW_SIZE_X/2, VIEW_SIZE_Y/2 + 50, 0);
    scale(5,5,5);
    
    // a demonstration of the following is at 
    // http://www.varesano.net/blog/fabio/ahrs-sensor-fusion-orientation-filter-3d-graphical-rotating-cube
    rotateZ(-Euler[2]);
    rotateX(-Euler[1]);
    rotateY(-Euler[0]);
    
    buildBoxShape();
    
  popMatrix();
}


void draw() {
  background(#000000);
  fill(#ffffff);
  
  if(hq != null) { // use home quaternion
    quaternionToEuler(quatProd(hq, q), Euler);
    text("Disable home position by pressing \"n\"", 20, VIEW_SIZE_Y - 50);
  }
  else {
    quaternionToEuler(q, Euler);
    text("Point FreeIMU's X axis to your monitor then press \"h\"", 20, VIEW_SIZE_Y - 50);
  }
  
  textFont(font, 20);
  textAlign(LEFT, TOP);
  text("Q:\n" + q[0] + "\n" + q[1] + "\n" + q[2] + "\n" + q[3] + "\n"  + "Lama: " + lama + " us" + "\n" + versi, 20, 20);
  text("Euler Angles:\nYaw (psi)  : " + degrees(Euler[0]) + "\nPitch (theta): " + degrees(Euler[1]) + "\nRoll (phi)  : " + degrees(Euler[2]), 200, 20);
 
  drawCube();
  //myPort.write("q" + 1);
}


void keyPressed() {
  if(key == 'h') {
    println("pressed h");
    
    // set hq the home quaternion as the quatnion conjugate coming from the sensor fusion
    hq = quatConjugate(q);
    
  }
  else if(key == 'v') {
      println("pressed v");
      myPort.write("v");
  }
  else if(key == 'n') {
    println("pressed n");
    hq = null;
  }
}

// See Sebastian O.H. Madwick report 
// "An efficient orientation filter for inertial and intertial/magnetic sensor arrays" Chapter 2 Quaternion representation

void quaternionToEuler(float [] q, float [] euler) {
  euler[0] = atan2(2 * q[1] * q[2] - 2 * q[0] * q[3], 2 * q[0]*q[0] + 2 * q[1] * q[1] - 1); // psi
  euler[1] = -asin(2 * q[1] * q[3] + 2 * q[0] * q[2]); // theta
  euler[2] = atan2(2 * q[2] * q[3] - 2 * q[0] * q[1], 2 * q[0] * q[0] + 2 * q[3] * q[3] - 1); // phi
}

float [] quatProd(float [] a, float [] b) {
  float [] q = new float[4];
  
  q[0] = a[0] * b[0] - a[1] * b[1] - a[2] * b[2] - a[3] * b[3];
  q[1] = a[0] * b[1] + a[1] * b[0] + a[2] * b[3] - a[3] * b[2];
  q[2] = a[0] * b[2] - a[1] * b[3] + a[2] * b[0] + a[3] * b[1];
  q[3] = a[0] * b[3] + a[1] * b[2] - a[2] * b[1] + a[3] * b[0];
  
  return q;
}

// returns a quaternion from an axis angle representation
float [] quatAxisAngle(float [] axis, float angle) {
  float [] q = new float[4];
  
  float halfAngle = angle / 2.0;
  float sinHalfAngle = sin(halfAngle);
  q[0] = cos(halfAngle);
  q[1] = -axis[0] * sinHalfAngle;
  q[2] = -axis[1] * sinHalfAngle;
  q[3] = -axis[2] * sinHalfAngle;
  
  return q;
}

// return the quaternion conjugate of quat
float [] quatConjugate(float [] quat) {
  float [] conj = new float[4];
  
  conj[0] = quat[0];
  conj[1] = -quat[1];
  conj[2] = -quat[2];
  conj[3] = -quat[3];
  
  return conj;
}
