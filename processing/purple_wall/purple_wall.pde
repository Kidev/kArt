/**
 * Purple sky fading into concrete void
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

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.

 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


// CONFIG
int iOUTPUT_W = 1000;
int iOUTPUT_H = 1000;

String PICTURE_LOCATION = "data/F.png";
String SMOKE_TEXTURE_LOCATION = "data/texture.png";

int iFPS = 30;
int iSUPER_SCALE = 1;

int iTEXT_SIZE = 10;

float flSMOKE_X = 1085.0;
float flSMOKE_Y = 472.0;
float flSMOKE_RESIZE_X = 20.0;
float flSMOKE_RESIZE_Y = 30.0;
float flSMOKE_WIND_X = 2.0;
float flSMOKE_WIND_Y = -2.5;
int iPARTICLES_PERFRAME = 20;
int iSMOKE_BLEND_MODE = LIGHTEST;

int iNOISE_PERIOD = 180;
int iNOISE_HALF_PERIOD = 90;

int iSMOKE_PARTICLES_HEAT_UP_FRAMES = 60;

int iBLUR_AMOUNT = 0;
int iBLUR_AMOUNT_SETUP = 1;
int iBLUR_AMOUNT_SMOKE = 1;

boolean SHOW_FPS = true;
int iRECORD_FRAMES = 0;//1026;
int iRECORD_FRAMES_HALF = iRECORD_FRAMES / 2;

int iSMOOTHING = 2;


int iLOD = 4;
float flFALLOFF = 0.05;
float flNOISE_INCREMENT = 0.03;
float flTIME_INCREMENT = 0.06;
float flNOISE_SCALE = 0.5;


// UTILS 
float flOUTPUT_W = float(iOUTPUT_W);
float flOUTPUT_H = float(iOUTPUT_H);

float flINPUT_W = 2850.0;
float flINPUT_H = 2850.0;
float flRESIZE_RATIO = flOUTPUT_W / flINPUT_W;

PImage PICTURE;
PImage DISPLAY_IMAGE;
PGraphics GRAPHICS;

PImage SMOKE_TEXTURE;

PVector SMOKE_WIND = new PVector(0, 0);
PVector SMOKE_ORIGIN = new PVector(0, 0);

ParticleSystem PARTICLES_SYS = null;

int iPRELOAD_FRAMES = 1 * iFPS;
ArrayList<FloatList> NOISE_ALL = new ArrayList<FloatList>(iPRELOAD_FRAMES + iFPS);
int iNOISE_CURRENT_LAST_FRAME = 0;


void turnKnobs() {
    
  iLOD = 4;
  flFALLOFF = 0.555;
  flNOISE_INCREMENT = 0.015;
  flTIME_INCREMENT = 0.005; // 0.1 0.05 
  flNOISE_SCALE = 1.750;
  
  iBLUR_AMOUNT = 0;
  iBLUR_AMOUNT_SETUP = 2;
  
  flSMOKE_X = 1090.0;
  flSMOKE_Y = 480.0;
  flSMOKE_RESIZE_X = 14.9;
  flSMOKE_RESIZE_Y = 14.5;
  flSMOKE_WIND_X = 0.6;
  flSMOKE_WIND_Y = -0.7;
  iPARTICLES_PERFRAME = 10;
  
  SMOKE_WIND.set(flSMOKE_WIND_X * flRESIZE_RATIO, flSMOKE_WIND_Y * flRESIZE_RATIO);
  SMOKE_ORIGIN.set(round(flSMOKE_X * flRESIZE_RATIO), round(flSMOKE_Y * flRESIZE_RATIO));
  
  if (PARTICLES_SYS != null) {
    PARTICLES_SYS.origin.set(SMOKE_ORIGIN);
  }

  noiseDetail(iLOD, flFALLOFF);
  
}


void precomputeNoise() {
    
  FloatList noiseList = new FloatList(int(0.5 * float(iOUTPUT_W * iOUTPUT_H)) + iOUTPUT_W);
  
  for (int x = 0; x < iOUTPUT_W; x++) {
  
    for (int y = 0; y <= x + 1 && y < iOUTPUT_H; y++) {         
        
      noiseList.append(
        pow(noise(x * flNOISE_INCREMENT, y * flNOISE_INCREMENT, iNOISE_CURRENT_LAST_FRAME * flTIME_INCREMENT)
            * 1.2 /*pow(map(dist(x, y, 0.7 * iOUTPUT_W, 0.4 * iOUTPUT_H), 0.0, 1.0 * iOUTPUT_H, 0.000, 1.0), 2))*/, 2));
    
    }
  
  }
  
  NOISE_ALL.add(noiseList);
  
  iNOISE_CURRENT_LAST_FRAME++;
  
}


