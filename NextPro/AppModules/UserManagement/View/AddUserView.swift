//
//  AddUserView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct AddUserView: View {
    
    let editUser: GetUserData?
    let onDismiss: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var addUserVM = AddUserViewModel()
    @StateObject private var generateNFCID = GenerateUniqueNfcViewModel()
    @StateObject private var getAccessGroupVM = GetAccessGroupListViewModel()
    @State private var showAddUserVMError = false
    @State private var showAccessGroupVMError = false
    @State private var showAddUserSuccess = false
    @State private var navigateToUserManagement = false
    @State private var navigateToDoorAddView = false
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = "Password@2026"
    @State private var phone = ""
    @State private var nfcId = ""
    @State private var nfcPhysicalNumber = ""
   
    @State private var digitalAccess = false
    @State private var remoteAccess = false


    @State private var isOneTimeAccess: Bool = true
    @State private var isScheduledAccess: Bool = false
    
    @State private var isSelectAccessGroup: Bool = true
    @State private var isSelectDoor: Bool = false
    
    @State private var isSelectMobileAPP: Bool = false
    @State private var isSelectKeyFob: Bool = false
    @State private var isSharedLink: Bool = false

    @State private var showTimePicker = false
    @State private var timeSlots: [TimeSlotUI] = [TimeSlotUI()]
    @State private var selectedTimeIndex: Int? = nil
    @State private var isSelectingStart: Bool = true
    
    
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    
    @State private var accessStartDate: Date? = nil
    @State private var accessEndDate: Date? = nil


    @State private var selectedWeekdays: Set<Int> = []   // 1 = Sun ... 7 = Sat

    @State private var selectedDoors: [SingleDoor] = []
    @StateObject private var doorListVM = GetAllDoorListViewModel()

    @State private var shouldScrollToDoorSection = false

    
    //@State private var selectedAccessGroup: AccessGroupItem? = nil
    @State private var selectedAccessGroups: [AccessGroupItem] = []
    @State private var openSection: Int? = nil
    
    @State private var hasInitialized = false
    
    @State private var isInitialLoading = false
    @State private var nfcType : String = "DIGITAL"
    
    @State private var isEditModeLoaded = false
    
    
    enum Field {
        case fullName
        case email
        case phone
    }
    var maxSlots: Int {
        return isOneTimeAccess ? 1 : 3
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("backgroundimg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                VStack(spacing: 10){
                    
                    HStack {
                        // LEFT: Back Button
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
                        
                        // RIGHT: Info Icon
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .overlay(
                        Text(editUser != nil ? "Edit User" : "Add User")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                    
                    
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 18) {
                                
                                LabeledTextField(
                                    title: "Full Name",
                                    placeholder: "Enter full name",
                                    isRequired: true,
                                    text: $fullName,
                                )
                                
                                .focused($focusedField, equals: .fullName)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .email
                                }
                                
                                
                                
                                LabeledTextField(
                                    title: "Email ID",
                                    placeholder: "Enter email",
                                    isRequired: true,
                                    text: $email,
                                    
                                )
                    
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .phone
                                }
                                
                                LabeledTextField(
                                    title: "Phone Number",
                                    placeholder: "Enter phone",
                                    text: $phone,
                                    keyboardType: .numberPad
                                    
                                )
                              
                                .focused($focusedField, equals: .phone)
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil
                                }
                                
//                                LabeledTextField(
//                                    title: "Digital Key Fob ID",
//                                    placeholder: "Generate NFC Card Id",
//                                    isRequired: true,
//                                    text: $nfcId,
//                                    isHaveBtn: true,
//                                    isEditMode: editUser != nil
//                                    
//                                )
                                
                                
                                VStack(alignment: .leading, spacing: 12) {

                                    HStack(spacing: 2) {
                                        Text("DEVICE ACCESS")
                                            .font(.custom("Inter-Medium", size: 16))
                                            .foregroundColor(.white)

                                        Text("*").foregroundColor(.red)
                                    }

                                    VStack(spacing: 20) {

                                   
//                                        AccessTypeRow(
//                                            title: "Mobile App",
//                                            isSelected: isSelectMobileAPP
//                                        ) {
//                                            isSelectMobileAPP = true
//                                            isSelectKeyFob = false
//                                            nfcType = "DIGITAL"
//                                            
//                                            handleNfcGeneration()
//                                        }
//                                        
//                                
//                                        AccessTypeRow(
//                                            title: "Key Fob/Card",
//                                            isSelected: isSelectKeyFob
//                                        ) {
//                                            isSelectMobileAPP = false
//                                            isSelectKeyFob = true
//                                            digitalAccess = false
//                                            remoteAccess = false
//                                            nfcType = "PHYSICAL"
//                                        }
//                                        
//                                        AccessTypeRow(
//                                            title: "Both",
//                                            isSelected: isSelectBoth
//                                        ) {
//                                            isSelectMobileAPP = false
//                                            isSelectKeyFob = false
//                                            isSelectBoth = true
//                                            digitalAccess = true
//                                            nfcType = "BOTH"
//                                            
//                                            handleNfcGeneration()
//                                        }
                                        
                                        
                                        VStack(spacing: 16) {
                                          
                                            Toggle(isOn: $isSelectMobileAPP) {
                                                Text("Mobile App")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 15, weight: .medium))
                                            }
                                            .tint(.green)
                                            
                                            
                                            if isSelectMobileAPP {

                                                VStack(alignment: .leading, spacing: 12) {

                                                    Text("Mobile App Options:")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 15, weight: .medium))

                                                    
                                                    VStack(spacing: 20) {

                                                        // Phone Tap
    //                                                    CheckBoxView(
    //                                                        title: "Phone Tap",
    //                                                        isChecked: $digitalAccess
    //                                                    )
                                                        
                                                        Toggle(isOn: $digitalAccess) {
                                                            Text("Phone Tap")
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 15, weight: .medium))
                                                        }
                                                        .tint(.green)

                                                        // Remote + Bluetooth (Grouped)
                                                        VStack(alignment: .leading, spacing: 20) {

    //                                                        CheckBoxView(
    //                                                            title: "Remote",
    //                                                            isChecked: $remoteAccess
    //                                                        )
                                                            
                                                            Toggle(isOn: $remoteAccess) {
                                                                Text("Remote")
                                                                    .foregroundColor(.white)
                                                                    .font(.system(size: 15, weight: .medium))
                                                            }
                                                            .tint(.green)
                                                            
                                                            //Sub Option
                                                            if remoteAccess {
    //                                                            CheckBoxView(
    //                                                                title: "Bluetooth",
    //                                                                isChecked: $remoteAccess,
    //                                                                isDisable : true
    //                                                            )
    //                                                            .padding(.leading, 28)
    //                                                            .opacity(0.9)
                                                                
                                                                Toggle(isOn: $remoteAccess) {
                                                                    Text("Bluetooth")
                                                                        .foregroundColor(.white.opacity(0.5))
                                                                        .font(.system(size: 15, weight: .medium))
                                                                }
                                                                .tint(Color.green.opacity(0.5))
                                                                .padding(.leading, 15)
                                                            }
                                                        }
                                                    }
                                                    .padding()
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.white.opacity(0.3))
                                                    )
                                                }
                                            }
                                            
                                            
                                            Toggle(isOn: $isSelectKeyFob) {
                                                Text("Key Fob / Card")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 15, weight: .medium))
                                            }
                                            .tint(.green)
                                            
                                            // MARK: - Key Fob Input
                                            if isSelectKeyFob {

                                                
                                                LabeledTextField(
                                                    title: "Physical Key Fob/Card ID:",
                                                    placeholder: "Enter key fob/card ID",
                                                    text: $nfcPhysicalNumber,
                                                    keyboardType: .numberPad
                                                    
                                                )
                                            }
                                            
                                            Toggle(isOn: $isSharedLink) {
                                                Text("Share Link")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 15, weight: .medium))
                                            }
                                            .tint(.green)
                                        }

                                        
                                        .onChange(of: isSelectMobileAPP) { _ in
//                                            if editUser == nil {
//                                                updateNfcType()
//                                            }
                                            updateNfcType()
                                        }

                                        .onChange(of: isSelectKeyFob) { _ in
//                                            if editUser == nil {
//                                                updateNfcType()
//                                            }
                                              updateNfcType()
                                            if isSelectKeyFob {
                                                    isSelectAccessGroup = true
                                                    isSelectDoor = false
                                            }
                                        }
                                       
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(12)
                                }
                                
                                
                                
                                
                                // ACCESS TYPE
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 2) {
                                        Text("ACCESS CONFIGURATION")
                                            .font(.custom("Inter-Medium", size: 16))
                                            .foregroundColor(.white)
                                        
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(spacing: 20) {
                                        
                                       
                                        AccessTypeRow(
                                            title: "Select Access group",
                                            isSelected: isSelectAccessGroup
                                        ) {
                                            isSelectAccessGroup = true
                                            isSelectDoor = false
                                        }
                                        
                                        if !isSelectKeyFob {
                                            AccessTypeRow(
                                                title: "Select Doors",
                                                isSelected: isSelectDoor
                                            ) {
                                                isSelectAccessGroup = false
                                                isSelectDoor = true
                                            }
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(12)
                                }
                                
                                if isSelectAccessGroup {
                                    
//                                    AccessGroupDropDown(
//                                        id: 0,
//                                        options: getAccessGroupVM.accessGroupList,
//                                        selectedGroup: $selectedAccessGroup,
//                                        openSection: $openSection
//                                    )
                                    AccessGroupDropDown(
                                        id: 0,
                                        options: getAccessGroupVM.accessGroupList,
                                        selectedGroups: $selectedAccessGroups,
                                        openSection: $openSection
                                    )
                                    .id("ACCESS_GROUP_SECTION")
                                    
                                }
                                
                                if isSelectDoor {
                                // ACCESS TYPE
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 2) {
                                        Text("ACCESS TYPE")
                                            .font(.custom("Inter-Medium", size: 16))
                                            .foregroundColor(.white)
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(spacing: 20) {
                                        
                                        // Schedule
                                        AccessTypeRow(
                                            title: "Schedule",
                                            isSelected: isScheduledAccess
                                        ) {
                                            isScheduledAccess = true
                                            isOneTimeAccess = false
                                        }
                                        
                                        // One Time
                                        AccessTypeRow(
                                            title: "One Time",
                                            isSelected: isOneTimeAccess
                                        ) {
                                            isOneTimeAccess = true
                                            isScheduledAccess = false
                                            
                                            //reset time slot ui
                                           // timeSlots = [TimeSlotUI()]
                                            
                                            timeSlots = [timeSlots.first ?? TimeSlotUI()]
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(12)
                                }
                                
                                //access date
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(spacing: 2) {
                                        Text("ACCESS DATE")
                                            .font(.custom("Inter-Medium", size: 16))
                                            .foregroundColor(.white)
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 16) {
                                        // Start Date
                                        dateBox(
                                            title: "Start Date",
                                            value: accessStartDate,
                                            action: { showStartDatePicker = true }
                                        )
                                        
                                        // End Date
                                        dateBox(
                                            title: "End Date",
                                            value: accessEndDate,
                                            action: { showEndDatePicker = true }
                                        )
                                    } .padding()
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
                                }
                                
                                VStack(alignment: .leading, spacing: 16) {

                                        HStack(spacing: 2) {
                                            Text("ACCESS TIME")
                                                .font(.custom("Inter-Medium", size: 16))
                                                .foregroundColor(.white)
                                            Text("*").foregroundColor(.red)
                                        }

                                        VStack(spacing: 10) {
                                            ForEach(timeSlots.indices, id: \.self) { index in
                                                
                                             
                                                    
                                                    VStack(spacing: 18) {
                                                        if isScheduledAccess {
                                                            HStack{
                                                                Text("Time Slot \(index + 1) :")
                                                                    .font(.custom("Inter-Medium", size: 17))
                                                                    .foregroundColor(.white.opacity(0.9))
                                                                
                                                                Spacer()
                                                                
                                                                if timeSlots.count > 1{
                                                                    // MINUS
                                                                    Button {
                                                                        timeSlots.remove(at: index)
                                                                    } label: {
                                                                        Image(systemName: "minus.circle.fill")
                                                                            .foregroundColor(.red)
                                                                            .font(.system(size: 22))
                                                                    }
                                                                }
                                                               
                                                            }.frame(height: 30)
                                                            .padding(.bottom,5)
                                                            
                                                        }
                                                        
                                                        // Start Time
                                                        timeBox(
                                                            title: "Start Time",
                                                            value: timeSlots[index].startTime
                                                        ) {
                                                            showTimePicker = true
                                                            selectedTimeIndex = index
                                                            isSelectingStart = true
                                                        }
                                                        
                                                        // End Time
                                                        timeBox(
                                                            title: "End Time",
                                                            value: timeSlots[index].endTime
                                                        ) {
                                                            showTimePicker = true
                                                            selectedTimeIndex = index
                                                            isSelectingStart = false
                                                        }
                                                        
                                                       
                                                        
                                                    
                                                        
                                                    }.padding()
                                                    .background(Color.white.opacity(0.05))
                                                    .cornerRadius(10)
                                                      
                                                  
                                            }
                                            
                                            
                                            if isScheduledAccess && timeSlots.count < maxSlots {
                                                HStack{
                                                    Spacer()
                                                    Button {
                                                        timeSlots.append(TimeSlotUI())
                                                    } label: {
                                                        Image(systemName: "plus.circle.fill")
                                                            .foregroundColor(.green)
                                                            .font(.system(size: 22))
                                                    }
                                                }
                                                //.padding(8)
                                                .padding(.trailing,10)
                                            }
                                        }
                                        .padding(10)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
                                    }
                                
                                
                                if isScheduledAccess {
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack(spacing: 2) {
                                        Text("REPEAT EVERY")
                                            .font(.custom("Inter-Medium", size: 16))
                                            .foregroundColor(.white)
                                            Text("*")
                                                .foregroundColor(.red)
                                        }
                                        
                                        LazyVGrid(
                                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7),
                                            spacing: 10
                                        ) {
                                            ForEach(1...7, id: \.self) { day in
                                                DayPill(
                                                    title: shortDay(day),
                                                    isSelected: selectedWeekdays.contains(day)
                                                ) {
                                                    toggleDay(day)
                                                }
                                            }
                                        }
                                        .padding()   //  indent
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
                                    }
                                }
                                
                                
                                
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 2) {
                                    Text("DOOR ACCESS")
                                        .font(.custom("Inter-Medium", size: 16))
                                        .foregroundColor(.white)
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                    
                                    Button(action: {
                                        navigateToDoorAddView = true
                                    }) {
                                        HStack {
                                            Image(systemName: "plus")
                                            Text("Add Door")
                                                .font(.custom("Inter-SemiBold", size: 15))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                    }
                                    
                                    // Selected Door List
                                    VStack{
                                        ForEach(selectedDoors) { door in
                                            HStack {
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(door.doorName)
                                                        .foregroundColor(.white)
                                                    if let location = door.location, !location.trimmingCharacters(in: .whitespaces).isEmpty {
                                                        Text(location)
                                                            .foregroundColor(.white.opacity(0.6))
                                                            .font(.system(size: 13))
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                Button {
                                                    selectedDoors.removeAll { $0.id == door.id }
                                                } label: {
//                                                    Image(systemName: "trash")
//                                                        .foregroundColor(.red)
                                                    Image("delete-icon")
                                                        .resizable()
                                                        .renderingMode(.template)
                                                        .foregroundColor(.white)
                                                        .frame(width: 25, height: 25)
                                                }
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.12))
                                            .cornerRadius(12)
                                        }
                                        
                                    }
                                    .padding()
                                    .background(selectedDoors.isEmpty ? Color.white.opacity(0.0) : Color.white.opacity(0.15))
                                    .cornerRadius(10)
                                }
                                .id("DOOR_SECTION")
                                
                                
                            }
                                
                                
                                
                            }.padding(.bottom,10)
                                .sheet(isPresented: $showStartDatePicker) {
                                    pickerSheet(
                                        title: "Select Start Date",
                                        selection: $accessStartDate,
                                        components: .date
                                    ) {
                                        showStartDatePicker = false
                                    }
                                }
                            
                                .sheet(isPresented: $showEndDatePicker) {
                                    pickerSheet(
                                        title: "Select End Date",
                                        selection: $accessEndDate,
                                        components: .date
                                    ) {
                                        showEndDatePicker = false
                                    }
                                }
                            
                            
                             .sheet(isPresented: $showTimePicker) {
                                    pickerSheet(
                                        title: "Select Time",
                                        selection: Binding<Date?>(
                                            get: {
                                                guard let index = selectedTimeIndex else { return nil }
                                                return isSelectingStart ? timeSlots[index].startTime : timeSlots[index].endTime
                                            },
                                            set: { newValue in
                                                guard let index = selectedTimeIndex else { return }
                                                if isSelectingStart {
                                                    timeSlots[index].startTime = newValue
                                                } else {
                                                    timeSlots[index].endTime = newValue
                                                }
                                            }
                                        ),
                                        components: .hourAndMinute
                                    ) {
                                        showTimePicker = false
                                    }
                                }
                            
                            
                            
                        }
                        .frame(maxHeight: .infinity)
                        .keyboardAware()
                        .onChange(of: shouldScrollToDoorSection) { value in
                            if value {
                                withAnimation {
                                    proxy.scrollTo("DOOR_SECTION", anchor: .top)
                                }
                                shouldScrollToDoorSection = false
                            }
                        }
                        
                        .onChange(of: openSection) { value in
                            if value == 0 {   // same id you passed
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation {
                                        proxy.scrollTo("ACCESS_GROUP_SECTION", anchor: .top)
                                    }
                                }
                            }
                        }
                    
                    }
                }
                .padding(.horizontal,10)
                .padding(.bottom, 110)
                
                VStack(spacing: 16) {
                    // Buttons
                    VStack(spacing: 10) {
                        Button {
                            
                            
                            CreateUserApiCall()
                            
                           
                        } label: {
                            Text("Save")
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.custom("Inter-SemiBold", size: 16))
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        
                        
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(.white)
                                
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
                
                // LOADING OVERLAY
                if addUserVM.isLoading || isInitialLoading || generateNFCID.isLoading{
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                }
                
                
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToUserManagement) {
            UserManagementView()
        }
        .navigationDestination(isPresented: $navigateToDoorAddView) {
            DoorAccessView(
                selectedDoors: $selectedDoors,
                doorListVM: doorListVM
            )
            .onDisappear {
                shouldScrollToDoorSection = true
            }
        }
        
        .onAppear {
            guard !hasInitialized else { return }
               hasInitialized = true
            Task {
                
                isInitialLoading = true
                await getAccessGroupVM.getAccessGroupList()
                await doorListVM.getDoorList(force: true)
                
                
                if let user = editUser {
                    
                    fullName = user.full_name
                    phone = user.phone_number ?? ""
                    nfcId = user.nfc_digital ?? ""
                    email =  user.email
                    username = user.username ?? ""
                    
                    nfcType = user.nfc_type
                    

                    
                    if nfcType == "DIGITAL" {
                        isSelectMobileAPP = true
                        isSelectKeyFob = false
                        
                        
                    } else if nfcType == "PHYSICAL" {
                        isSelectMobileAPP = false
                        isSelectKeyFob = true
                        
                    }
                    else if nfcType == "BOTH" {
                        isSelectMobileAPP = true
                        isSelectKeyFob = true
                        
                    }
                    
                    digitalAccess =  user.is_digital
                    remoteAccess =  user.is_remote
                    isSharedLink = user.is_shared_link 
                    
                    isEditModeLoaded = true
                    
                    nfcPhysicalNumber = user.nfc_physical ?? ""
                    nfcId = user.nfc_digital ?? ""
                    
                    if user.creation_method == "door_selection" {
                        isSelectAccessGroup = false
                        isSelectDoor = true
                    } else{  // access_group
                        isSelectAccessGroup = true
                        isSelectDoor = false
                    }
                    
                    
//                    if user.creation_method == "access_group",
//                       let firstGroup = user.access_groups_detail.first {
//                        
//                        selectedAccessGroup = AccessGroupItem(
//                            id: firstGroup.access_group_id,
//                            name: firstGroup.access_group_name,
//                            description: nil,
//                            doors: user.doors
//                        )
//                    }
                    
                    if user.creation_method == "access_group" {

                        selectedAccessGroups = user.access_groups_detail.map {
                            AccessGroupItem(
                                id: $0.access_group_id,
                                name: $0.access_group_name,
                                description: nil,
                                doors: user.doors
                            )
                        }
                    }
                    
                    
                    if user.creation_method == "door_selection" {
                        
                        if user.schedule_type == "schedule"{
                            isOneTimeAccess = false
                            isScheduledAccess = true
                        }else{
                            isOneTimeAccess = true
                            isScheduledAccess = false
                        }
                        
                        if let startDateString = user.start_date {
                            accessStartDate = apiDateFormatter.date(from: startDateString)
                        }
                        
                        if let endDateString = user.end_date {
                            accessEndDate = apiDateFormatter.date(from: endDateString)
                        }
                        
                        
                        // Set time slots from backend
                        if !user.time_slots.isEmpty {
                            
                            timeSlots = user.time_slots.map { slot in
                                TimeSlotUI(
                                    startTime: apiTimeFormatter.date(from: slot.start_time),
                                    endTime: apiTimeFormatter.date(from: slot.end_time)
                                )
                            }
                            
                            // Safety: max 3
                            if timeSlots.count > 3 {
                                timeSlots = Array(timeSlots.prefix(3))
                            }
                            
                        } else {
                            timeSlots = [TimeSlotUI()]
                        }
                        
                        if user.schedule_type == "schedule"{
                            if let weekDays = user.week_days {
                                selectedWeekdays = Set(
                                    weekDays
                                        .split(separator: ",")
                                        .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                                )
                            }
                            
                        }
                        
                        selectedDoors = doorListVM.doorList.filter {
                            user.doors.contains($0.id)
                        }
                        
                        print("selectedDoors is :\(selectedDoors)")
                        
                    }
                }
                else {
                    handleNfcGeneration()
                }
                
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                isInitialLoading = false
                
                
               
                
            }
            
           
        }
        
        .onChange(of: phone) { newValue in
            // keep only digits
            let filtered = newValue.filter { $0.isNumber }
            
            // limit to 10 digits
            if filtered.count <= 10 {
                phone = filtered
            } else {
                phone = String(filtered.prefix(10))
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        }
        
        .onDisappear {
            onDismiss?()
        }
        
        .internetOverlay()

        .modernAlert(
                isPresented: Binding(
                    get: { showAddUserVMError && !addUserVM.isFailedDueToNoInternet },
                    set: { showAddUserVMError = $0 }
                )
            ) {
                ModernAlertView(
                    title: "Error!",
                    message: addUserVM.errorMessage ?? "Something went wrong!",
                    isSuccess: false,
                    buttonTitle: "OK"
                ) {
                    showAddUserVMError = false
                }
        }
        
            .modernAlert(isPresented: $showAddUserSuccess) {
                ModernAlertView(
                    title: "Success!",
                    message:  editUser != nil ? "User Update Successfully" : "User Created successfully",
                    isSuccess: true,
                    buttonTitle: "OK"
                ) {
                    showAddUserSuccess = false
                    addUserVM.Successflag = false
                    dismiss()
                }
            }
        
            .modernAlert(
                    isPresented: Binding(
                        get: { showAccessGroupVMError && !getAccessGroupVM.isFailedDueToNoInternet },
                        set: { showAccessGroupVMError = $0 }
                    )
                ) {
                    ModernAlertView(
                        title: "Error!",
                        message: getAccessGroupVM.errorMessage ?? "Something went wrong!",
                        isSuccess: false,
                        buttonTitle: "OK"
                    ) {
                        showAccessGroupVMError = false
                    }
            }
        
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
    }
    private let apiDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()

    private let apiTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    func toggleDay(_ day: Int) {
        if selectedWeekdays.contains(day) {
            selectedWeekdays.remove(day)
        } else {
            selectedWeekdays.insert(day)
        }
    }
    
    
    func updateNfcType() {
        
    
       
        if isSelectMobileAPP && !isSelectKeyFob{
            nfcType = "DIGITAL"
//            digitalAccess = false
//            remoteAccess = false
            handleNfcGeneration()
        }
        else if !isSelectMobileAPP && isSelectKeyFob{
            nfcType = "PHYSICAL"
//            digitalAccess = false
//            remoteAccess = false
        }
        else if isSelectMobileAPP && isSelectKeyFob{
            nfcType = "BOTH"
//            digitalAccess = false
//            remoteAccess = false
            handleNfcGeneration()
        }
        
        print("nfctype : \(nfcType)")
    }
   
    func validateForm() -> String? {
        
        guard let userId = UserDefaults.standard.string(forKey: "user_id"),
                  !userId.trimmingCharacters(in: .whitespaces).isEmpty else {
                return "User session expired. Please login again."
            }

        if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Full name is required"
        }
        

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Email is required"
        }

        if !isValidEmail(email) {
            return "Please enter a valid email address"
        }

        
        if !isSelectMobileAPP && !isSelectKeyFob && !isSharedLink{
            return "Please select at least one device access method"
        }
    
        if isSelectMobileAPP
        {
            if !digitalAccess && !remoteAccess {
                return "Please select at least one mobile app options (Phone Tap or Remote)"
            }
            
            if nfcId.trimmingCharacters(in: .whitespaces).isEmpty {
                return "Digital Card ID is not generated"
            }
        }
        
        if isSelectKeyFob {
            if nfcPhysicalNumber.trimmingCharacters(in: .whitespaces).isEmpty {
                return "Physical Key Fob ID is required"
            }
        }
        
        
        if isSelectDoor {
            
            if accessStartDate == nil || accessEndDate == nil {
                return "Please select access start and end date"
            }
            
            if let start = accessStartDate,
               let end = accessEndDate,
               end < start {
                return "End date must be later than or same as start date"
            }
            
            
            if timeSlots.contains(where: { $0.startTime == nil || $0.endTime == nil }) {
                return "Please fill a time slots"
            }
            
           
            // 1️⃣ Validate start & end (allow overnight)
            let calendar = Calendar.current

            let normalizedSlots: [(start: Date, end: Date)] = timeSlots.compactMap { slot in
                guard let start = slot.startTime,
                      let end = slot.endTime else { return nil }
                
                var adjustedStart = start
                var adjustedEnd = end
                
                // 👉 Handle overnight (e.g. 11 PM → 2 AM)
                if end <= start {
                    adjustedEnd = calendar.date(byAdding: .day, value: 1, to: end)!
                }
                
                return (adjustedStart, adjustedEnd)
            }


            // 2️⃣ Sort by start time
            let sortedSlots = normalizedSlots.sorted { $0.start < $1.start }


            // 3️⃣ Check overlap
            for i in 0..<sortedSlots.count - 1 {
                let current = sortedSlots[i]
                let next = sortedSlots[i + 1]

                if current.end > next.start {
                    return "Time slots cannot overlap."
                }
            }
            


            
            if isScheduledAccess {
                if selectedWeekdays.isEmpty {
                    return "Please select at least one repeat day"
                }
            }
            
            if selectedDoors.isEmpty {
                return "Please select at least one door"
            }
        }
        
