/*
 * ***** BEGIN GPL LICENSE BLOCK *****
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * The Original Code is Copyright (C) 2016-2017 Marcelo "Tanda" Cerviño. http://lodetanda.blogspot.com/ 
 * All rights reserved.
 *
 * Contributor(s): Matías Cerviño (idea and testing) https://twitter.com/MatiasmacSD
 *
 * ***** END GPL LICENSE BLOCK *****
 */

import themidibus.*;

String os;

PImage imagetoMidi;
PImage imagelogo;

color Col;
float r;
float g; 
float b;
float H;
float S; 
float B;

int midiprevnote;  
int midinote;  
int midivel;
int midichannel = 0;
boolean noteon = false;
boolean keyon = false;

int notetype = 7;
int veltype = 2;
String ntype = "RGB";
String vtype = "Brightness";
float[] freq = new float[128]; 

int noteconst = 38; 
int velconst = 64; 

color bcolor = color(15, 16, 16);

MidiBus midiBus = null;
String midiout_list = " ----------"; 
int midiin_list_index = 0;
int midiout_list_index = 1;
int num_midiout_ports;

File imgfolder;

void setup () {

  size(800, 480);
  surface.setResizable(true);
  background(0);
  smooth();
  noLoop(); 
  imageMode(CENTER);
  cursor(CROSS);

  os = System.getProperty("os.name");
  os = os.toLowerCase();
  if (os.indexOf("linux") != -1) os = "LINUX";

  midiout_list = MidiBus.availableOutputs()[midiout_list_index];
  num_midiout_ports = MidiBus.availableOutputs().length;
  midiout_list = MidiBus.availableOutputs()[midiout_list_index];
  num_midiout_ports = MidiBus.availableOutputs().length;
  midiBus = new MidiBus(this, MidiBus.availableInputs()[midiin_list_index], MidiBus.availableOutputs()[midiout_list_index]);

  imagetoMidi = loadImage("default_image.png");
  imagelogo = loadImage("imagetomidi_logo.png");

  for (int i = 0; i < 128; i++) {
    freq[i] = 440 * (pow(2.0, (i - 69.0) / 12.0));
  }
}

void draw() {

  background(bcolor);

  image(imagelogo, width - 150, 50);

  if (imagetoMidi.width > imagetoMidi.height) { 
    float i = float(imagetoMidi.width) / float(imagetoMidi.height); 
    image(imagetoMidi, width / 2, height / 1.75, (height / 1.45) * i, height / 1.45);
  } else {
    float i = float(imagetoMidi.height)/float(imagetoMidi.width); 
    image(imagetoMidi, width / 2, height / 1.75, (height / 1.45) / i, height / 1.45);
  }

  textAlign(CENTER);
  fill(150);
  textSize(12);
  text("Web", width - 50, 95);
  fill(150);
  textSize(20);
  text("IMAGE TO MIDI v1.0", width / 2, 20);
  fill(200, 50, 50);
  textSize(18);
  text("-Playing with images-", width / 2, 50);
  textSize(12);
  text("-The color's sounds-", width / 2, 65);

  fill(200);
  text(midiout_list, width / 2, height - 25);
  text("<--", (width / 2) - 80, height - 25);
  text("-->", (width / 2) + 80, height - 25);
  fill(100);
  text("-MIDI out-", width / 2, height - 8);

  println(mouseX+"----"+mouseY);

  fill(200, 50, 50);
  if (os == "LINUX") text(">Add Virtual MIDI<", width  - 100, height -25);
  fill(20, 100, 100);
  text("Connect the selected virtual midi at any midi soft.", width /1.3 + 28, height -10);

  textAlign(CORNER);
  fill(100, 200, 50);
  textSize(12);
  text("-1 to 9 (change note mode)", 20, 20);
  text("-Q to O (change velocity mode)", 20, 35);
  text("-Any key or LEFT Mouse (Play MIDI notes)", 20, 50);
  text("-Mouse Wheel (Modulation)", 20, 65);
  text("-CENTER Mouse (Panic! MIDI)", 20, 80);
  text("-RIGHT Mouse (Load image: jpg, png, tga, gif)", 20, 95);
  text(vtype, 100, height - 10);
  text(ntype, 100, height - 25);
  text(e, 260, height - 10);
  fill(10, 100, 100);
  text("   Notes from:", 10, height - 25);
  text("Velocity from:", 10, height - 10);
  text("Modulation:", 180, height - 10);

  if (noteon) {
    info();
    redraw();
  }
}

