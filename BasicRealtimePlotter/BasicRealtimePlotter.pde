// import libraries
import org.neuroph.util.plugins.*;
import org.neuroph.core.transfer.*;
import org.neuroph.util.*;
import org.neuroph.nnet.comp.layer.*;
import org.neuroph.nnet.*;
import org.neuroph.core.events.*;
import org.neuroph.core.learning.error.*;
//import org.neuroph.core.data.sample.*;
import org.neuroph.util.io.*;
import org.neuroph.core.exceptions.*;
import org.neuroph.core.learning.*;
import org.neuroph.core.input.*;
import org.neuroph.nnet.learning.*;
import org.neuroph.util.benchmark.*;
import org.neuroph.util.random.*;
import org.neuroph.nnet.comp.*;
import org.neuroph.core.learning.stop.*;
import org.neuroph.core.data.*;
import org.neuroph.core.*;
import org.neuroph.nnet.comp.neuron.*;
//import org.neuroph.core.data.norm.*;

import java.util.*;

import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*; // http://www.sojamo.de/libraries/controlP5/
import processing.serial.*;
int num = 50;
float[] arrayOfFloats = new float[num];
import AULib.*;
 import org.gicentre.utils.stat.*; 
import oscP5.*;
import netP5.*;
import processing.net.*;
Server myServer,myServer2,myServer3,myServer4;
OscP5 oscP5;
NetAddress myRemoteLocation;
double[] f1 = new double[4];
double[] f2 = new double[4];
double[] f3 = new double[4];
double[] f4 = new double[4];
double[] f5 = new double[4];
double[] f6 = new double[4];
double[] f7 = new double[4];
double[] f8 = new double[4];
double[] f9 = new double[4];
double[] f10 = new double[4];

double[] input = new double[43];

double s1;//blink
double s2;//concentration
double s3;//mellow

BarChart barChart;

/* SETTINGS BEGIN */

// Serial port to connect to
String serialPortName = "127.0.0.1";

// If you want to debug the plotter without using a real serial port set this to true
boolean mockupSerial = true;

/* SETTINGS END */

Serial serialPort; // Serial port object

// interface stuff
ControlP5 cp5;

// Settings for the plotter are saved in this file
JSONObject plotterConfigJSON;

// plots
Graph BarChart = new Graph(225, 70, 600, 150, color(20, 20, 200));
Graph LineGraph = new Graph(225, 350, 600, 200, color (20, 20, 200));
float[] barChartValues = new float[7];
float[][] lineGraphValues = new float[7][100];
float[] lineGraphSampleNumbers = new float[100];
color[] graphColors = new color[7];

// helper for saving the executing path
String topSketchPath = "";