//        if isSelectAccessGroup {
//            if selectedAccessGroup == nil {
//                    return "Please select an access group"
//            }
//        }
        if isSelectAccessGroup {
            if selectedAccessGroups.isEmpty {
                return "Please select at least one access group"
            }
        }

        return nil // All good
    }
    
    func handleNfcGeneration() {
        
        // If already exists → don't regenerate
        if !nfcId.trimmingCharacters(in: .whitespaces).isEmpty {
            return
        }
        
        Task {
            await generateNfcId()
        }
    }
    
    func generateNfcId() async {
        await generateNFCID.generateNfcId()
        
        if let id = generateNFCID.nfcCardId {
            nfcId = String(id)
        }
    }
    
    func CreateUserApiCall(){
        if let error = validateForm() {
                addUserVM.errorMessage = error
                showAddUserVMError = true
                return
            }
        
       
        //  Safe unwrap (validation already ensured this exists)
            guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
                addUserVM.errorMessage = "User session expired. Please login again."
                showAddUserVMError = true
                return
            }
        
        Task {
          
            let isEditMode = editUser != nil

//            let timeSlots: [TimeSlot] = {
//                guard let start = accessStartTime,
//                      let end = accessEndTime else {
//                    return []
//                }
//                return [
//                    TimeSlot(
//                        start_time: start.toAPITime(),
//                        end_time: end.toAPITime()
//                    )
//                ]
//            }()
            
            
            let apiTimeSlots: [TimeSlot] = timeSlots.compactMap { slot in
                if let start = slot.startTime,
                   let end = slot.endTime {
                    return TimeSlot(
                        start_time: start.toAPITime(),
                        end_time: end.toAPITime()
                    )
                }
                return nil
            }
            
            let weekDaysString: String? = isScheduledAccess
                ? selectedWeekdays
                    .sorted()
                    .map(String.init)
                    .joined(separator: ", ")
                : ""
        
            
            let request = AddUserRequest(
                user_id: isEditMode ? nil : userId,
                id: isEditMode ? editUser?.id : nil, // for edit
                username: isEditMode ? username : email,
                password: isEditMode ? "" : password,
                full_name: fullName,
                email: email,
                phone_number: phone,
                user_type: "non_staff",
                

                // Access
                
                is_digital: (isSelectMobileAPP && digitalAccess) ? true : false,
                is_remote: (isSelectMobileAPP && remoteAccess) ? true : false,
                // NFC
                nfc_type: nfcType,
                nfc_physical: isSelectKeyFob  ? nfcPhysicalNumber : "",
                nfc_digital: isSelectMobileAPP  ? nfcId : "",

                // Doors
                doors: isSelectDoor ? selectedDoors.map { $0.id } : [],

                //access group
//                access_groups: isSelectAccessGroup ? (selectedAccessGroup != nil ? [selectedAccessGroup!.id] : nil)  : [],
                
                access_groups: isSelectAccessGroup ? selectedAccessGroups.map { String($0.id) } : [],
                
                // Schedule
                start_date: isSelectDoor ? accessStartDate?.toAPIDate() : "",
                end_date: isSelectDoor ?  accessEndDate?.toAPIDate() : "",
                time_slots:  isSelectDoor ?  apiTimeSlots : [],
                week_days: isSelectDoor ?  weekDaysString : "",


                // Meta
                source: "app",
                is_mqtt_sync: true,
                is_shared_link: isSharedLink,
                creation_method: isSelectDoor ? "door_selection" : "access_group",
                schedule_type: isSelectDoor ? (isOneTimeAccess ? "one_time" : "schedule") : ""
            )

            await addUserVM.addUser(request: request,isEditUser: isEditMode)
            
            if addUserVM.Successflag{
                resetForm()
                showAddUserSuccess = true
            }else{
              //  resetForm()
                showAddUserVMError = true
            }
        }
    }
    
