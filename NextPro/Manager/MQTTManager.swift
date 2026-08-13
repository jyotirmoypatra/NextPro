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
       // print("📥 Subscribed: \(success.allKeys) | Failed: \(failed)")
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
    private var subscribedTopics = Set<String>()

    private override init() {}
    
    func getUDID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
    }
    
//    func connect() {
//
//        let clientID = getUDID()
//        let mqttClient = CocoaMQTT(clientID: clientID, host: "13.223.139.54", port: 1883)
//        mqttClient.username = "nexpromqtt"
//        mqttClient.password = "neXpr02o25MqtT"
//        mqttClient.keepAlive = 120
//        mqttClient.cleanSession = true
//        mqttClient.willMessage = nil
//        mqttClient.autoReconnect = true
//        mqttClient.enableSSL = false
//        mqttClient.delegate = self
//        mqtt = mqttClient
//        _ = mqttClient.connect()
//    }

    func connect() {
        let host     = KeychainManager.shared.get("mqtt_host")     ?? ""
        let portStr  = KeychainManager.shared.get("mqtt_port")     ?? "1883"
        let username = KeychainManager.shared.get("mqtt_username") ?? ""
        let password = KeychainManager.shared.get("mqtt_password") ?? ""
        let port     = UInt16(portStr) ?? 1883

        guard !host.isEmpty, !username.isEmpty, !password.isEmpty else {
            print("❌ MQTT credentials missing from Keychain — cannot connect")
            return
        }

        print("🔌 Connecting to MQTT broker: \(host):\(port) as \(username)")

        let clientID   = getUDID()
        let mqttClient = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqttClient.username     = username
        mqttClient.password     = password
        mqttClient.keepAlive    = 120
        mqttClient.cleanSession = true
        mqttClient.willMessage  = nil
        mqttClient.autoReconnect = true
        mqttClient.enableSSL    = false
        mqttClient.delegate     = self
        mqtt = mqttClient
        _ = mqttClient.connect()
    }


    // Subscribe to device response topic (example: up/{SN}/rtdata)
