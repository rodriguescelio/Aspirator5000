#include <Arduino.h>
#include "Aspirator5000.h"

Aspirator5000 *aspirator5000;

void setup() {
  aspirator5000 = new Aspirator5000();
  aspirator5000->init();
}

void loop() {
  aspirator5000->loop();
}