//    func resetForm() {
//        fullName = ""
//        email = ""
//        username = ""
//        password = ""
//        phone = ""
//        nfcId = ""
//
//        digitalAccess = false
//        remoteAccess = false
//
//        isOneTimeAccess = true
//        isScheduledAccess = false
//
//        accessStartDate = nil
//        accessEndDate = nil
//        accessStartTime = nil
//        accessEndTime = nil
//
//        selectedWeekdays.removeAll()
//        selectedDoors.removeAll()
//
//        shouldScrollToDoorSection = false
//    }
    
    func resetForm() {
        
        // MARK: - User Info
        fullName = ""
        email = ""
        username = ""
        password = ""
        phone = ""
        nfcId = ""
        
        // MARK: - Access Mode
        digitalAccess = false
        remoteAccess = false
        
        // Reset to default mode → Access Group
        isSelectAccessGroup = true
        isSelectDoor = false
        
        // MARK: - Schedule Type
        isOneTimeAccess = true
        isScheduledAccess = false
        
        // MARK: - Dates & Time
        accessStartDate = nil
        accessEndDate = nil
//        accessStartTime = nil
//        accessEndTime = nil
        
        timeSlots = [TimeSlotUI()]
        
        
        // MARK: - Weekdays
        selectedWeekdays.removeAll()
        
        // MARK: - Doors
        selectedDoors.removeAll()
        
        // MARK: - Access Group
//        selectedAccessGroup = nil
        selectedAccessGroups.removeAll()
        openSection = nil
        
        // MARK: - Scroll
        shouldScrollToDoorSection = false
    }

    
    @ViewBuilder
    func pickerSheet(
        title: String,
        selection: Binding<Date?>,
        components: DatePickerComponents,
        onDone: @escaping () -> Void
    ) -> some View {

        // Local mutable value
        let internalDate = Binding<Date>(
            get: {
                selection.wrappedValue ?? Date()
            },
            set: { newValue in
                selection.wrappedValue = newValue
            }
        )

        VStack(spacing: 20) {

            Text(title)
                .font(.headline)

//            DatePicker(
//                "",
//                selection: internalDate,
//                displayedComponents: components
//            )
//            .datePickerStyle(.wheel)
//            .labelsHidden()
            
            
            DatePicker(
                "",
                selection: internalDate,
                displayedComponents: components
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "en_US"))

            Button("Done") {
                if selection.wrappedValue == nil {
                    selection.wrappedValue = internalDate.wrappedValue
                }
                onDone()   // selection already updated
            }
        }
        .presentationDetents([.height(350)])
    }




}


