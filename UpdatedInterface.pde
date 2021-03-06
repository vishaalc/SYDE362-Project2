//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
OscP5 osc;
NetAddress dest;

// These are needed for the moving average calculation
float[] data1 = new float[2];
float total1 = 0, average1 = 0;
int m1 = 0, n1 = 0;

float[] data2 = new float[2];
float total2 = 0, average2 = 0;
int m2 = 0, n2 = 0;

float[] data3 = new float[2];
float total3 = 0, average3 = 0;
int m3 = 0, n3 = 0;

float[] data4 = new float[2];
float total4 = 0, average4 = 0;
int m4 = 0, n4 = 0;

// delay = 0, a = 1, so on
int previousValue = -1;
int currentValue = 0;

int decay1 = 200;
int decay2 = 200;
int decay3 = 200;
int decay4 = 200;

int heightA = 5;
int heightB = 5;
int heightC = 5;
int heightD = 5;

int decayStart = 200;
int decayAmount = 10;
int count = 0;

float lowLim = 0.2;
float highLim = 0.8;

float start = 0;
boolean first = true;

Table table = new Table();

PFont f;  
float elasped = 0.0;
float s = 0;
String global_event = "";


void setup()
{
  size(1024, 668);
    //Initialize OSC communication
  osc = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  rectMode(CENTER);
  //table.addColumn("decay1");
  //table.addColumn("decay2");
  //table.addColumn("decay3");
  //table.addColumn("decay4");
  table.addColumn("SAMPLE COUNT");
  table.addColumn("TIMESTAMP");
  table.addColumn("SOUND");
  TableRow firstRow = table.addRow();
  firstRow.setInt("SAMPLE COUNT", 0);
  firstRow.setFloat("TIMESTAMP", 0.0);
  firstRow.setString("SOUND", "Delay");
  previousValue = 0;
  
  f = createFont("Arial-Black",24,true);
  
float[] numbers = {1,2,3,4,5,6,7,8,9,10};
  for(int i = 0; i < numbers.length; i++){
    nextValue1(numbers[i]);
    nextValue2(numbers[i]);
    nextValue3(numbers[i]);
    nextValue4(numbers[i]);
  }  
}

void draw()
{
  if (first) {
    return;
  }
  background(255, 255, 255);
  if((average1 > highLim) && (average2 < lowLim) && (average3 < lowLim)  && (average4 < lowLim)) {
    decay1 = decayStart;
    decay2 -= decayAmount;
    decay3 -= decayAmount;
    decay4 -= decayAmount;
  } else if((average1 < lowLim) && (average2 > highLim) && (average3 < lowLim) && (average4 < lowLim)){
    decay1 -= decayAmount;
    decay2 = decayStart;
    decay3 -= decayAmount;
    decay4 -= decayAmount;
  } else if((average1 < lowLim) && (average2 < lowLim) && (average3 > highLim) && (average4 < lowLim)){
    decay1 -= decayAmount;
    decay2 -= decayAmount;
    decay3 = decayStart;
    decay4 -= decayAmount;
  } else if((average1 < lowLim) && (average2 < lowLim) && (average3 < lowLim) && (average4 > highLim)){
    decay1 -= decayAmount;
    decay2 -= decayAmount;
    decay3 -= decayAmount; 
    decay4 = decayStart;
  } else {
    decay1 -= decayAmount;
    decay2 -= decayAmount;
    decay3 -= decayAmount; 
    decay4 -= decayAmount;
  }
    
    if(decay1 < 0){decay1 = 0;}
    if(decay2 < 0){decay2 = 0;}
    if(decay3 < 0){decay3 = 0;}
    if(decay4 < 0){decay4 = 0;}
  
    //Drawing all the rectangles
    fill(decay1 + 100,0,0, 200); //A
    rect(168, 73, 300,  100, 20);
    fill(0,decay2+ 100,0, 200); //B
    rect(168, 234, 300, 100, 20);
    fill(0,0,decay3+100, 200);//C
    rect(168, 395,  300,100, 20);  
    fill(decay4 +54, decay4, decay4 +55, 200);//D
    rect(168, 556, 300,  100, 20);  
    
    //Histogram
    fill(256, 256, 256);
    rect(630, 650-312.5, 485,  625, 20); 
    fill(256,0,0);// A
    rect(475, 650-(heightA/2), 80,  heightA); 
    fill(0,256,0);// B
    rect(575, 650-(heightB/2), 80,  heightB); 
    fill(0,0,256);// C
    rect(675, 650-(heightC/2), 80,  heightC); 
    fill(256,41,255);// D
    rect(775, 650-(heightD/2), 80,  heightD); 
    
    textFont(f,30);    
    fill(0, 255);                        
    text("A",155,80);   
    text("B",155,245); 
    text("C",155,405); 
    text("D",155,570);
    textFont(f, 16);
    fill(0);
      if (start > 0 && global_event != "end") {
        elasped = millis() - start; 
      }
    
      s = (elasped/ 1000) % 60;
      text(s, 915, 30);

   
    
    if(decay1 == decayStart) {
        currentValue = 1;
    }
    else if(decay2 == decayStart) {
        currentValue = 2;
    }
    else if(decay3 == decayStart) {
        currentValue = 3;
    }
    else if(decay4 == decayStart) {
        currentValue = 4;
    }
    else {
        currentValue = 0;
    }
        
    if ((decay1 == decayStart && (previousValue != currentValue)) 
        || (decay2 == decayStart && (previousValue != currentValue)) 
        || (decay3 == decayStart && (previousValue != currentValue)) 
        || (decay4 == decayStart && (previousValue != currentValue)) 
        || (previousValue != currentValue)) {
      
      TableRow newRow = table.addRow();
      newRow.setFloat("TIMESTAMP", (millis() - start)/1000.0);
      
      if(decay1 == decayStart) {
        newRow.setString("SOUND", "A");
       // println("A");
        previousValue = 1;
        heightA = heightA + 25;
      }
      else if(decay2 == decayStart) {
        newRow.setString("SOUND", "B");
      //  println("B");
        previousValue = 2;
        heightB = heightB + 25;
      }
      else if(decay3 == decayStart) {
        newRow.setString("SOUND", "C");
        //println("C");
        previousValue = 3;
        heightC = heightC + 25;
      }
      else if(decay4 == decayStart) {
        newRow.setString("SOUND", "D");
        //println("D");
        previousValue = 4;
        heightD = heightD + 25;
      }
      else if (previousValue != -1) {
        newRow.setString("SOUND", "Delay");
       // println("Delay");
        previousValue = 0;
      }
      newRow.setInt("SAMPLE COUNT", count);
    }
    
}

