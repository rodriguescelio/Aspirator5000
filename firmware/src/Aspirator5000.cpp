#include <Arduino.h>
#include <BLE2902.h>
#include <iostream>

#include "Aspirator5000.h"

void Aspirator5000::init() {
  Serial.begin(115200);

  for (int i = 0; i < sizeof(outputPins); i++) {
    pinMode(outputPins[i], OUTPUT);
  }

  BLEDevice::init("Aspirator 5000");

  server = BLEDevice::createServer();
  server->setCallbacks(this);

  service = server->createService(UUID_SERVICE);

  characteristic = service->createCharacteristic(UUID_CHANNEL, BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_WRITE);
  characteristic->addDescriptor(new BLE2902());
  characteristic->setCallbacks(this);

  service->start();
  advertise();
}

void Aspirator5000::advertise() {
  digitalWrite(LED_GREEN, LOW);
  server->getAdvertising()->start();
  Serial.println("Esperando um cliente se conectar...");
}

void Aspirator5000::resetHardwareState() {
  for (int i = 0; i < sizeof(motorPins); i++) {
    digitalWrite(motorPins[i], LOW);
  }
}

void Aspirator5000::loop() {
  if (deviceConnected) {
    characteristic->setValue("ACK");
    characteristic->notify();
    Serial.println("ACK");
  }
  delay(2000);
}

void Aspirator5000::onConnect(BLEServer* pServer) {
  deviceConnected = true;
  digitalWrite(LED_GREEN, HIGH);
}

void Aspirator5000::onDisconnect(BLEServer* pServer) {
  deviceConnected = false;
  Serial.println("Cliente desconectado");
  advertise();
}

void Aspirator5000::onWrite(BLECharacteristic *pCharacteristic) {
  resetHardwareState();

  std::string value = pCharacteristic->getValue();

  if (value.length() > 0) {
    if (value == "+L") {
      digitalWrite(MOTOR_RIGHT_FORWARD, HIGH);
    } else if (value == "+LF") {
      digitalWrite(MOTOR_RIGHT_FORWARD, HIGH);
      digitalWrite(MOTOR_LEFT_BACKWARD, HIGH);
    } else if (value == "+R") {
      digitalWrite(MOTOR_LEFT_FORWARD, HIGH);
    } else if (value == "+RF") {
      digitalWrite(MOTOR_LEFT_FORWARD, HIGH);
      digitalWrite(MOTOR_RIGHT_BACKWARD, HIGH);
    } else if (value == "+U") {
      digitalWrite(MOTOR_LEFT_FORWARD, HIGH);
      digitalWrite(MOTOR_RIGHT_FORWARD, HIGH);
    } else if (value == "+D") {
      digitalWrite(MOTOR_LEFT_BACKWARD, HIGH);
      digitalWrite(MOTOR_RIGHT_BACKWARD, HIGH);
    }

    Serial.print("Valor: ");
    for (int i = 0; i < value.length(); i++) {
      Serial.print(value[i]);
    }
    Serial.println();
  }
}