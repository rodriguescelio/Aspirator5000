#include <BLEDevice.h>

#ifndef ASPIRATOR_5000_H
#define ASPIRATOR_5000_H

#define UUID_SERVICE   "5cb7ea7e-ed9f-42e7-807e-51ffa3b6b5fb"
#define UUID_CHANNEL   "fc77b5bf-e5ce-481f-a607-7f389d185950"

#define LED_GREEN            22
#define LED_RED              23
#define MOTOR_LEFT_FORWARD   14
#define MOTOR_LEFT_BACKWARD  12
#define MOTOR_RIGHT_FORWARD  32
#define MOTOR_RIGHT_BACKWARD 33

class Aspirator5000: public BLEServerCallbacks, public BLECharacteristicCallbacks {
  BLEServer *server;
  BLEService *service;
  BLECharacteristic *characteristic;

  bool deviceConnected;
  int outputPins[6] = {
    LED_GREEN,
    LED_RED,
    MOTOR_LEFT_FORWARD,
    MOTOR_LEFT_BACKWARD,
    MOTOR_RIGHT_FORWARD,
    MOTOR_RIGHT_BACKWARD
  };

  int motorPins[4] = {
    MOTOR_LEFT_FORWARD,
    MOTOR_LEFT_BACKWARD,
    MOTOR_RIGHT_FORWARD,
    MOTOR_RIGHT_BACKWARD
  };

  private:
    void advertise();
    void resetHardwareState();

  public:
    void init();
    void loop();
    void onConnect(BLEServer* pServer);
    void onDisconnect(BLEServer* pServer);
    void onWrite(BLECharacteristic *pCharacteristic);
};

#endif