//    func subscribeToDevice(_ sn: String, model:String) {
//        var topic = ""
//        if model == "TC434"{
//             topic = "up/\(sn)/data"
//        }else{
//            topic = "up/\(sn)/rtdata"
//        }
//        
//        mqtt?.subscribe(topic, qos: .qos1)
//        print("📡 Subscribed to topic: \(topic)")
//    }
    
    func subscribeToDevice(_ sn: String, model: String) {

        let topic: String
        if model.uppercased() == "TC434" {
            topic = "up/\(sn)/data"
        } else {
            topic = "up/\(sn)/rtdata"
        }

        // 🚫 Prevent duplicate subscription
        guard !subscribedTopics.contains(topic) else {
            print("⚠️ Already subscribed to:", topic)
            return
        }

        subscribedTopics.insert(topic)
        mqtt?.subscribe(topic, qos: .qos1)

        print("📡 MQTT Subscribed:", topic)
    }


    // Publish open door command to the device
    func sendOpenDoorCommand(to deviceSN: String, doorID: Int32 = 1, duration: Int = 5) {
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
//        subscribeToDevice("4283847520" ,  model: "tc434")
//        subscribeToDevice("4282184653", model: "bc220")
//        subscribeToDevice("4282705968", model: "M230")
        resubscribeAllTopics()
    }

    private func resubscribeAllTopics() {
        for topic in subscribedTopics {
            mqtt?.subscribe(topic, qos: .qos1)
            print("🔁 Re-subscribed:", topic)
        }
    }
    
    // MARK: - Subscribe if not already subscribed (Heartbeat)
    func subscribeIfNeeded(sn: String) {
        let topic = "up/\(sn)/rtdata"

        // Prevent duplicate subscription
        guard !subscribedTopics.contains(topic) else {
            return
        }

        subscribedTopics.insert(topic)
        mqtt?.subscribe(topic, qos: .qos1)
        print("📡 MQTT subscribed to \(topic)")
    }
    
    func subscribeDownChannel(sn: String) {
        let topic = "down/\(sn)"

        guard !subscribedTopics.contains(topic) else { return }

        subscribedTopics.insert(topic)
        mqtt?.subscribe(topic, qos: .qos1)

        print("📡 Subscribed to DOWN topic:", topic)
    }
    
    func publishRaw(sn: String, message: String) {
        
        let topic = "down/\(sn)"
        
        mqtt?.publish(topic, withString: message, qos: .qos1)
        
        print("📤 Raw MQTT publish → \(topic)")
        print(message)
    }

    
    // MARK: - Heartbeat Check (Force Device to Send Heartbeat)
    func sendHeartbeatCheck(to deviceSN: String) {
        let topic = "down/\(deviceSN)"

        let payload: [String: Any] = [
            "commandid": 1,
            "operation": "PUT",
            "resource": "device/control?cmd=heartbeat"
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []),
              let message = String(data: data, encoding: .utf8) else {
            print("❌ Failed to encode heartbeat command")
            return
        }

        mqtt?.publish(topic, withString: message, qos: .qos1)
        print("💓 Heartbeat check sent to \(deviceSN)")
    }


    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        guard let msg = message.string else { return }
        print("📨 MQTT Message Received on \(message.topic): \(msg)")

        DispatchQueue.main.async {
            self.lastMessage = msg
        }

        guard let data = msg.data(using: .utf8) else { return }

        // Check which topic the message came from
        let topic = message.topic
        let isDataTopic = topic.contains("/data")
        let isRtdataTopic = topic.contains("/rtdata")
        
        print("📍 Topic type - data: \(isDataTopic), rtdata: \(isRtdataTopic)")

        do {
            // Decode only the top-level structure first
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let resource = json?["resource"] as? String else {
                print("⚠️ Missing resource key")
                return
            }

            switch resource {
            case "events":
                // Decode the event structure safely
                let event = try JSONDecoder().decode(DoorEvent.self, from: data)
                if let first = event.data.first {
                    NotificationCenter.default.post(
                        name: .doorEventReceived,
                        object: nil,
                        userInfo: [
                            "doorID": first.doorID,
                            "userID" : first.userID,
                            "verified": first.verified,
                            "type": first.type,
                            "sn": event.SN,
                            "time": first.time,
                            "cardnumber": first.number,
                            "topicType": isDataTopic ? "data" : "rtdata"  // ✅ Track topic type
                        ]
                    )
                    print("✅ Door event received (Topic: \(topic), SN: \(event.SN), doorID: \(first.doorID), type: \(first.type), verified: \(first.verified))")
                }


            case "commands/result":
                if let status = json?["status"] as? [String: Any] {
                    print("✅ Command Result (Topic: \(topic)): \(status)")
                }

            case "heartbeat":
                print("💓 Heartbeat received (Topic: \(topic))")

                if let sn = json?["SN"] as? String {
                    NotificationCenter.default.post(
                        name: .deviceHeartbeatReceived,
                        object: nil,
                        userInfo: ["sn": sn]
                    )
                }


            default:
                print("ℹ️ Unhandled resource type: \(resource) (Topic: \(topic))")
            }

        } catch {
            print("⚠️ Failed to decode MQTT message from \(topic): \(error)")
            print("📄 Raw message: \(msg)")
        }
    }


    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("❌ MQTT Disconnected: \(err?.localizedDescription ?? "unknown error")")
           DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
               print("🔄 Attempting to reconnect to MQTT...")
               self.reconnectIfNeeded()
           }
    }
    
    func reconnectIfNeeded() {
        guard let mqtt = mqtt else { return }
        if mqtt.connState != .connected && mqtt.connState != .connecting {
            _ = mqtt.connect()
        }
    }

    func disconnect() {
        mqtt?.autoReconnect = false
        mqtt?.disconnect()
        mqtt = nil
        subscribedTopics.removeAll()
        lastMessage = ""
        print("🔌 MQTT disconnected and local state cleared (logout)")
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
    let userID: String
    let number: String
    let verified: Int
    let doorID: Int
    let type: Int      // ✅ Added for success/failure check
    let direction: Int
    let time: String
}