struct LabeledTextField: View {

    let title: String
    let placeholder: String
    var isRequired: Bool = false
    @Binding var text: String
    var isSecure: Bool = false
    var isHaveBtn: Bool = false
    @State private var isGeneratingNfc = false
    @StateObject private var generateNfcVm = GenerateUniqueNfcViewModel()
    @State private var isPasswordVisible: Bool = false   // 👈 NEW
    @State private var showGenerateNfcVmError = false
    @State private var showGenerateButton: Bool = false   // 👈 NEW
    var keyboardType: UIKeyboardType = .default
    var isEditMode: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Title
            HStack(spacing: 2) {
                Text(title)
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.white)

                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
                 Spacer()
            
                
                if isHaveBtn && showGenerateButton{
                    Button {
                        generateNfc()
                    } label: {
                        ZStack {
                            if isGeneratingNfc {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(.white)
                            } else {
                                Text("Generate")
                                    .foregroundColor(.white)
                                    .font(.system(size: 13, weight: .medium))
                            }
                        }
                        .frame(height: 22)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.12))   // 👈 gives contrast
                        .cornerRadius(14)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.leading,10)
                    .disabled(isGeneratingNfc)
                }



            }
            
        
            

            // Field
            ZStack(alignment: .leading) {

                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color.white.opacity(0.5))
                        .font(.custom("Inter-Regular", size: 16))
                        .padding(.leading, 14)
                }

                HStack {

                    // Input
                    Group {
                        if isSecure && !isPasswordVisible {
                            SecureField("", text: $text)
                        } else {
                            TextField("", text: $text)
                                .submitLabel(.next)
                        }
                    }
                    .keyboardType(keyboardType)
                    .foregroundColor(.white)
                    .font(.custom("Inter-Regular", size: 16))
                    .disabled(isHaveBtn)
                    .opacity(isHaveBtn ? 0.7 : 1)

                    // 👁 Eye Button
                    if isSecure {
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.trailing, 10)
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 50)
            }
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
    
        
        .onAppear {
            guard isHaveBtn else { return }

            if isEditMode {
                //  Edit mode → never auto-generate
                showGenerateButton = false
            } else {
                //  Add mode → auto-generate
                generateNfc()
                showGenerateButton = false
            }
        }

        .onReceive(generateNfcVm.$nfcCardId) { value in
            if let value {
                text = String(value)
            }
        }
        .onReceive(generateNfcVm.$errorMessage) { msg in
            if msg != nil {
                showGenerateNfcVmError = true
            }
        }
        .modernAlert(
                isPresented: Binding(
                    get: { showGenerateNfcVmError && !generateNfcVm.isFailedDueToNoInternet },
                    set: { showGenerateNfcVmError = $0 }
                )
            ) {
                ModernAlertView(
                    title: "Error!",
                    message: generateNfcVm.errorMessage ?? "Something went wrong!",
                    isSuccess: false,
                    buttonTitle: "OK"
                ) {
                    showGenerateNfcVmError = false
                }
        }

    }
    
    private func generateNfc() {
        
        Task {
                isGeneratingNfc = true
                showGenerateButton = false

                await generateNfcVm.generateNfcId()

                isGeneratingNfc = false

                if let id = generateNfcVm.nfcCardId {
                    text = String(id)
                    showGenerateButton = false     // success → keep hidden
                } else {
                    showGenerateButton = true      // failed → show button
                }
            }
    }

}


