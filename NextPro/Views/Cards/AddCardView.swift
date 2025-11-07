//
//  AddCardView.swift
//  NextPro
//
//  Minimal UI to scan a tag UID/type using NFCTagReaderService
//

import SwiftUI

struct AddCardView: View {
	@Environment(\.dismiss) var dismiss
	@StateObject private var nfc = NFCTagReaderService()
	private let timeFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateStyle = .medium
		f.timeStyle = .medium
		return f
	}()
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				Image("backgroundimg")
					.resizable()
					.scaledToFill()
					.frame(width: geo.size.width, height: geo.size.height)
					.ignoresSafeArea()
				Color.black.opacity(0.85).ignoresSafeArea()
				VStack(spacing: 16) {
					header
					scanSection
					resultSection
					Spacer()
				}
				.padding(.horizontal, 20)
			}
		}
	}
	
	private var header: some View {
		HStack {
			Button(action: { dismiss() }) {
				Image(systemName: "chevron.left")
					.foregroundColor(.white)
					.frame(width: 40, height: 40)
					.background(Color.white.opacity(0.1))
					.clipShape(Circle())
			}
			Spacer()
			Text("Add Card")
				.font(.title2.bold())
				.foregroundColor(.white)
			Spacer().frame(width: 40)
		}
		.padding(.top, 50)
	}
	
	private var scanSection: some View {
		VStack(spacing: 16) {
			ZStack {
				Circle()
					.fill(LinearGradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
					.frame(width: 120, height: 120)
					.scaleEffect(nfc.isScanning ? 1.15 : 1.0)
					.opacity(nfc.isScanning ? 0.6 : 1.0)
				Image(systemName: "wave.3.right.circle.fill")
					.font(.system(size: 54))
					.foregroundColor(.white)
			}
			Text(nfc.statusMessage)
				.font(.headline)
				.foregroundColor(.white)
				.multilineTextAlignment(.center)
			if let err = nfc.errorMessage {
				Text(err)
					.font(.caption)
					.foregroundColor(.red)
			}
			Button(action: { nfc.isScanning ? nfc.stop() : nfc.start() }) {
				HStack {
					Image(systemName: nfc.isScanning ? "xmark.circle.fill" : "wave.3.right")
						.font(.system(size: 20))
					Text(nfc.isScanning ? "Cancel" : "Start Scan")
						.font(.headline)
				}
				.foregroundColor(.white)
				.frame(maxWidth: .infinity)
				.frame(height: 56)
				.background(
					LinearGradient(
						colors: nfc.isScanning ? [Color.red.opacity(0.85), Color.red] : [Color.blue, Color.purple],
						startPoint: .leading,
						endPoint: .trailing
					)
				)
				.cornerRadius(16)
			}
			.opacity(1.0)
		}
		.padding(24)
		.background(Color.white.opacity(0.05))
		.cornerRadius(20)
		.overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
	}
	
	private var resultSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Detected Tag")
				.font(.headline)
				.foregroundColor(.white)
			if let uid = nfc.lastUIDHex {
				resultRow(title: "UID", value: uid)
			}
			if let type = nfc.lastTagType {
				resultRow(title: "Type", value: type)
			}
			if let ts = nfc.timestamp {
				resultRow(title: "Time", value: timeFormatter.string(from: ts))
			}
			if nfc.lastUIDHex == nil && nfc.errorMessage == nil {
				Text("No tag detected yet")
					.font(.subheadline)
					.foregroundColor(.gray)
			}
		}
		.padding(20)
		.background(Color.white.opacity(0.05))
		.cornerRadius(20)
		.overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
	}
	
	private func resultRow(title: String, value: String) -> some View {
		HStack {
			Text(title)
				.font(.subheadline).foregroundColor(.gray)
			Spacer()
			Text(value)
				.font(.subheadline).foregroundColor(.white)
				.lineLimit(1)
		}
	}
}

#Preview {
	AddCardView()
}
