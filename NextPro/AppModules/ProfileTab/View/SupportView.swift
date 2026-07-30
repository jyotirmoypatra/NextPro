//
//  SupportView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/07/26.
//

import SwiftUI
struct SupportView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()

                Color.black.opacity(0.9)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Nav bar
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                    }
                    .overlay(
                        Text("Support")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                    )
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 15)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {

                            Text("How to Contact Us")
                                .font(.custom("Inter-Bold", size: 15))
                                .foregroundColor(.white)

                            Divider().background(Color.white.opacity(0.15))

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Nextpro Technologies, Inc. (d/b/a ZYLX)")
                                    .font(.custom("Inter-SemiBold", size: 15))
                                    .foregroundColor(.white)

                                Text("8 The Green, Dover, Delaware 19901, United States")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.gray)

                                HStack(spacing: 6) {
                                    Text("Privacy contact:")
                                        .font(.custom("Inter-Regular", size: 14))
                                        .foregroundColor(.gray)
                                    Link("admin@getzylx.io", destination: URL(string: "mailto:admin@getzylx.io")!)
                                        .font(.custom("Inter-Medium", size: 14))
                                        .foregroundColor(.blue)
                                }
                            }

                            Divider().background(Color.white.opacity(0.15))

                            Text("For End Users who were enrolled by a specific Organization Administrator, you may also contact that Organization Administrator directly, which can often resolve straightforward requests (such as a lost card or a request to switch to a non-biometric credential) most quickly.")
                                .font(.custom("Inter-Regular", size: 15))
                                .foregroundColor(.gray)
                                .lineSpacing(5)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(14)
                        .padding(.horizontal, 10)
                    }
                    .padding(.horizontal, 4)
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}
