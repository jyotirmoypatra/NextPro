//
//  MQTTManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 12/11/25.
//


import Foundation
import CocoaMQTT
import Combine

class MQTTManager: NSObject, ObservableObject, CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("📡 MQTT State changed to: \(state)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("📤 Published message to \(message.topic): \(message.string ?? "")")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("✅ Publish acknowledged: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("📥 Subscribed: \(success.allKeys) | Failed: \(failed)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("🚫 Unsubscribed from topics: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("📶 Ping sent")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("🏓 Pong received")
    }

    
    static let shared = MQTTManager()

    private var mqtt: CocoaMQTT?
    @Published var lastMessage: String = ""

    private override init() {}

    // Connect to NextPro MQTT Broker
//    func connect() {
//        let clientID = "ios-client-\(UUID().uuidString.prefix(6))"
//        let mqttClient = CocoaMQTT(clientID: clientID, host: "13.223.139.54", port: 1883)
//        mqttClient.username = "nexpromqtt"
//        mqttClient.password = "secret"
//        mqttClient.keepAlive = 60
//        mqttClient.autoReconnect = true
//        mqttClient.delegate = self
//        mqttClient.connect()
//        mqtt = mqttClient
//    }
    
    func connect(deviceSN: String = "4283847520") {
        let clientID = "down/\(deviceSN)" // Required pattern
        let mqttClient = CocoaMQTT(clientID: clientID, host: "13.223.139.54", port: 1883)
        mqttClient.username = "nexpromqtt"
        mqttClient.password = "neXpr02o25MqtT"
        mqttClient.keepAlive = 120
        mqttClient.cleanSession = false
        mqttClient.autoReconnect = true
        mqttClient.enableSSL = false
        mqttClient.delegate = self
        mqttClient.logLevel = .debug
        mqtt = mqttClient
        _ = mqttClient.connect() // store result just to silence compiler
    }


    // Subscribe to device response topic (example: up/{SN}/rtdata)
    func subscribeToDevice(_ sn: String) {
        let topic = "up/\(sn)/rtdata"
        mqtt?.subscribe(topic, qos: .qos1)
        print("📡 Subscribed to topic: \(topic)")
    }

    // Publish open door command to the device
    func sendOpenDoorCommand(to deviceSN: String, doorID: Int = 1, duration: Int = 5) {
        let topic = "down/\(deviceSN)"
        let payload: [String: Any] = [
            "commandid": 1,
            "operation": "put",
            "resource": "device/doors/\(doorID)/lock/status?value=on&time=\(duration)"
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: []),
           let message = String(data: data, encoding: .utf8) {
            mqtt?.publish(topic, withString: message, qos: .qos1)
            print("🚪 MQTT Command Sent to \(topic): \(message)")
        }
    }

    // MARK: - CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("✅ MQTT Connected Successfully")
    }

//    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
//        let msg = message.string ?? ""
//        print("📨 MQTT Message Received on \(message.topic): \(msg)")
//        DispatchQueue.main.async {
//            self.lastMessage = msg
//        }
//    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let msg = message.string ?? ""
        print("📨 MQTT Message Received on \(message.topic): \(msg)")

        DispatchQueue.main.async {
            self.lastMessage = msg
        }

        // ✅ Decode the message for door open event
        if message.topic.contains("/rtdata"),
           let data = msg.data(using: .utf8) {
            do {
                let event = try JSONDecoder().decode(DoorEvent.self, from: data)
                if event.resource == "events",
                   let first = event.data.first {
                    NotificationCenter.default.post(
                        name: .doorEventReceived,
                        object: nil,
                        userInfo: ["doorID": first.doorID,
                                   "verified": first.verified,
                                   "time": first.time]
                    )
                    print("✅ Door \(first.doorID) event received at \(first.time)")
                }
            } catch {
                print("⚠️ Failed to decode event: \(error)")
            }
        }
    }

    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("❌ MQTT Disconnected: \(err?.localizedDescription ?? "unknown error")")
    }
}


extension Notification.Name {
    static let doorEventReceived = Notification.Name("doorEventReceived")
}

struct DoorEvent: Codable {
    let SN: String
    let resource: String
    let data: [DoorEventData]
}

struct DoorEventData: Codable {
    let doorID: Int
    let verified: Int
    let type: Int
    let time: String
}