void setup() {
  
   for (int i =0; i<43;i++)
  {
    input[i] = 0;
  }
  frame.setTitle("Realtime plotter");
  size(890, 620);
  smooth();
  frameRate(25);
  oscP5 = new OscP5(this,5000,OscP5.TCP);
  barChart = new BarChart(this);
  //**Server implementation
  // size(200, 200);
  // Starts a myServer on port 5204
  myServer = new Server(this, 5204); 
 
 
  // set line graph colors
  graphColors[0] = color(131, 255, 20);
  graphColors[1] = color(232, 158, 12);
  graphColors[2] = color(255, 0, 0);
  graphColors[3] = color(62, 12, 232);
  graphColors[4] = color(13, 255, 243);
  graphColors[5] = color(200, 46, 232);

  // settings save file
  topSketchPath = sketchPath;
  plotterConfigJSON = loadJSONObject(topSketchPath+"/plotter_config.json");

  // gui
  cp5 = new ControlP5(this);
  
 // print(barChartValues);
  // init charts
  setChartSettings();
  for (int i=0; i<barChartValues.length; i++) {
    barChartValues[i] = 0;
  }
  // build x axis values for the line graph
  for (int i=0; i<lineGraphValues.length; i++) {
    for (int k=0; k<lineGraphValues[0].length; k++) {
      lineGraphValues[i][k] = 0;
      if (i==0)
        lineGraphSampleNumbers[k] = k;
    }
  }
  
  // start serial communication
  if (!mockupSerial) {
    //String serialPortName = Serial.list()[3];
    serialPort = new Serial(this, serialPortName, 5000);
  }
  else
    serialPort = null;

  // build the gui
  int x = 170;
  int y = 60;
  cp5.addTextfield("bcMaxY").setPosition(x, y).setText(getPlotterConfigString("bcMaxY")).setWidth(40).setAutoClear(false);
  cp5.addTextfield("bcMinY").setPosition(x, y=y+150).setText(getPlotterConfigString("bcMinY")).setWidth(40).setAutoClear(false);
  cp5.addTextfield("lgMaxY").setPosition(x, y=y+130).setText(getPlotterConfigString("lgMaxY")).setWidth(40).setAutoClear(false);
  cp5.addTextfield("lgMinY").setPosition(x, y=y+200).setText(getPlotterConfigString("lgMinY")).setWidth(40).setAutoClear(false);

  cp5.addTextlabel("on/off2").setText("on/off").setPosition(x=13, y=20).setColor(0);
  cp5.addTextlabel("multipliers2").setText("multipliers").setPosition(x=55, y).setColor(0);
  cp5.addTextfield("bcMultiplier1").setPosition(x=60, y=30).setText(getPlotterConfigString("bcMultiplier1")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("bcMultiplier2").setPosition(x, y=y+40).setText(getPlotterConfigString("bcMultiplier2")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("bcMultiplier3").setPosition(x, y=y+40).setText(getPlotterConfigString("bcMultiplier3")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("bcMultiplier4").setPosition(x, y=y+40).setText(getPlotterConfigString("bcMultiplier4")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("bcMultiplier5").setPosition(x, y=y+40).setText(getPlotterConfigString("bcMultiplier5")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("bcMultiplier6").setPosition(x, y=y+40).setText(getPlotterConfigString("bcMultiplier6")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addToggle("bcVisible1").setPosition(x=x-50, y=30).setValue(int(getPlotterConfigString("bcVisible1"))).setMode(ControlP5.SWITCH);
  cp5.addToggle("bcVisible2").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("bcVisible2"))).setMode(ControlP5.SWITCH);
  cp5.addToggle("bcVisible3").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("bcVisible3"))).setMode(ControlP5.SWITCH);
  cp5.addToggle("bcVisible4").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("bcVisible4"))).setMode(ControlP5.SWITCH);
  cp5.addToggle("bcVisible5").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("bcVisible5"))).setMode(ControlP5.SWITCH);
  cp5.addToggle("bcVisible6").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("bcVisible6"))).setMode(ControlP5.SWITCH);
  cp5.addToggle("bcVisible7").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("bcVisible7"))).setMode(ControlP5.SWITCH);

  cp5.addTextlabel("label").setText("on/off").setPosition(x=13, y=y+90).setColor(0);
  cp5.addTextlabel("multipliers").setText("multipliers").setPosition(x=55, y).setColor(0);
  cp5.addTextfield("lgMultiplier1").setPosition(x=60, y=y+10).setText(getPlotterConfigString("lgMultiplier1")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("lgMultiplier2").setPosition(x, y=y+40).setText(getPlotterConfigString("lgMultiplier2")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("lgMultiplier3").setPosition(x, y=y+40).setText(getPlotterConfigString("lgMultiplier3")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("lgMultiplier4").setPosition(x, y=y+40).setText(getPlotterConfigString("lgMultiplier4")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("lgMultiplier5").setPosition(x, y=y+40).setText(getPlotterConfigString("lgMultiplier5")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addTextfield("lgMultiplier6").setPosition(x, y=y+40).setText(getPlotterConfigString("lgMultiplier6")).setColorCaptionLabel(0).setWidth(40).setAutoClear(false);
  cp5.addToggle("lgVisible1").setPosition(x=x-50, y=330).setValue(int(getPlotterConfigString("lgVisible1"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[0]);
  cp5.addToggle("lgVisible2").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("lgVisible2"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[1]);
  cp5.addToggle("lgVisible3").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("lgVisible3"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[2]);
  cp5.addToggle("lgVisible4").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("lgVisible4"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[3]);
  cp5.addToggle("lgVisible5").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("lgVisible5"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[4]);
  cp5.addToggle("lgVisible6").setPosition(x, y=y+40).setValue(int(getPlotterConfigString("lgVisible6"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[5]);
}

byte[] inBuffer = new byte[100]; // holds serial message
int i = 0; // loop variable


////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
 //print("### received an osc message.");
  if (theOscMessage.checkAddrPattern("/muse/elements/alpha_absolute") == true)
  {
     //s1 = 0;
    for (int i=0 ; i<4; i++)   
     {
       f1[i] = (theOscMessage.get(i).floatValue());
  
       
     }

    
  }
  
  /////////////////////////////////////////////////////////////////////
   if (theOscMessage.checkAddrPattern("/muse/elements/alpha_relative") == true)
  {
     //s1 = 0;
    for (int i=0 ; i<4; i++)   
     {
       f2[i] = theOscMessage.get(i).floatValue();
     }

    
  }
  //////////////////////////////////////////////////////////////////////
   if (theOscMessage.checkAddrPattern("/muse/elements/beta_absolute") == true)
  {
     //s1 = 0;
    for (int i=0 ; i<4; i++)   
     {
       f3[i] = theOscMessage.get(i).floatValue();
     }

    
  }
  //////////////////////////////////////////////////////////////////////

  if (theOscMessage.checkAddrPattern("/muse/elements/beta_relative") == true)
  {
     for (int i=0 ; i<4; i++)   
     {
       f4[i] = theOscMessage.get(i).floatValue();
     }
  }
  
  //////////////////////////////////////////////////////////////////////////
   if (theOscMessage.checkAddrPattern("/muse/elements/blink") == true)
  {
      s1 =theOscMessage.get(0).intValue();
  }
  
  //////////////////////////////////////////////////////////////////////////
  

  
  if (theOscMessage.checkAddrPattern("/muse/elements/delta_absolute") == true)
  {
      for (int i=0 ; i<4; i++)   
     {
       f5[i] = theOscMessage.get(i).floatValue();
     }  
   
  }
  ////////////////////////////////////////////////////////////////////////////
  
   
    if (theOscMessage.checkAddrPattern("/muse/elements/delta_relative") == true)
  {
      for (int i=0 ; i<4; i++)   
     {
       f6[i] = theOscMessage.get(i).floatValue();
     }  
   
  }
  //////////////////////////////////////////////////////////////////////////////
   if (theOscMessage.checkAddrPattern("/muse/elements/experimental/concentration") == true)
   {
        s2 = theOscMessage.get(0).floatValue();
   }
   ////////////////////////////////////////////////////////////////////////////////
   
    if (theOscMessage.checkAddrPattern("/muse/elements/experimental/mellow") == true)
   {
        s3 = theOscMessage.get(0).floatValue();
   }
   /////////////////////////////////////////////////////////////////////////////////////
  
  if (theOscMessage.checkAddrPattern("/muse/elements/gamma_absolute") == true)
  {
         for (int i=0 ; i<4; i++)   
     {
       f7[i] = theOscMessage.get(i).floatValue();
     }
     
 }
 
    /////////////////////////////////////////////////////////////////////////////////////
      if (theOscMessage.checkAddrPattern("/muse/elements/gamma_relative") == true)
  {
         for (int i=0 ; i<4; i++)   
     {
       f8[i] = theOscMessage.get(i).floatValue();
     }
    
 }
 
    /////////////////////////////////////////////////////////////////////////////////////
   if (theOscMessage.checkAddrPattern("/muse/elements/theta_absolute") == true)
  {
       for (int i=0 ; i<4; i++)   
     {
       f9[i] = theOscMessage.get(i).floatValue();
     }
   
  }
 
  if (theOscMessage.checkAddrPattern("/muse/elements/theta_relative") == true)
  {
       for (int i=0 ; i<4; i++)   
     {
       f10[i] = theOscMessage.get(i).floatValue();
       
     }
    
 
  }
 
 ////construct the input array
  for (int i =0; i<4;i++)
  {
    input[i] = f1[i]; // alpha absolute
    input[i+4] = f2[i];// alpha relative
    input[i+8] = f3[i]; // beta absolute
    input[i+12] = f4[i];// beta relative
    input[16] = s1; //blink
    input[i+17] = f5[i];// delta_absolute
    input[i + 21] = f6[i];// delta_relative
    input[25] = s2;//concentration
    input[26]=s3; //mellow
    input[i+27] = f7[i]; //gamma_ab
    input[i+31] = f8[i]; //gamma real
    input[i+35] = f9[i];//theta/ab
    input[i+39] = f10[i]; //theta_relative
    
  }
  println(input);
 
 
DataSet trainingSet = new DataSet(43, 2);
//trainingSet.addRow(new DataSetRow (input));
  // load saved neural network
  NeuralNetwork loadedPerceptron = NeuralNetwork.load("Neural_Net.nnet");
// test loaded neural network
  System.out.println("Testing loaded perceptron");
  testNeuralNetwork(loadedPerceptron, input);
  
}  

/////////////////////////////////////
///////////////////////////////////////////
//////////////////////////////////////////

void draw() {
  /* Read serial and update values */
  if (mockupSerial || serialPort.available() > 0) {
    String myString = "";

   
  myString = mockupSerialFunction();

   // println(myString);

    // split the string at delimiter (space)
    String[] nums = split(myString, ' ');
  //  println(nums);
    
    // count number of bars and line graphs to hide
    int numberOfInvisibleBars = 0;
    for (i=0; i<6; i++) {
      if (int(getPlotterConfigString("bcVisible"+(i+1))) == 0) {
        numberOfInvisibleBars++;
      }
    }
    int numberOfInvisibleLineGraphs = 0;
    for (i=0; i<6; i++) {
      if (int(getPlotterConfigString("lgVisible"+(i+1))) == 0) {
        numberOfInvisibleLineGraphs++;
      }
    }
    // build a new array to fit the data to show
    barChartValues = new float[7-numberOfInvisibleBars];

    // build the arrays for bar charts and line graphs
    int barchartIndex = 0;
    for (i=0; i<nums.length; i++) {

      // update barchart
      try {
        if (int(getPlotterConfigString("bcVisible"+(i+1))) == 1) {
          if (barchartIndex < barChartValues.length)
            barChartValues[barchartIndex++] = float(nums[i])*float(getPlotterConfigString("bcMultiplier"+(i+1)));
        }
        else {
        }
      }
      catch (Exception e) {
      }

      // update line graph
      try {
        if (i<lineGraphValues.length) {
          for (int k=0; k<lineGraphValues[i].length-1; k++) {
            lineGraphValues[i][k] = lineGraphValues[i][k+1];
          }

          lineGraphValues[i][lineGraphValues[i].length-1] = float(nums[i])*float(getPlotterConfigString("lgMultiplier"+(i+1)));
        }
      }
      catch (Exception e) {
      }
    }
  }

  // draw the bar chart
  background(255); 
  BarChart.DrawAxis();              
  BarChart.Bar(barChartValues); // This draws a bar graph of Array4
  // println(barChartValues);

  // draw the line graphs
  LineGraph.DrawAxis();
  for (int i=0;i<lineGraphValues.length; i++) {
    LineGraph.GraphColor = graphColors[i];
    if (int(getPlotterConfigString("lgVisible"+(i+1))) == 1)
      LineGraph.LineGraph(lineGraphSampleNumbers, lineGraphValues[i]);
  }
}

// called each time the chart settings are changed by the user 
void setChartSettings() {
  BarChart.xLabel="Frequency Band ";
  BarChart.yLabel="Relative Band Power (%)";
  BarChart.Title="Real Time EEG Band Power Diagram";  
  BarChart.xDiv=1;  
  BarChart.yMax=int(getPlotterConfigString("bcMaxY")); 
  BarChart.yMin=int(getPlotterConfigString("bcMinY"));

  LineGraph.xLabel=" Samples ";
  LineGraph.yLabel="Relative Band Power (%)";
  LineGraph.Title="";  
  LineGraph.xDiv=20;  
  LineGraph.xMax=0; 
  LineGraph.xMin=-100;  
 // LineGraph.yMax=int(getPlotterConfigString("lgMaxY")); 
  LineGraph.yMin=int(getPlotterConfigString("lgMinY"));
 LineGraph.yMax=60;
 
}

// handle gui actions
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class) || theEvent.isAssignableFrom(Toggle.class) || theEvent.isAssignableFrom(Button.class)) {
    String parameter = theEvent.getName();
    String value = "";
    if (theEvent.isAssignableFrom(Textfield.class))
      value = theEvent.getStringValue();
    else if (theEvent.isAssignableFrom(Toggle.class) || theEvent.isAssignableFrom(Button.class))
      value = theEvent.getValue()+"";

    plotterConfigJSON.setString(parameter, value);
    saveJSONObject(plotterConfigJSON, topSketchPath+"/plotter_config.json");
  }
  setChartSettings();
}

// get gui settings from settings file
String getPlotterConfigString(String id) {
  String r = "";
  try {
    r = plotterConfigJSON.getString(id);
  } 
  catch (Exception e) {
    r = "";
  }
  return r;
}

