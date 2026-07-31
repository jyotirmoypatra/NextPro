//
//  InfoScreenView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/07/26.
//

import SwiftUI

struct InfoScreenView: View {
    @Environment(\.dismiss) private var dismiss
    let infoType: String

    private var imageName: String {
        switch infoType {
        case "device_config_info":
            return "info_device_config"
        default:
            return "info_device_config"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("backgroundimg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()

                Color.black.opacity(0.9)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .overlay(
                        Text("Info")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 15)

                    ScrollView(.vertical, showsIndicators: false) {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
