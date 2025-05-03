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

class ParticleSystem {

  ArrayList<Particle> particles;    // An arraylist for all the particles
  PVector origin;                   // An origin point for where particles are birthed
  PImage img;
  PGraphics dest;

  ParticleSystem(int num, PVector v, PImage img_, PGraphics dest_) {
    particles = new ArrayList<Particle>();              // Initialize the arraylist
    origin = v.copy();                                   // Store the origin point
    img = img_;
    dest = dest_;
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin, img, dest));         // Add "num" amount of particles to the arraylist
    }
  }
  
  void dry_run() {
    for (int i = 0; i < particles.size(); i++) {
      Particle p = particles.get(i);
      p.dry_run();
    }
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  void run() {
    dest.beginDraw();
    dest.background(0);
    for (int i = 0; i < particles.size(); i++) {
      Particle p = particles.get(i);
      p.run();
    }
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      if (p.isDead()) {
        particles.remove(i);
      }
    }
    dest.endDraw();
  }

  // Method to add a force vector to all particles currently in the system
  void applyForce(PVector dir) {
    // Enhanced loop!!!
    for (Particle p : particles) {
      p.applyForce(dir);
    }
  }  

  void addParticle() {
    particles.add(new Particle(origin, img, dest));
  }
  
  PGraphics getRender() {
    return dest;
  }
}