void colorToMidi() {

  Col = get(mouseX, mouseY);

  r = red(Col);
  g = green(Col);
  b = blue(Col);
  H = hue(Col);
  S = saturation(Col);
  B = brightness(Col);

  switch(notetype) { 
  case 0: 
    midinote = floor(map(H, 0, 255, 0, 127));
    break;
  case 1:
    midinote = floor(map(S, 0, 255, 0, 127));
    break;
  case 2:
    midinote = floor(map(B, 0, 255, 0, 127));
    break;
  case 3:
    midinote = floor(map(r, 0, 255, 0, 127));
    break;
  case 4:
    midinote = floor(map(g, 0, 255, 0, 127));
    break;
  case 5:
    midinote = floor(map(b, 0, 255, 0, 127));
    break;
  case 6:
    midinote = floor(map((H + S + B) / 3, 0, 255, 0, 127));
    break;
  case 7:
    midinote = floor(map((r + g + b) / 3, 0, 255, 0, 127));
    break;
  case 8:
    midinote = noteconst; 
    break;
  }

  switch(veltype) { 
  case 0: 
    midivel = floor(map(H, 0, 255, 0, 127));    
    break;
  case 1:
    midivel = floor(map(S, 0, 255, 0, 127));  
    break;
  case 2:
    midivel = floor(map(B, 0, 255, 0, 127));  
    break;
  case 3:
    midivel = floor(map(r, 0, 255, 0, 127));  
    break;
  case 4:
    midivel = floor(map(g, 0, 255, 0, 127));  
    break;
  case 5:
    midivel = floor(map(b, 0, 255, 1, 127));  
    break;
  case 6:
    midivel = floor(map((H + S + B) / 3, 0, 255, 0, 127)); 
    break;
  case 7:
    midivel = floor(map((r + g + b) / 3, 0, 255, 0, 127)); 
    break;
  case 8:
    midivel = velconst;  
    break;
  }
}

void fileSelected(File selection) {

  if (selection != null) {
    String path = selection.getAbsolutePath();
    if (path.endsWith("jpg") || path.endsWith("jpeg") || path.endsWith("png") || path.endsWith("gif") || path.endsWith("tga") ) {
      imagetoMidi = loadImage(path);
      imgfolder = new File (path);
      redraw();
    }
  }
}

void info() {

  int x = mouseX;
  int y = mouseY - 100;

  textAlign(CORNER);
  rectMode(CENTER);
  fill(200, 100);
  rect(x + 20, y + 40, 135, 110, 10);
  fill(Col);
  rect(x - 10, y + 28, 40, 30);
  textSize(10);
  fill(255, 0, 0);
  text("R: "+(int)r, x + 30, y + 20);
  fill(0, 255, 0);
  text("G: "+(int)g, x + 30, y + 30);
  fill(0, 0, 255);
  text("B: "+(int)b, x + 30, y + 40);
  fill(20);
  text ("#"+hex(Col, 6), x + 30, y + 50);
  text ("H:"+(int)H, x + 30, y + 65);
  text ("S:"+(int)S, x + 30, y + 75);
  text ("B:"+(int)B, x + 30, y + 85);
  textSize(12);
  text ("ANY COLOR YOU LIKE", x - 43, y + 5);
  text ("   MIDI", x - 35, y + 60);
  text ("NOTE:"+midinote, x - 35, y + 75);
  text ("VEL:"+midivel, x - 35, y + 90);
  fill(200, 200, 200);
  text(freq[midinote] + "Hz", width / 2, 100);
}

void Mididisconnect()
{
  midiBus.stop();
  midiBus = null;
}

boolean midiOutL() 
{
  return  (mouseX > (width / 2) - 100 && mouseX < (width / 2) - 60 && mouseY > height - 35 && mouseY < height - 15);
}

boolean midiOutR() 
{
  return  (mouseX > (width / 2) + 60 && mouseX < (width / 2) + 100 && mouseY > height - 35 && mouseY < height - 15);
}

boolean imageArea() 
{
  return  (mouseX > 5 && mouseX < width - 5 && mouseY > 100 && mouseY <  height - 35);
}

boolean web() 
{
  return  (mouseX > width - 60 && mouseX < width && mouseY > 60 && mouseY <  100);
}

boolean virmidi_()
{
  return  (mouseX > width - 150 && mouseX < width && mouseY > height - 35 && mouseY < height - 20);
}