float timeForFrame(int frame) {
  return 1 + abs(((frame + (iNOISE_HALF_PERIOD - 2)) % (iNOISE_PERIOD - 2)) - (iNOISE_HALF_PERIOD - 1));
}


void settings() {
  
  size(iOUTPUT_W * iSUPER_SCALE, iOUTPUT_H * iSUPER_SCALE, P2D);
  smooth(iSMOOTHING);
  
}


void setup() {
 //<>// //<>// //<>//
  turnKnobs(); //<>// //<>// //<>//
 //<>// //<>// //<>//
  imageMode(CORNER); //<>// //<>// //<>//
  colorMode(RGB, 1.0); //<>// //<>// //<>//
  textSize(iTEXT_SIZE * iSUPER_SCALE); //<>// //<>// //<>//
  noiseSeed(0);
  randomSeed(0); //<>// //<>// //<>//
  noiseDetail(iLOD, flFALLOFF); //<>// //<>// //<>//
 //<>// //<>// //<>//
  SMOKE_TEXTURE = loadImage(SMOKE_TEXTURE_LOCATION); //<>// //<>// //<>//
  SMOKE_TEXTURE.filter(BLUR, iBLUR_AMOUNT_SMOKE); //<>// //<>// //<>//
 //<>// //<>// //<>//
  PICTURE = loadImage(PICTURE_LOCATION); //<>// //<>// //<>//
   //<>// //<>// //<>//
  PICTURE.filter(BLUR, iBLUR_AMOUNT_SETUP); //<>// //<>// //<>//
   //<>// //<>// //<>//
  PICTURE.resize(iOUTPUT_W, iOUTPUT_H); //<>// //<>// //<>//
       //<>// //<>// //<>//
  //PICTURE.filter(BLUR, iBLUR_AMOUNT_SETUP);
  
  PICTURE.loadPixels();
  
  DISPLAY_IMAGE = createImage(iOUTPUT_W, iOUTPUT_H, RGB);
  DISPLAY_IMAGE.copy(PICTURE, 0, 0, iOUTPUT_W, iOUTPUT_H, 0, 0, iOUTPUT_W, iOUTPUT_H);
  
  DISPLAY_IMAGE.loadPixels();
  
  GRAPHICS = createGraphics(iOUTPUT_W, iOUTPUT_H, P2D);

  SMOKE_TEXTURE.resize(round(flSMOKE_RESIZE_X * flRESIZE_RATIO), round(flSMOKE_RESIZE_Y * flRESIZE_RATIO));
  PARTICLES_SYS =
    new ParticleSystem(0,
                       SMOKE_ORIGIN,
                       SMOKE_TEXTURE,
                       GRAPHICS);
                     
  GRAPHICS.loadPixels();
  
  for (int k = 0; k < iSMOKE_PARTICLES_HEAT_UP_FRAMES; k++) {
    PARTICLES_SYS.applyForce(SMOKE_WIND);
    PARTICLES_SYS.dry_run();
    for (int i = 0; i < iPARTICLES_PERFRAME; i++) {
      PARTICLES_SYS.addParticle();
    }  
  }
  
  GRAPHICS.loadPixels();
  
  for (int i = 0; i < iPRELOAD_FRAMES; i++) {
    precomputeNoise();
  }
  
  if (iPRELOAD_FRAMES > 0) {
    thread("precomputeNoise");
  }
                         
  frameRate(iFPS);
  
}


