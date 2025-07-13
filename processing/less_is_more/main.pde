/**
 * Something less is something more
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


/* CONSTANTS */
int iOUTPUT_W = 1000;
int iOUTPUT_H = 1079;

int iBORDERS_W = 0;
int iBORDERS_H = iOUTPUT_H;

String BACKGROUND_FILE = "data/background.png";
String SILOUHETTE_FILE = "data/silouhette.png";
String SILOUHETTE2_FILE = "data/silouhette2.png";

int iFPS = 30;
int iTEXT_SIZE = 20;

boolean SHOW_FPS = false;
boolean DO_RECORD = false;

int iSMOOTHING = 2;

int iMAX_STEPS = 200;
float flTIME_SPEED = 0.03;
float flTIME_BRIGHTNESS_SPEED = 0.3;

float flX_MULT_ABOVE = 1.0;
float flX_MULT_BELOW = 1.0;
float flY_MULT_ABOVE = -0.15;
float flY_MULT_BELOW = -0.09;


float EASING_K = 2.0;
float EASING_S = 8.0;


/* DEDUCED CONSTANTS */
float flOUTPUT_W = float(iOUTPUT_W);
float flOUTPUT_H = float(iOUTPUT_H);

PImage BACKGROUND;
PImage SILOUHETTE;
PImage SILOUHETTE2;


/* GLOBALS */
int iTimeCount = 0;
boolean bStopAnimation = false;
boolean bRecording = false;
boolean bRecordingStarted = false;
boolean bWaitingForZero = false;
boolean bPassedOne = false;
int iFrameNumber = 0;
float flPreviousOscillator = -1.0;
String RECORD_FOLDER = "record/";


/* ANIMATIONS */
float easing_animation(float progress) {

  if (progress < 0.0 || progress > 1.0) {
    throw new IllegalArgumentException("Argument 'progress' is outside the [0, 1] interval");
  }

  if (progress <= 0.5) {
    return (1.0 / EASING_K) * exp(-EASING_S * pow(((EASING_K * progress) - 1.0), 4));
  }

  return (1.0 / EASING_K) * (exp(-EASING_S * pow((EASING_K * (1.0 - progress)), 4)) + 1.0);

}


void mousePressed() {
  if (bStopAnimation) {
    loop();
  } else {
    noLoop();
  }
  bStopAnimation = !bStopAnimation;
}


void turnKnobs() {
  iMAX_STEPS = 200;
  flTIME_SPEED = 0.01;
  flTIME_BRIGHTNESS_SPEED = 30.00;
  flX_MULT_ABOVE = 1.00;
  flX_MULT_BELOW = 1.00;
  flY_MULT_ABOVE = -0.15;
  flY_MULT_BELOW = -0.09;
}


void settings() {

  size(iOUTPUT_W, iOUTPUT_H, P2D);
  smooth(iSMOOTHING);

}


void setup() {

  frameRate(iFPS);
  imageMode(CORNER);
  textSize(iTEXT_SIZE);

  turnKnobs();

  BACKGROUND = loadImage(BACKGROUND_FILE);
  SILOUHETTE = loadImage(SILOUHETTE_FILE);
  SILOUHETTE2 = loadImage(SILOUHETTE2_FILE);

  BACKGROUND.resize(iOUTPUT_W, iOUTPUT_H);
  SILOUHETTE.resize(iOUTPUT_W, iOUTPUT_H);
  SILOUHETTE2.resize(iOUTPUT_W, iOUTPUT_H);

  background(BACKGROUND);

  // Initialize recording state
  bWaitingForZero = true;
  flPreviousOscillator = -1.0;

  // Create the record folder if it doesn't exist
  File recordDir = new File(sketchPath(RECORD_FOLDER));
  if (!recordDir.exists()) {
    recordDir.mkdir();
  }

}


