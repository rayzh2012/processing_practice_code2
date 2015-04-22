/**
* ControlP5 Textlabel
*
*
* find a list of public methods available for the Textlabel Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;

ControlP5 cp5;

Textlabel myTextlabelA;
Textlabel myTextlabelB;

void setup() {
  size(700,400);
  cp5 = new ControlP5(this);

  myTextlabelA = cp5.addTextlabel("label")
                    .setText("A single ControlP5 textlabel, in yellow.")
                    .setPosition(100,50)
                    .setColorValue(0xffffff00)
                    .setFont(createFont("Georgia",20))
                    ;

  myTextlabelB = new Textlabel(cp5,"Another textlabel, not created through ControlP5 needs to be rendered separately by calling Textlabel.draw(PApplet).",100,100,400,200);

}



void draw() {
  background(0);
  myTextlabelB.draw(this); 
}

