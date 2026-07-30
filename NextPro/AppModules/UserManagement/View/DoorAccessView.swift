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
    @State private var showDoorListVMError = false
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
                        // LEFT: Back Button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        // RIGHT: Info Icon
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .overlay(
                        Text("Add Door")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)


                    // MARK: Search
//                    TextField("Search Door", text: $searchText)
//                        .padding()
//                        .background(Color.white.opacity(0.15))
//                        .cornerRadius(10)
//                        .foregroundColor(.white)
//                        .padding(.horizontal)
                    
                    HStack(spacing: 8) {

                              Image(systemName: "magnifyingglass")
                                  .foregroundColor(.white.opacity(0.7))
                        ZStack(alignment: .leading) {
                            if searchText.isEmpty {
                                Text("Search Door")
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .font(.custom("Inter-Regular", size: 16))
                                
                                
                            }
                            TextField("", text: $searchText)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                          }
                          .padding(.horizontal, 12)
                          .frame(height: 46)
                          .background(Color.clear)
                          .overlay(
                              RoundedRectangle(cornerRadius: 10)
                                  .stroke(Color.white.opacity(0.5), lineWidth: 1)
                          )

                    // MARK: Door List
                    ScrollView(showsIndicators: false) {
                        if !filteredDoors.isEmpty {
                            VStack(spacing: 12) {
                                
                                ForEach(filteredDoors.indices, id: \.self) { index in
                                    
                                    let door = filteredDoors[index]
                                    
                                    DoorRow(
                                        door: door,
                                        isSelected: tempSelected.contains(door.id)
                                    ) {
                                        toggleDoor(door.id)
                                    }
                                    
                                    if index != filteredDoors.count - 1 {
                                        Divider()
                                            .background(Color.white.opacity(0.15))
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(16)
                        }
                     
                    }
                    .refreshable {
                        await doorListVM.getDoorList(force: true)
                    }


                    Spacer()
                }
                .padding(.horizontal,10)
                .padding(.bottom, 80)

                // MARK: Save Button

                VStack {
                    Button {

//                        selectedDoors = doors.filter {
//                            tempSelected.contains($0.id)
//                        }
                        
                        let previousDoors = selectedDoors

                        selectedDoors = tempSelected.compactMap { id in
                            doors.first(where: { $0.id == id }) ??
                            previousDoors.first(where: { $0.id == id })
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
                    
                    if !doorListVM.hasLoadedOnce{
                        showDoorListVMError = true
                    }
                }
            }
        }
        .internetOverlay()
        // Reflect delete from AddUserView
        .onChange(of: selectedDoors) { newValue in
            tempSelected = Set(newValue.map { $0.id })
        }
        
        .modernAlert(
                isPresented: Binding(
                    get: { showDoorListVMError && !doorListVM.isFailedDueToNoInternet },
                    set: { showDoorListVMError = $0 }
                )
            ) {
                ModernAlertView(
                    title: "Error!",
                    message: doorListVM.errorMessage ?? "Something went wrong!",
                    isSuccess: false,
                    buttonTitle: "OK"
                ) {
                    showDoorListVMError = false
                }
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
