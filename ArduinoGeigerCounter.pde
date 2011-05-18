/*
 * Project: Arduino Geiger Counter
 * File name: ArduinoGeigerCounter.pde
 * Description: This code uses ATmega interrupts to count pulses coming from
 *              a Geiger tube, and uses a 1000 ms time base to make
 *              calculations and output data to the user.
 * Author: Francesco Gugliuzza <jackthevendicator@gmail.com>, Copyright (C) 2011.
 */

/* 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
/* Signal coming to the Geiger board must be connected to an interrupt pin */
#define GEIGER_PIN 2
#define GEIGER_INTERRUPT 0

/* Variables accessed by interrupt handlers must be volatile */
volatile unsigned int pulseCount;
unsigned long endMillis;

void countPulse() {
  pulseCount++;
}

inline unsigned int getCount() {
  unsigned int pulseCountTmp;
  
  /*
   * Disable interrupts to make sure we access critical section
   * exclusively
   */
  noInterrupts();
  pulseCountTmp = pulseCount;
  interrupts();
  return pulseCountTmp;
}

inline void resetCount() {
  /*
   * Disable interrupts to make sure we access critical section
   * exclusively
   */
  noInterrupts();
  pulseCount = 0;
  interrupts();
}

void setup() {
  pinMode(GEIGER_PIN, INPUT);
  attachInterrupt(GEIGER_INTERRUPT, countPulse, RISING);
  Serial.begin(115200);
}

void loop() {
  /*
   * Try to auto-compensate incremental error. We ignore error caused by
   * interrupts, though.
   */
  endMillis = millis() + 1000;
  resetCount();
  
  /* Just busy wait */
  while(millis() < endMillis);
  Serial.print("Got ");
  Serial.print(getCount());
  Serial.println(" pulses from the Geiger tube.");
}
