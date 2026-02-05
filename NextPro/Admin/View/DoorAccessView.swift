////
////  DoorAccessView.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 29/01/26.
////



import SwiftUI

struct DoorAccessView: View {

    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDoors: [SingleDoor]
    @ObservedObject var doorListVM: GetAllDoorListViewModel

    @State private var searchText: String = ""
    @State private var tempSelected: Set<String> = []

    var doors: [SingleDoor] {
        doorListVM.doorList
    }

    // MARK: - Search

    var filteredDoors: [SingleDoor] {
        if searchText.isEmpty {
            return doors
        } else {
            return doors.filter {
                $0.doorName.lowercased()
                    .contains(searchText.lowercased())
            }
        }
    }

    // MARK: - UI

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

                    // MARK: Header
                    HStack {

                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                Text("Back")
                                    .foregroundColor(.white)
                            }
                        }

                        Spacer()
                    }
                    .overlay(
                        Text("Door Access")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding()

                    // MARK: Search
                    TextField("Search Door", text: $searchText)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    // MARK: Door List
                    ScrollView(showsIndicators: false) {

                        VStack(spacing: 12) {

                            ForEach(filteredDoors) { door in

                                DoorRow(
                                    door: door,
                                    isSelected: tempSelected.contains(door.id)
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
                        .padding(.horizontal)
                    }
                    .refreshable {
                        await doorListVM.getDoorList(force: true)
                    }


                    Spacer()
                }
                .padding(.bottom, 80)

                // MARK: Save Button

                VStack {
                    Button {

                        selectedDoors = doors.filter {
                            tempSelected.contains($0.id)
                        }

                        dismiss()

                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .font(.custom("Inter-SemiBold", size: 16))
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxHeight: .infinity, alignment: .bottom)
                
                
                if doorListVM.isLoading{
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                }
            }
        }
        .navigationBarBackButtonHidden(true)

        // MARK: Lifecycle

        .onAppear {

            // Sync previously selected doors
            tempSelected = Set(selectedDoors.map { $0.id })

            // Call API only once per AddUserView lifetime
            if !doorListVM.hasLoadedOnce {
                Task {
                    await doorListVM.getDoorList()
                }
            }
        }
        .internetOverlay()
        // Reflect delete from AddUserView
        .onChange(of: selectedDoors) { newValue in
            tempSelected = Set(newValue.map { $0.id })
        }
    }

    // MARK: - Toggle

    private func toggleDoor(_ id: String) {
        if tempSelected.contains(id) {
            tempSelected.remove(id)
        } else {
            tempSelected.insert(id)
        }
    }
}

struct DoorRow: View {

    let door: SingleDoor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack {

                VStack(alignment: .leading, spacing: 4) {

                    Text(door.doorName)
                        .foregroundColor(.white)
                        .font(.custom("Inter-Regular", size: 16))

                    if let location = door.location {
                        Text(location)
                            .foregroundColor(.white.opacity(0.6))
                            .font(.custom("Inter-Regular", size: 13))
                    }
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