void draw() {
  
  turnKnobs();
  
  if (iPRELOAD_FRAMES > 0) {
    thread("precomputeNoise");
  }
  
  if (iNOISE_CURRENT_LAST_FRAME - frameCount <= 0) {
    println("No noise available, too fast!");
    exit();
  }
  
  if (frameCount % 6 == 1) {
    imageMode(CENTER);
    PARTICLES_SYS.applyForce(SMOKE_WIND);
    PARTICLES_SYS.run();
    for (int i = 0; i < iPARTICLES_PERFRAME; i++) {
        PARTICLES_SYS.addParticle();
    } 
    imageMode(CORNER);
    GRAPHICS.loadPixels();
  }
  
  FloatList frame_noise = NOISE_ALL.get(0);
  NOISE_ALL.remove(0);
  
  int noise_id = 0;
  
  for (int x = 0; x < iOUTPUT_W; x++) {
        
    for (int y = 0; y <= x + 1 && y < iOUTPUT_H; y++) {
                    
      color current_color = PICTURE.pixels[x + (y * iOUTPUT_W)];
      color current_effect = GRAPHICS.pixels[x + (y * iOUTPUT_W)];
      
      current_color = blendColor(current_color, current_effect, iSMOKE_BLEND_MODE);
      
      float noise_xyz = frame_noise.get(noise_id++) * flNOISE_SCALE;
      
      float p_r = min(max(red(current_color) * noise_xyz, 0.0), 1.0);
      float p_g = min(max(green(current_color) * noise_xyz, 0.0), 1.0);
      float p_b = min(max(blue(current_color) * noise_xyz, 0.0), 1.0);
      
      DISPLAY_IMAGE.pixels[x + (y * iOUTPUT_W)] = color(p_r, p_g, p_b);
        
    }
  }
  
  DISPLAY_IMAGE.updatePixels();
  if (iBLUR_AMOUNT != 0) {
    DISPLAY_IMAGE.filter(BLUR, iBLUR_AMOUNT);
  }
  
  if (iRECORD_FRAMES > 0) {
    
    iRECORD_FRAMES -= 1;
    
    DISPLAY_IMAGE.save("record/frame_" + nf(frameCount, 5) + ".png");
    
    println("Recorded frame #" + nf(frameCount, 5));
    
    if (iRECORD_FRAMES > 0 && frameCount > 1 && frameCount != (iRECORD_FRAMES_HALF + 1)) {
      DISPLAY_IMAGE.save("record/frame_" + nf((2 * iRECORD_FRAMES_HALF) - frameCount + 2, 5) + ".png");
      
      iRECORD_FRAMES -= 1;
      
      println("Recorded mirrored (of #" + frameCount + ") frame #" + nf((2 * iRECORD_FRAMES_HALF) - frameCount + 2, 5));
    }
    println(str(iRECORD_FRAMES) + " frames remaining.");
    
    
  } else {
    
    image(DISPLAY_IMAGE, 0, 0, iOUTPUT_W * iSUPER_SCALE, iOUTPUT_H * iSUPER_SCALE);
  
    // Draws frame count
    if (SHOW_FPS) {
      
      int txt_n = 1;
      
      fill(1, 0, 0);
      text("#" + str(frameCount), 0, (txt_n++) * iTEXT_SIZE * iSUPER_SCALE);
      text("t=" + str(int(timeForFrame(frameCount))), 0, (txt_n++) * iTEXT_SIZE * iSUPER_SCALE);
      text(round(frameRate) + " fps", 0, (txt_n++) * iTEXT_SIZE * iSUPER_SCALE);
      
      if (iSUPER_SCALE != 1) {
        text("! overscaled x" + str(iSUPER_SCALE), 0, (txt_n++) * iTEXT_SIZE * iSUPER_SCALE);
      }
      if (iPRELOAD_FRAMES > 0) {
        text("pre=" + str(iNOISE_CURRENT_LAST_FRAME - frameCount), 0, (txt_n++) * iTEXT_SIZE * iSUPER_SCALE);
      }
    }
  }
 
}
