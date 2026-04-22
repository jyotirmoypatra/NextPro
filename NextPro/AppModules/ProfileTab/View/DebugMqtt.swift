//
//  DebugMqtt.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 09/03/26.
//

import UIKit
import PDFKit
import SwiftUI

struct MQTTLog: Identifiable {
    let id = UUID()
    let direction: String
    let topic: String
    let message: String
}

struct DebugMqtt: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var serialNumber = "4282184653"
   // @State private var logs: [String] = []
    @State private var logs: [MQTTLog] = []
    
    @State private var commands: [[String: Any]] = []
    @State private var currentIndex = 0
    @State private var uploading = false
    @State private var timeoutTask: DispatchWorkItem?
    @State private var waitingForResponse = false
    
    @State private var currentUserID = 1
    
    @State private var isClearOperation = false
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                }

                Spacer()

                Text("MQTT Debug")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

              
            }
            .padding(10)
            
           
            
            // Serial number input
            TextField("Enter Device Serial Number", text: $serialNumber)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .foregroundColor(.white)
                .padding(.horizontal,10)
            
            HStack(spacing: 5) {
                
                Button {
                    subscribeUP()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 20))
                        Text("Subscribe UP")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 65)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                
                Button {
                    subscribeDOWN()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 20))
                        Text("Subscribe DOWN")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 65)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                }
                
                Button {
                    MQTTManager.shared.sendHeartbeatCheck(to: serialNumber)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                        Text("HeartBeat")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 65)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.pink)
                    .cornerRadius(12)
                }
                
                
                Button {
                    clearDeviceData()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 20))
                        Text("Clear Device")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 65)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }

            }
            .padding(.horizontal,10)
            
            HStack(spacing: 10) {
                
                Button {
                    startUpload()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 22))
                        Text("Bulk Upload")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(12)
                }

                Button {
                    exportPDF()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                        Text("Export Log")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.yellow)
                    .cornerRadius(12)
                }

                Button {
                    logs.removeAll()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 22))
                        Text("Clear Logs")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }

            }
            .padding(.horizontal,10)
        
            
            ScrollViewReader { proxy in
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        ForEach(logs) { log in
                            
                            VStack(alignment: .leading, spacing: 6) {
                                
                                Text(log.direction)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(log.direction == "UP" ? .blue : .orange)
                                
                                Divider()
                                    .background(Color.gray.opacity(0.4))
                                
                                Text("Topic: \(log.topic)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                
                                Text(log.message)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.green)
                                    .textSelection(.enabled)
                            }
                            .padding(.vertical,10)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                            .id(log.id)   // important
                        }
                    }
                    .padding()
                }
                .background(Color.black)
                .cornerRadius(12)
                .padding(5)
                
                .onChange(of: logs.count) { _ in
                    
                    if let last = logs.last {
                        
                        DispatchQueue.main.async {
                            withAnimation(.easeOut(duration: 0.25)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
        }
        .background(Color.black.ignoresSafeArea())
        .onTapGesture {
            UIApplication.shared.hideKeyboard()
        }
        
        .onReceive(MQTTManager.shared.$lastMessage) { msg in
            
            guard !msg.isEmpty else { return }

            let sn = serialNumber.trimmingCharacters(in: .whitespaces)

            let direction: String
            let topic: String

            if msg.contains(sn) {
                direction = "UP"
                topic = "up/\(sn)/rtdata"
            } else {
                direction = "DOWN"
                topic = "down/\(sn)"
            }

            logs.append(
                MQTTLog(
                    direction: direction,
                    topic: topic,
                    message: msg
                )
            )

            if uploading && waitingForResponse {

                
                if msg.lowercased().contains("ok") {

                    timeoutTask?.cancel()
                    waitingForResponse = false

                    if isClearOperation {
                        // Only one final success log
                        currentIndex += 1
                        
                        if currentIndex >= commands.count {
                            uploading = false
                            
                            logs.append(
                                MQTTLog(
                                    direction: "INFO",
                                    topic: "CLEAR",
                                    message: "Device data cleared successfully"
                                )
                            )
                        } else {
                            sendNextCommand()
                        }
                        
                    } else {
                        // Upload logic
                        
                        if (currentIndex + 1) % 4 == 0 {

                            logs.append(
                                MQTTLog(
                                    direction: "INFO",
                                    topic: "UPLOAD",
                                    message: "User \(currentUserID) uploaded successfully"
                                )
                            )

                            currentUserID += 1
                        }

                        currentIndex += 1
                        sendNextCommand()
                    }
                }
            }
        }
        
       
    }
    
    // MARK: - Subscribe UP
    func subscribeUP() {
        
        let sn = serialNumber.trimmingCharacters(in: .whitespaces)
        guard !sn.isEmpty else { return }
        
        MQTTManager.shared.subscribeToDevice(sn, model: "BC220")
        
        let log = MQTTLog(
            direction: "UP",
            topic: "up/\(sn)/rtdata",
            message: "📡 Subscribed to UP topic"
        )
        
        logs.append(log)
    }
    
    // MARK: - Subscribe DOWN
    func subscribeDOWN() {
        
        let sn = serialNumber.trimmingCharacters(in: .whitespaces)
        guard !sn.isEmpty else { return }
        
        MQTTManager.shared.subscribeDownChannel(sn: sn)
        
        let log = MQTTLog(
            direction: "DOWN",
            topic: "down/\(sn)",
            message: "📡 Subscribed to DOWN topic"
        )
        
        logs.append(log)
    }
    
    
    func startUpload() {

        let sn = serialNumber.trimmingCharacters(in: .whitespaces)
        guard !sn.isEmpty else { return }

        commands.removeAll()
        
        currentUserID = 1
        isClearOperation = false

        for id in 1...25 {

            let user: [String: Any] = [
                "commandid": 2,
                "operation": "PUT",
                "resource": "tables/users",
                "data": [[
                    "UserID": id,
                    "Name": "User\(id)",
                    "Access": "1",
                    "passageMode": 1,
                    "SuperUser": 0,
                    "Disable": 0
                ]]
            ]

            let card: [String: Any] = [
                "commandid": 2,
                "operation": "PUT",
                "resource": "tables/cards",
                "data": [[
                    "UserID": id,
                    "CardNo": 1000000000 + id,
                    "Status": 1
                ]]
            ]

            let tpg: [String: Any] = [
                "commandid": 2,
                "operation": "PUT",
                "resource": "tables/time_passage_group",
                "data": [[
                    "tpgID": id,
                    "applyAllUsers": 0,
                    "startTime1": "08:00",
                    "endTime1": "18:00",
                    "passageMode": 1,
                    "timeMode": 1,
                    "startDate": "2026-09-09",
                    "endDate": "2026-12-31",
                    "weekDays": "1,2,3,4,5,6,7"
                ]]
            ]

            let userTPG: [String: Any] = [
                "commandid": 2,
                "operation": "PUT",
                "resource": "tables/user_time_passage_group",
                "data": [[
                    "tpgID": id,
                    "userID": id
                ]]
            ]

            commands.append(user)
            commands.append(card)
            commands.append(tpg)
            commands.append(userTPG)
        }

        currentIndex = 0
        uploading = true

        logs.append(
            MQTTLog(
                direction: "INFO",
                topic: "UPLOAD",
                message: "Starting upload of 25 users..."
            )
        )

        sendNextCommand()
    }
    
    func sendNextCommand() {

        if currentIndex >= commands.count {
            uploading = false
            
            logs.append(
                MQTTLog(
                    direction: "INFO",
                    topic: "UPLOAD",
                    message: "Upload completed successfully"
                )
            )
            
            return
        }

        let sn = serialNumber.trimmingCharacters(in: .whitespaces)
        let cmd = commands[currentIndex]

        if let data = try? JSONSerialization.data(withJSONObject: cmd),
           let msg = String(data: data, encoding: .utf8) {

            MQTTManager.shared.publishRaw(sn: sn, message: msg)



            waitingForResponse = true

            startTimeout()
        }
    }
    
    func startTimeout() {

        timeoutTask?.cancel()

        let task = DispatchWorkItem {
            
            if waitingForResponse {
                
                uploading = false
                waitingForResponse = false
                
                logs.append(
                    MQTTLog(
                        direction: "ERROR",
                        topic: "UPLOAD",
                        message: "Timeout: No OK received in 10 seconds. Upload stopped."
                    )
                )
            }
        }

        timeoutTask = task

        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: task)
    }
    
    func exportPDF() {

        if logs.isEmpty { return }

        let text = logs.map {
            """
            \($0.direction)
            Topic: \($0.topic)
            \($0.message)

            --------------------------------------

            """
        }.joined()

        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let margin: CGFloat = 20

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { context in

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            ]

            let attributedText = NSAttributedString(string: text, attributes: attributes)

            let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
            var currentRange = CFRange(location: 0, length: 0)

            repeat {

                context.beginPage()

                let frameRect = CGRect(
                    x: margin,
                    y: margin,
                    width: pageWidth - margin * 2,
                    height: pageHeight - margin * 2
                )

                let path = CGMutablePath()
                path.addRect(frameRect)

                let frame = CTFramesetterCreateFrame(framesetter, currentRange, path, nil)

                let ctx = context.cgContext
                ctx.textMatrix = .identity
                ctx.translateBy(x: 0, y: pageHeight)
                ctx.scaleBy(x: 1, y: -1)

                CTFrameDraw(frame, ctx)

                let visibleRange = CTFrameGetVisibleStringRange(frame)
                currentRange.location += visibleRange.length

            } while currentRange.location < attributedText.length
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("mqtt_logs.pdf")

        do {
            try data.write(to: url)

            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(activityVC, animated: true)
            }

        } catch {
            print("PDF export failed:", error)
        }
    }
    
    func clearDeviceData() {
        

        let sn = serialNumber.trimmingCharacters(in: .whitespaces)
        guard !sn.isEmpty else {
            logs.append(
                MQTTLog(
                    direction: "ERROR",
                    topic: "CLEAR",
                    message: "Serial number required to clear device data"
                )
            )
            return
        }

        commands.removeAll()
        isClearOperation = true

        let deleteCards: [String: Any] = [
            "commandid": 2,
            "operation": "DELETE",
            "resource": "tables/cards"
        ]

        let deleteUsers: [String: Any] = [
            "commandid": 2,
            "operation": "DELETE",
            "resource": "tables/users"
        ]

        let deleteUserTPG: [String: Any] = [
            "commandid": 2,
            "operation": "DELETE",
            "resource": "tables/user_time_passage_group"
        ]

        let deleteTPG: [String: Any] = [
            "commandid": 2,
            "operation": "DELETE",
            "resource": "tables/time_passage_group"
        ]

        commands.append(deleteCards)
        commands.append(deleteUsers)
        commands.append(deleteUserTPG)
        commands.append(deleteTPG)

        currentIndex = 0
        uploading = true

        logs.append(
            MQTTLog(
                direction: "INFO",
                topic: "CLEAR",
                message: "Starting device data cleanup..."
            )
        )

        sendNextCommand()
    }
   
}
