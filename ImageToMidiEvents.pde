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

void  mouseReleased() {
  midiBus.sendNoteOff(midichannel, midiprevnote, 0);
  redraw();
}

void  mousePressed() {

  if (web() == true) {
    if (mouseButton == LEFT) {
      link("https://github.com/eLeDeTe-LoDeTanda/ImageToMidi");
    }
  }

  if (midiOutR() == true) {
    if (mouseButton == LEFT) {
      if (midiout_list_index < (num_midiout_ports - 1)) {

        midiout_list_index++;
        midiout_list = MidiBus.availableOutputs()[midiout_list_index];
      } else { 
        midiout_list_index = 0;
        midiout_list = MidiBus.availableOutputs()[midiin_list_index];
      }
    }
    midiBus = new MidiBus(this, MidiBus.availableInputs()[midiin_list_index], MidiBus.availableOutputs()[midiout_list_index]);
    redraw();
  }
  if (midiOutL()==true) {
    if (mouseButton == LEFT) {
      if (midiout_list_index > 0) {
        midiout_list_index--;
        midiout_list = MidiBus.availableOutputs()[midiout_list_index];
      } else { 
        midiout_list_index = num_midiout_ports;
        midiout_list = MidiBus.availableOutputs()[midiin_list_index];
      }
    }
    midiBus = new MidiBus(this, MidiBus.availableInputs()[midiin_list_index], MidiBus.availableOutputs()[midiout_list_index]);
    redraw();
  }
  if (imageArea() == true) {
    if (mouseButton == LEFT) {
      colorToMidi();
      noteon = true;
      midiprevnote = midinote;
      midiBus.sendNoteOn(midichannel, midiprevnote, midivel);
      redraw();
    }
    if (mouseButton == RIGHT) selectInput("Select an image:", "fileSelected", imgfolder);
    if (mouseButton == CENTER) midiBus.sendControllerChange(midichannel, 123, 123);
    redraw();
  }
  if (os == "LINUX") {
    if (virmidi_()) {
      if (mouseButton == LEFT) {
        String cmd[] = {"xterm", "-e", "sudo", "modprobe", "snd-virmidi"};
        exec(cmd);
      }
    }
  }
}

void mouseDragged() 
{
  if (imageArea() == true) {
    delay(20);
    noteon = true;
    midiBus.sendNoteOff(midichannel, midiprevnote, 0);
    midiprevnote = midinote;
    midiBus.sendNoteOn(midichannel, midiprevnote, midivel);
    colorToMidi();
    redraw();
  }
}

int e;
void mouseWheel(MouseEvent event) {
  e = constrain(e + event.getCount() * 5, 0, 127);
  midiBus.sendControllerChange(midichannel, 1, e);
  noteon = true;
  redraw();
}

void keyPressed()
{
  if (imageArea() == true) {
    colorToMidi();

    if (keyPressed) {
      if (!keyon) {
        keyon = true;
        noteon = true;
        midiprevnote = midinote;
        midiBus.sendNoteOn(midichannel, midiprevnote, midivel);
        redraw();
      }
      switch(key) {
        case('1'):
        notetype = 0;
        ntype = "Hue";
        break;
        case('2'):
        notetype = 1;
        ntype = "Saturation";
        break;
        case('3'):
        notetype = 2;
        ntype = "Brightness";
        break;
        case('4'):  
        notetype = 3;
        ntype = "Red";
        break;
        case('5'):
        notetype = 4;
        ntype = "Green";
        break;
        case('6'):  
        notetype = 5;
        ntype = "Blue";
        break;
        case('7'):
        notetype = 6;
        ntype = "HSB";
        break;
        case('8'):
        notetype = 7;
        ntype = "RGB";
        break;
        case('9'):
        notetype = 8;
        ntype = "Constant";
        break;
        case('q'):
        veltype = 0;
        vtype = "Hue";
        break;
        case('w'):
        veltype = 1;
        vtype = "Saturation";
        break;
        case('e'):
        veltype = 2;
        vtype = "Brightness";
        break;
        case('r'):  
        veltype = 3;
        vtype = "Red";
        break;
        case('t'):
        veltype = 4;
        vtype = "Green";
        break;
        case('y'):  
        veltype = 5;
        vtype = "Blue";
        break;
        case('u'):
        veltype = 6;
        vtype = "HSB";
        break;
        case('i'):
        veltype = 7;
        vtype = "RGB";
        break;
        case('o'):
        veltype = 8;
        vtype = "Constant";
        break;
      }
    }
  }
}

void keyReleased()
{
  midiBus.sendNoteOff(midichannel, midiprevnote, 0);
  keyon = false;
}