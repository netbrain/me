+++
categories = ["arduino"]
date = "2015-09-02T11:28:31+02:00"
tags = ["arduino", "sensor", "DIY", "IoT"]
title = "DIY Arduino parking sensor"
image = "/images/post/arduino-psens.jpg"
+++

I recently created a workbench in the far end of my garage. This however resulted in about 10 cm of clearance in total in front and behind the car. So needless to say it would be great if I had my own personal parking assistant.

So I set out with the goal of creating a simple parking assistant, which had to be cheap, small and accurate.I then browsed http://www.dx.com for the parts i needed and landed on the following pieces:

1. Arduino nano v3
2. HC-SR04 (Ultrasonic distance sensor)
3. Starter kit (breadbord, resistors, cables, LED's, etc.)

I read a couple of tutorials and started piecing the parts together. It was actually quite simple, and i found the whole experience to be quite enjoyable. The following breadboard describes how I assembled the parts & circuits.

[![breadboard](/images/post/psens_bb.png)](/images/post/psens_bb.png)

As for programming the chip I really wanted to use the [gobot](http://www.gobot.io) framework. However it turned out that you can't actually flash the arduino with this, instead it works like a remote. Where you run the golang application on a go capable machine, and then this application relays the instructions to the firmata firmware, through some means of communication. So I had to learn a little C/C++ in order to actually program the chip and came up with the following code.

```c++
#include <NewPing.h>

#define R_LED 2             // red led pin
#define Y_LED 3             // yellow led pin
#define G_LED 4             // green led pin
#define ECHO_PIN     11     // HC-SR04 echo pin
#define TRIGGER_PIN  12     // HC-SR04 trigger pin
#define MAX_DISTANCE 500    // max distance to mesture
#define DELAY 10            // nanoseconds between distance pings


//The history struct keeps track of previous distances measured
//and calculates the avg distance from the last hsize measures.
struct history {
  unsigned int cur;
  unsigned int hist[100];
  unsigned int hsize;
  history(unsigned int hsize = 10) :
  cur(0), hist({
    0  }
  ),hsize(hsize) {
  }
  void add(int i){
    hist[cur] = i;
    cur = (cur + 1) % hsize;  
  }
  int avg(){
    int sum = 0;
    int divider = hsize;
    for (int i = 0; i < hsize; i++) {
      if (hist[i%hsize] == 0) {
        divider--;
      }
      else{
        sum = sum + hist[i%hsize];
      }
    }
    return sum / divider;
  }
};

//HC-SR04 library
NewPing sonar(TRIGGER_PIN,ECHO_PIN,MAX_DISTANCE);

history *h = new history(50);

void setup(){
  pinMode(R_LED, OUTPUT);
  pinMode(G_LED, OUTPUT);
  pinMode(Y_LED, OUTPUT);
}

void loop(){
  delay(DELAY);

  //Add distance measured to history
  h->add(sonar.ping_cm());

  //Get the avg distance
  int distance = h->avg();

  //If nothing was returned within MAX_DISTANCE
  //power all leds
  if (distance == -1){
    nothing();
  }
  //If distance is greater than 100cm
  //power green led
  else if (distance > 100){
    green();  
  }
  //If distance is greater than 5cm
  //power yellow led
  else if (distance > 5){
    yellow();
  }
  //distance is 5cm or less, power red led and stop the car!
  else{
    red();
  }
}

void nothing() {
  digitalWrite(G_LED, HIGH);
  digitalWrite(Y_LED, HIGH);  
  digitalWrite(R_LED, HIGH);
}

void green(){
  digitalWrite(G_LED, HIGH);
  digitalWrite(Y_LED, LOW);  
  digitalWrite(R_LED, LOW);
}

void yellow(){
  digitalWrite(G_LED, LOW);
  digitalWrite(Y_LED, HIGH);  
  digitalWrite(R_LED, LOW);
}

void red(){
  digitalWrite(G_LED, LOW);
  digitalWrite(Y_LED, LOW);  
  digitalWrite(R_LED, HIGH);
}
```

The next step is to create some sort of casing and mounting for it and then mount it somewhere in my garage. But that will have to wait until my next dx.com shipment. :)