struct CheckBoxView: View {

    let title: String
    @Binding var isChecked: Bool
    var isDisable:  Bool = false

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack{

                Text(title)
                    .foregroundColor(isDisable ? .white.opacity(0.8) : .white)
                    .font(.custom("Inter-Regular", size: 15))
                
                Spacer()
                if isDisable {
                    Image( isChecked ? "gray_check" : "square-uncheck")
                        .resizable()
                        .frame(width: 22, height: 22)
                }else{
                    Image( isChecked ? "square-check" : "square-uncheck")
                        .resizable()
                        .frame(width: 22, height: 22)
                }

                
            }
        }
    }
}

struct AccessTypeRow: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {

                Text(title)
                    .foregroundColor(.white)
                    .font(.custom("Inter-Regular", size: 15))

                Spacer()

                Image(isSelected
                      ? "radio-checked"
                      : "radio-unchecked")
                    .resizable()
                    .frame(width: 22, height: 22)
            }
        }
    }
}



func dateBox(
    title: String,
    value: Date?,
    action: @escaping () -> Void
) -> some View {

    VStack(alignment: .leading, spacing: 6) {

        Text(title)
            .foregroundColor(.white)
            .font(.custom("Inter-Regular", size: 15))

        Button(action: action) {
            HStack {
                Image("calendar")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(
                    value == nil
                    ? "Select Date"
                    : mmddyyFormatter.string(from: value!)
                )
                .font(.custom("Inter-Regular", size: 15))
                .foregroundColor(value == nil ? .white.opacity(0.5) : .white)

                Spacer()
            }
            .padding()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
    }
}
private let mmddyyFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "MM/dd/YYYY"
    df.locale = Locale(identifier: "en_US_POSIX") // 🔒 stable format
    return df
}()

