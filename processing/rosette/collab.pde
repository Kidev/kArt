/**
 * Rosace
 *
 * By Alexandre 'kidev' Poumaroux
 *
 * Thanks a lot to the whole PROCESSING.ORG team for their amazing work !
 * Visit www.processing.org to learn how to run this software.
 *
 * Joined pictures are licensed under CC BY-SA 4.0, see "data/LICENSE".
 *
 * Copyright (C) 2022 Alexandre 'kidev' Poumaroux
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


// CONFIG
int iOUTPUT_W = 1000;
int iOUTPUT_H = 1000;

String PICTURE_LOCATION = "data/test.jpeg";

int iFPS = 60;
int iSUPER_SCALE = 1;

int iTEXT_SIZE = 10;

float flROTATE_RATE = 0.5;

int iFRAMES_CALC = int(360.0 / flROTATE_RATE);


boolean SHOW_FPS = true;
int iRECORD_FRAMES = 0;//iFRAMES_CALC;
int iRECORD_FRAMES_HALF = iRECORD_FRAMES / 2;

int iSMOOTHING = 8;


// UTILS 
float flOUTPUT_W = float(iOUTPUT_W);
float flOUTPUT_H = float(iOUTPUT_H);

float flINPUT_W = 1080.0;
float flINPUT_H = 1079.0;
float flRESIZE_RATIO = flOUTPUT_W / flINPUT_W;

PImage PICTURE;
PImage DISPLAY_IMAGE;
PGraphics GRAPHICSA;
PGraphics GRAPHICSB;


void turnKnobs() {
  
}


void settings() {
  
  size(iOUTPUT_W * iSUPER_SCALE, iOUTPUT_H * iSUPER_SCALE, P2D);
  smooth(iSMOOTHING);
  
}


void setup() {
 //<>//
  turnKnobs(); //<>//
  
  print("cacl=" + iRECORD_FRAMES);
 //<>//
  imageMode(CENTER); //<>//
  textSize(iTEXT_SIZE * iSUPER_SCALE); //<>// //<>//
 //<>//
  PICTURE = loadImage(PICTURE_LOCATION); //<>//
  PICTURE.resize(round(flOUTPUT_W * 1.5), round(flOUTPUT_H * 1.5)); //<>//
  PICTURE.filter(BLUR, 1.0);
  PICTURE.loadPixels();
  
  DISPLAY_IMAGE = createImage(iOUTPUT_W, iOUTPUT_H, ARGB);
  
  DISPLAY_IMAGE.loadPixels();
  for (int x = 0; x < iOUTPUT_W; x++) {
        
    for (int y = 0; y < iOUTPUT_H; y++) {
      
      DISPLAY_IMAGE.pixels[x + (y * iOUTPUT_W)] = color(0, 0, 0, 255);
        
    }
  }
  DISPLAY_IMAGE.updatePixels();
  
  GRAPHICSA = createGraphics(iOUTPUT_W, iOUTPUT_H, P2D);
  GRAPHICSA.smooth(iSMOOTHING);
  GRAPHICSB = createGraphics(iOUTPUT_W, iOUTPUT_H, P2D);
  GRAPHICSB.smooth(iSMOOTHING);
                         
  frameRate(iFPS);
  
}

// 1 -> flROTATE_RATE * x = 360.0
// x = 360.0 / flROTATE_RATE
void draw() {
  
  turnKnobs();
  
  GRAPHICSA.beginDraw();
  GRAPHICSA.imageMode(CENTER);
  GRAPHICSA.background(0.0, 0.0, 0.0, 0.0);
  GRAPHICSA.pushMatrix();
  GRAPHICSA.translate(0.5 * iOUTPUT_W * iSUPER_SCALE, 0.5 * iOUTPUT_H * iSUPER_SCALE);
  GRAPHICSA.scale(1, 1);
  GRAPHICSA.rotate(radians(flROTATE_RATE * float(frameCount)));
  GRAPHICSA.image(PICTURE, 0, 0);
  GRAPHICSA.popMatrix();
  GRAPHICSA.loadPixels();
  GRAPHICSA.endDraw();
  
  GRAPHICSB.beginDraw();
  GRAPHICSB.imageMode(CENTER);
  GRAPHICSB.background(0.0, 0.0, 0.0, 0.0);
  GRAPHICSB.pushMatrix();
  GRAPHICSB.translate(0.5 * iOUTPUT_W * iSUPER_SCALE, 0.5 * iOUTPUT_H * iSUPER_SCALE);
  GRAPHICSB.scale(-1, 1);
  GRAPHICSB.rotate(radians(flROTATE_RATE * float(frameCount)));
  GRAPHICSB.image(PICTURE, 0, 0);
  GRAPHICSB.popMatrix();
  GRAPHICSB.loadPixels();
  GRAPHICSB.endDraw();
  
  DISPLAY_IMAGE.loadPixels();
  
  for (int x = 0; x < iOUTPUT_W; x++) {
        
    for (int y = 0; y < iOUTPUT_H; y++) {
                    
      color current_colorA = GRAPHICSA.pixels[x + (y * iOUTPUT_W)];
      color current_colorB = GRAPHICSB.pixels[x + (y * iOUTPUT_W)];
      //color mixed_color;
      
      //float p_rA = red(current_colorA);
      //float p_gA = green(current_colorA);
      //float p_bA = blue(current_colorA);
      float p_aA = alpha(current_colorA);
      
      //float p_rB = red(current_colorB);
      //float p_gB = green(current_colorB);
      //float p_bB = blue(current_colorB);
      float p_aB = alpha(current_colorB);
      
      float p_brightness = 0.0;
      float p_r = 0.0;
      float p_g = 0.0;
      float p_b = 0.0;
      float p_a = 0.0;
      
      float limit = 0.0;
      
      if (p_aA > limit || p_aB > limit) {
        
        p_r = 255.0;
        p_g = 255.0;
        p_b = 255.0;
        p_a = 255.0;
        
        //mixed_color = blendColor(current_colorA, current_colorB, BLEND);
        //p_r = red(mixed_color);
        //p_g = green(mixed_color);
        //p_b = blue(mixed_color);
        
        
        if (p_aA > limit && p_aB > limit) {
          
          p_brightness = 0.0;
          p_r = p_brightness;
          p_g = p_brightness;
          p_b = p_brightness;
          
          
        }
        
        DISPLAY_IMAGE.pixels[x + (y * iOUTPUT_W)] = color(p_r, p_g, p_b, p_a);
        
      } else {
        DISPLAY_IMAGE.pixels[x + (y * iOUTPUT_W)] = color(0, 0, 0, 255);
      }
        
    }
  }
  
  DISPLAY_IMAGE.updatePixels();
  
  if (iRECORD_FRAMES > 0) {
    
    iRECORD_FRAMES -= 1;
    
    DISPLAY_IMAGE.save("record/frame_" + nf(frameCount, 5) + ".png");
    
    println("Recorded frame #" + nf(frameCount, 5));
    
    /*
    if (iRECORD_FRAMES > 0 && frameCount > 1 && frameCount != (iRECORD_FRAMES_HALF + 1)) {
      DISPLAY_IMAGE.save("record/frame_" + nf((2 * iRECORD_FRAMES_HALF) - frameCount + 2, 5) + ".png");
      
      iRECORD_FRAMES -= 1;
      
      println("Recorded mirrored (of #" + frameCount + ") frame #" + nf((2 * iRECORD_FRAMES_HALF) - frameCount + 2, 5));
    }
    println(str(iRECORD_FRAMES) + " frames remaining.");
    */
    
  } else {
    
    image(DISPLAY_IMAGE, 0.5 * iOUTPUT_W * iSUPER_SCALE, 0.5 * iOUTPUT_H * iSUPER_SCALE);
  
    if (SHOW_FPS) {
            
      int txt_n = 1;
      
      fill(255, 0, 0);
      text("#" + str(frameCount), 0, (txt_n++) * iTEXT_SIZE * iSUPER_SCALE);
      text(round(frameRate) + " fps", 0, (txt_n++) * iTEXT_SIZE * iSUPER_SCALE);
      
      if (iSUPER_SCALE != 1) {
        text("! overscaled x" + str(iSUPER_SCALE), 0, (txt_n++) * iTEXT_SIZE * iSUPER_SCALE);
      }
      
    }
  }
 
}
