//
//  DoorAccessView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/01/26.
//


import SwiftUI

struct DoorAccessView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var selectedDoors: Set<String> = []

    // Dummy Data (replace with API later)
    let doors: [DoorModel] = [
        DoorModel(id: "UTL/L1-003", name: "UTL Front Gate"),
        DoorModel(id: "UTL/L0-001", name: "UTL Lift Gate"),
        DoorModel(id: "UTL/L1-002", name: "UTL Conference Room"),
        DoorModel(id: "UTL/L2-007", name: "Cafeteria"),
        DoorModel(id: "UTL/L3-002", name: "UTL Game Room")
    ]

    var filteredDoors: [DoorModel] {
        if searchText.isEmpty {
            return doors
        } else {
            return doors.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                // Background
                Image("backgroundimg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
                    .ignoresSafeArea()

                Color.black.opacity(0.9)
                    .ignoresSafeArea()

                VStack(spacing: 10) {

                    // MARK: - Header
                    HStack {

                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Back")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-SemiBold", size: 16))
                            }
                        }
                        Spacer()

                    }
                    .overlay(
                        Text("Door Access")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 10)

                    // MARK: - Search
                    TextField("Search Door", text: $searchText)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                        .foregroundColor(.white)


                    // MARK: - List
                    ScrollView(showsIndicators: false) {

                        VStack(spacing: 12) {

                            ForEach(filteredDoors) { door in

                                DoorRow(
                                    door: door,
                                    isSelected: selectedDoors.contains(door.id)
                                ) {
                                    toggleDoor(door.id)
                                }

                                Divider()
                                    .background(Color.white.opacity(0.15))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(16)
                    }.padding(.top,10)
                    

                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            UIApplication.shared.hideKeyboard()
        }
    }

    // MARK: - Toggle

    func toggleDoor(_ id: String) {
        if selectedDoors.contains(id) {
            selectedDoors.remove(id)
        } else {
            selectedDoors.insert(id)
        }
    }
}


struct DoorRow: View {

    let door: DoorModel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {

            HStack {

                VStack(alignment: .leading, spacing: 4) {

                    Text(door.name)
                        .foregroundColor(.white)
                        .font(.custom("Inter-Regular", size: 16))

                    Text(door.id)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.custom("Inter-Regular", size: 13))
                }

                Spacer()

                Image(isSelected ? "square-check" : "square-uncheck")
                    .resizable()
                    .frame(width: 22, height: 22)
            }
            .padding(.vertical, 14)
        }
    }
}


struct DoorModel: Identifiable {
    let id: String
    let name: String
}