void reset() {
  decay1 = 200;
  decay2 = 200;
  decay3 = 200;
  decay4 = 200;
  
  heightA = 10;
  heightB = 10;
  heightC = 10;
  heightD = 10;
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("ffff")) { //Now looking for parameters
        count++;
        float p1 = theOscMessage.get(0).floatValue(); //get first parameter
        float p2 = theOscMessage.get(1).floatValue(); //get second parameter
        float p3 = theOscMessage.get(2).floatValue(); //get third parameter
        float p4 = theOscMessage.get(3).floatValue(); //get fourth parameter
        
        nextValue1(p1);
        nextValue2(p2);
        nextValue3(p3);
        nextValue4(p4);
        
        //println("Received new params value from Wekinator");  
      } else {
        println("Error: unexpected params type tag received by Processing");
      }
 }
 else if (theOscMessage.checkAddrPattern("/event")==true) {
   String event = theOscMessage.get(0).stringValue();
   String soundfile = (theOscMessage.get(1).stringValue());
   if (event.equals("start")) {
     first = false;
     println("Starting Processing on " + soundfile);
     //Reset Processing global vars
     reset();
     
     start = float(millis());
     global_event = "start";
   }
   else if (event.equals("end")) {
     saveTable(table, "data/" + soundfile +".csv");
     println("Done Processing on " + soundfile );
     table.clearRows();
     global_event = "end";
   }
}
}

// Use the next value and calculate the

// moving average1
public void nextValue1(float value){
  total1 -= data1[m1];
  data1[m1] = value;
  total1 += value;
  m1 = ++m1 % data1.length;
  if(n1 < data1.length) n1++;
  average1 = total1 / n1;
}

// moving average2
public void nextValue2(float value){
  total2 -= data2[m2];
  data2[m2] = value;
  total2 += value;
  m2 = ++m2 % data2.length;
  if(n2 < data2.length) n2++;
  average2 = total2 / n2;
}

// moving average3
public void nextValue3(float value){
  total3 -= data3[m3];
  data3[m3] = value;
  total3 += value;
  m3 = ++m3 % data3.length;
  if(n3 < data3.length) n3++;
  average3 = total3 / n3;
}

// moving average4
public void nextValue4(float value){
  total4 -= data4[m4];
  data4[m4] = value;
  total4 += value;
  m4 = ++m4 % data4.length;
  if(n4 < data4.length) n4++;
  average4 = total4 / n4;
}
