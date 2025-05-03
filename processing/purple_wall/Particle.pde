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
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;
  PImage img;
  PGraphics dest;

  Particle(PVector l, PImage img_, PGraphics dest_) {
    acc = new PVector(0, 0);
    float vx = randomGaussian()*0.1;
    float vy = randomGaussian()*0.1 - 1.1;
    vel = new PVector(vx, vy);
    loc = l.copy();
    lifespan = 1.0;
    img = img_;
    dest = dest_;
  }

  void run() {
    update();
    render();
  }
 
  void dry_run() {
    update();
  }

  // Method to apply a force vector to the Particle object
  // Note we are ignoring "mass" here
  void applyForce(PVector f) {
    acc.add(f);
  }  

  void update() {
    vel.add(acc);
    loc.add(vel);
    lifespan -= 0.025;
    acc.mult(0); // clear Acceleration
  }
  
  color fire[] = {
    color(128.0 / 255.0,   17.0 / 255.0,   0, 0.8),
    color(182.0 / 255.0,   34.0 / 255.0,   0, 0.8),
    color(215.0,           53.0 / 255.0,   0, 0.8),
    color(252.0 / 255.0,   100.0 / 255.0,   0, 0.8),
    color(255.0 / 255.0,   117.0 / 255.0,   0, 0.8),
    color(250.0 / 255.0,   192.0 / 255.0,   0, 0.8)
  };
  
  color lifespan_color() {
    if (this.lifespan >= (1.0 - 0.025)) {
      return fire[int(random(fire.length))];
    }
    float rand = random(0.2, 1.0);
    return color(rand, rand, rand, 1.0 * this.lifespan);
  }

  void render() {
    dest.tint(lifespan_color());
    dest.image(img, loc.x, loc.y);
  }

  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
