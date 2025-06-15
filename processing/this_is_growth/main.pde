/**
 * This is growth
 *
 * By Alexandre 'kidev' Poumaroux
 *
 * Thanks a lot to the whole PROCESSING.ORG team for their amazing work !
 * Visit www.processing.org to learn how to run this software.
 *
 * Joined pictures are licensed under CC BY-SA 4.0, see "data/LICENSE".
 *
 * Copyright (C) 2025 Alexandre 'kidev' Poumaroux
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

float[] stockPrices;
int totalPoints;
float currentPrice;
float drawingWidth;
float currentPointX;

void setup() {
  size(1200, 600);
  
  // Calculate drawing area (3/4 of screen width)
  drawingWidth = width * 0.75;
  currentPointX = drawingWidth; // Fixed position for current point
  totalPoints = (int)drawingWidth;
  
  // Initialize stock prices array
  stockPrices = new float[totalPoints];
  
  // Start in middle range for zoomed effect
  currentPrice = height * 0.5;
  
  // Fill initial array with starting price
  for (int i = 0; i < totalPoints; i++) {
    stockPrices[i] = currentPrice;
  }
  
  background(20);
}

void draw() {
  background(20);
  
  // Add multiple data points per frame for faster animation
  addNewDataPoint();
  addNewDataPoint();
  
  drawStockCurve();
  drawCurrentPoint();
}

void addNewDataPoint() {
  // Shift all data points to the left
  for (int i = 0; i < totalPoints - 1; i++) {
    stockPrices[i] = stockPrices[i + 1];
  }
  
  // High volatility - 40% of screen height
  float maxVolatility = height * 23.1;
  float volatility = random(-maxVolatility/2, maxVolatility/2);
  
  // Simple random walk with high volatility
  currentPrice += volatility * 0.03; // Scale down for smoother movement
  
  // Add occasional market events
  if (random(100) < 0) {
    currentPrice += random(-maxVolatility * 0.2, maxVolatility * 0.3);
  }
  
  // Keep price within bounds
  if (currentPrice < height * 0.2) {
    currentPrice = height * 0.2 + random(50);
  }
  if (currentPrice > height * 0.8) {
    currentPrice = height * 0.8 - random(50);
  }
  
  // Add new price at the end
  stockPrices[totalPoints - 1] = currentPrice;
}

void drawStockCurve() {
  stroke(255, 100, 100); // Red color for declining stock
  strokeWeight(2);
  noFill();
  
  // Calculate tilt amount for dramatic decline effect
  float tiltAmount = height * 0.6; // Total tilt across screen
  
  beginShape();
  for (int i = 0; i < totalPoints; i++) {
    float x = map(i, 0, totalPoints - 1, 0, drawingWidth);
    
    // Apply tilt: left side goes up, right side goes down
    float tiltOffset = map(i, 0, totalPoints - 1, -tiltAmount/2, tiltAmount/2);
    float y = stockPrices[i] + tiltOffset;
    
    vertex(x, y);
  }
  endShape();
}

void drawCurrentPoint() {
  // Apply same tilt to current point
  float tiltAmount = height * 0.6;
  float tiltOffset = map(totalPoints - 1, 0, totalPoints - 1, -tiltAmount/2, tiltAmount/2);
  float adjustedCurrentPrice = currentPrice + tiltOffset;
  
  // Highlight the current point at 3/4 position
  stroke(255, 200, 200);
  strokeWeight(8);
  point(currentPointX, adjustedCurrentPrice);
  
  // Add a subtle glow effect
  stroke(255, 100, 100, 100);
  strokeWeight(8);
  point(currentPointX, adjustedCurrentPrice);
  
  // Draw vertical line to show 3/4 boundary
  stroke(80, 80, 80);
  strokeWeight(1);
  line(currentPointX, 0, currentPointX, height);
}

void keyPressed() {
  if (key == ' ') {
    // Reset to starting position
    currentPrice = height * 0.5;
    for (int i = 0; i < totalPoints; i++) {
      stockPrices[i] = currentPrice;
    }
  }
  
  if (key == 'r' || key == 'R') {
    // Randomize starting position
    currentPrice = random(height * 0.3, height * 0.7);
    for (int i = 0; i < totalPoints; i++) {
      stockPrices[i] = currentPrice;
    }
  }
}