private let amPmFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "hh:mm a"
    df.locale = Locale(identifier: "en_US_POSIX")
    return df
}()


func timeBox(
    title: String,
    value: Date?,
    action: @escaping () -> Void
) -> some View {

    VStack(alignment: .leading, spacing: 6) {

        Text(title)
            .foregroundColor(.white)
            .font(.custom("Inter-Regular", size: 15))

        Button(action: action) {
            HStack {
                Image("clock")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(
                    value == nil
                    ? "Select Time"
                    : /*value!.formatted(date: .omitted, time: .shortened)*/
                    amPmFormatter.string(from: value!)
                )
                .font(.custom("Inter-Regular", size: 15))
                .foregroundColor(value == nil ? .white.opacity(0.5) : .white)

                Spacer()
            }
            .padding()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
    }
}


// Day Pill
struct DayPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.white.opacity(0.15))
                .cornerRadius(8)
        }
    }
}

// Short Day Name
func shortDay(_ day: Int) -> String {
    ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][day - 1]
}



//struct AccessGroupDropDown: View {
//    
//    let id: Int
//    let options: [AccessGroupItem]
//    
//    @Binding var selectedGroup: AccessGroupItem?
//    @Binding var openSection: Int?
//    
//    private var isOpen: Bool {
//        openSection == id
//    }
//    
//    var body: some View {
//        
//        VStack(alignment: .leading, spacing: 10) {
//            
//            HStack(spacing: 2) {
//                Text("Door Access Group")
//                    .font(.custom("Inter-Medium", size: 16))
//                    .foregroundColor(.white)
//                Text("*")
//                    .foregroundColor(.red)
//            }
//            
//            // 🔹 Dropdown Button
//            Button {
//                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
//                    openSection = isOpen ? nil : id
//                }
//            } label: {
//                HStack {
//                    
//                    Text(selectedGroup?.name ?? "Select Access Group")
//                        .foregroundColor(selectedGroup == nil ? .white.opacity(0.6) : .white)
//                        .font(.custom("Inter-Regular", size: 14))
//                    
//                    Spacer()
//                    
//                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
//                        .foregroundColor(.white.opacity(0.8))
//                }
//                .padding()
//                .background(Color.white.opacity(0.2))
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//            }
//            
//            //  Dropdown List
//            if isOpen {
//                VStack(spacing: 0) {
//                    ForEach(options) { item in
//                        
//                        Button {
//                            selectedGroup = item
//                            withAnimation {
//                                openSection = nil
//                            }
//                        } label: {
//                            HStack {
//                                Text(item.name)
//                                    .foregroundColor(.white)
//                                    .font(.custom("Inter-Regular", size: 14))
//                                
//                                Spacer()
//                                
//                                if selectedGroup?.id == item.id {
//                                    Image(systemName: "checkmark")
//                                        .foregroundColor(.green)
//                                }
//                            }
//                            .padding(.vertical, 10)
//                            .padding(.horizontal, 12)
//                        }
//                        
//                        Divider()
//                            .overlay(Color.white.opacity(0.08))
//                    }
//                }
//                .background(Color.gray.opacity(0.2))
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .transition(.opacity)
//                .padding(.top, -9)
//            }
//        }
//    }
//}