void draw() {

  turnKnobs();

  float gen_oscillator = 0.5 * (sin(flTIME_SPEED * frameCount) + 1);
  float time = easing_animation(gen_oscillator);
  float gen_oscillator_brightness = 0.0;
  float time_brightness = 0.0;

  int brightness = 0;
  float step_progress = 0.0;
  float step_progress_inv = 0.0;

  float mid_farness = (2.0 * abs(0.5 - time));

  float Y_multiplier = 1.0;
  float X_multiplier = 1.0;

  // Handle recording logic
  if (flPreviousOscillator != -1.0) {
    // Detect when we cross from >0 to 0 (initial trigger)
    if (bWaitingForZero && flPreviousOscillator > 0.001 && gen_oscillator <= 0.001) {
      bWaitingForZero = false;
      bRecording = true;
      bPassedOne = false;
      iFrameNumber = 0;
      println("Recording started at gen_oscillator = " + gen_oscillator);
    }

    // Detect when we pass through 1 (halfway point)
    if (bRecording && !bPassedOne && gen_oscillator >= 0.999) {
      bPassedOne = true;
      println("Passed through 1 at frame " + iFrameNumber + ", gen_oscillator = " + gen_oscillator);
    }

    // Detect when we return to 0 (end of full cycle)
    if (bRecording && bPassedOne && flPreviousOscillator > 0.001 && gen_oscillator <= 0.001) {
      println("Full cycle completed at gen_oscillator = " + gen_oscillator);
      // We'll stop recording after saving this frame
    }
  }

  // Above
  if (gen_oscillator <= 0.5) {
    iTimeCount -= 1;
    Y_multiplier = flY_MULT_ABOVE;
    X_multiplier = flX_MULT_ABOVE;
  }
  // Below
  else {
    iTimeCount += 1;
    Y_multiplier = flY_MULT_BELOW;
    X_multiplier = flX_MULT_BELOW;
  }

  // Draws background
  image(BACKGROUND, 0, 0);
  image(SILOUHETTE2, 0, 0);

  // Draws black and white effect
  for (int step = 0; step <= iMAX_STEPS; step++) {

    step_progress = float(step) / float(iMAX_STEPS);
    step_progress_inv = (1.0 - step_progress);

    gen_oscillator_brightness = 0.5 * (sin(flTIME_BRIGHTNESS_SPEED * (-frameCount + step)) + 1.0);
    time_brightness = easing_animation(gen_oscillator_brightness);

    brightness = round(time_brightness * 255.0);

    if (step > 0) {
      tint(brightness, brightness, brightness, min(float(step), 255.0));
      image(SILOUHETTE,
          round(time * X_multiplier * flOUTPUT_W * step_progress),
          round((0.65 + (Y_multiplier * mid_farness)) * flOUTPUT_H * step_progress),
          round(flOUTPUT_W * step_progress_inv),
          round(flOUTPUT_H * step_progress_inv));
    }
  }

  noTint();

  // Draws background over it so it seems that the effect is behind
  if (gen_oscillator >= 0.5) {
    image(BACKGROUND, 0, 0);
  }

  // Draws frame count
  if (SHOW_FPS) {
    int text_pos = 1;
    fill(255, 0, 0);
    text(str(frameCount), 0, text_pos++ * iTEXT_SIZE);
    text(str(int(frameRate)) + "fps", 0, text_pos++ * iTEXT_SIZE);
    text("g+1=" + nf(gen_oscillator, 1, 3), 0, text_pos++ * iTEXT_SIZE);
    text("t+1=" + nf(time, 1, 3), 0, text_pos++ * iTEXT_SIZE);
    text("t-1=" + nf(time_brightness, 1, 3), 0, text_pos++ * iTEXT_SIZE);
    text("g-1=" + nf(gen_oscillator_brightness, 1, 3), 0, text_pos++ * iTEXT_SIZE);
  }

  // Save frame if recording
  if (bRecording) {
    String filename = RECORD_FOLDER + "frame_" + nf(iFrameNumber, 3) + ".png";
    saveFrame(filename);
    println("Saved: " + filename + " (gen_oscillator = " + gen_oscillator + ")");
    iFrameNumber++;

    // Stop recording after we return to 0 (full cycle)
    if (bPassedOne && flPreviousOscillator > 0.001 && gen_oscillator <= 0.001) {
      bRecording = false;
      bRecordingStarted = true;
      println("Recording completed. Total frames: " + iFrameNumber);
      println("Full cycle: 0 -> 1 -> 0");
    }
  }

  // Store the previous oscillator value if record is enabled
  if (DO_RECORD) {
    flPreviousOscillator = gen_oscillator;
  }

}