struct AccessGroupDropDown: View {

    let id: Int
    let options: [AccessGroupItem]

    @Binding var selectedGroups: [AccessGroupItem]
    @Binding var openSection: Int?

    private var isOpen: Bool {
        openSection == id
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 2) {
                Text("Door Access Group")
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.white)

                Text("*")
                    .foregroundColor(.red)
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    openSection = isOpen ? nil : id
                }
            } label: {

                HStack {

                    Text(
                        selectedGroups.isEmpty
                        ? "Select Access Group"
                        : selectedGroups.map { $0.name }.joined(separator: ", ")
                    )
                    .foregroundColor(
                        selectedGroups.isEmpty
                        ? .white.opacity(0.6)
                        : .white
                    )
                    .font(.custom("Inter-Regular", size: 14))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if isOpen {

                VStack(spacing: 0) {

                    ForEach(options) { item in

                        Button {

                            if selectedGroups.contains(where: { $0.id == item.id }) {

                                selectedGroups.removeAll { $0.id == item.id }

                            } else {

                                selectedGroups.append(item)
                            }

                        } label: {

                            HStack {

                                Text(item.name)
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Regular", size: 14))

                                Spacer()

                                Image(
                                    systemName: selectedGroups.contains(where: { $0.id == item.id })
                                    ? "checkmark.square.fill"
                                    : "square"
                                )
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.green)
                                
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal, 12)
                        }

                        Divider()
                            .overlay(Color.white.opacity(0.08))
                    }
                }
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity)
                .padding(.top, -9)
            }
        }
    }
}

struct TimeSlotUI: Identifiable {
    let id = UUID()
    var startTime: Date? = nil
    var endTime: Date? = nil
}
