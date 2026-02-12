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
    @StateObject private var getAccessGroupVM = GetAccessGroupListViewModel()
    @State private var showAddUserVMError = false
    @State private var showAccessGroupVMError = false
    @State private var showAddUserSuccess = false
    @State private var navigateToUserManagement = false
    @State private var navigateToDoorAddView = false
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var username = "sourav"
    @State private var password = "Jyoti@123"
    @State private var phone = ""
    @State private var nfcId = ""
   
    @State private var digitalAccess = true
    @State private var remoteAccess = false


    @State private var isOneTimeAccess: Bool = true
    @State private var isScheduledAccess: Bool = false
    
    @State private var isSelectAccessGroup: Bool = true
    @State private var isSelectDoor: Bool = false

    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    
    @State private var accessStartTime: Date? = nil
    @State private var accessEndTime: Date? = nil
    
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    
    @State private var accessStartDate: Date? = nil
    @State private var accessEndDate: Date? = nil


    @State private var selectedWeekdays: Set<Int> = []   // 1 = Sun ... 7 = Sat

    @State private var selectedDoors: [SingleDoor] = []
    @StateObject private var doorListVM = GetAllDoorListViewModel()

    @State private var shouldScrollToDoorSection = false

    
    @State private var selectedAccessGroup: AccessGroupItem? = nil
    @State private var openSection: Int? = nil
    
    @State private var hasInitialized = false
    
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
                                
                                
                                
                                LabeledTextField(
                                    title: "Email ID",
                                    placeholder: "Enter email",
                                    isRequired: true,
                                    text: $email,
                                    
                                )
                                
                                LabeledTextField(
                                    title: "Phone Number",
                                    placeholder: "Enter phone",
                                    text: $phone,
                                    keyboardType: .numberPad
                                    
                                )
                                
                                LabeledTextField(
                                    title: "NFC Card ID",
                                    placeholder: "Generate NFC Card Id",
                                    isRequired: true,
                                    text: $nfcId,
                                    isHaveBtn: true,
                                    isEditMode: editUser != nil
                                    
                                )
                                
                                
                                
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 2) {
                                        Text("DEVICE ACCESS")
                                            .font(.custom("Inter-Medium", size: 16))
                                            .foregroundColor(.white)
                                        
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(spacing: 20) {
                                        
                                        // Digital
                                        CheckBoxView(
                                            title: "Digital",
                                            isChecked: $digitalAccess
                                        )
                                        
                                        // Remote
                                        CheckBoxView(
                                            title: "Remote",
                                            isChecked: $remoteAccess
                                        )
                                    }
                                    .padding(12)
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
                                        
                                        // Schedule
                                        AccessTypeRow(
                                            title: "Select Access group",
                                            isSelected: isSelectAccessGroup
                                        ) {
                                            isSelectAccessGroup = true
                                            isSelectDoor = false
                                        }
                                        
                                        // One Time
                                        AccessTypeRow(
                                            title: "Select Doors",
                                            isSelected: isSelectDoor
                                        ) {
                                            isSelectAccessGroup = false
                                            isSelectDoor = true
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(12)
                                }
                                
                                if isSelectAccessGroup {
                                    
                                    AccessGroupDropDown(
                                        id: 0,
                                        options: getAccessGroupVM.accessGroupList,
                                        selectedGroup: $selectedAccessGroup,
                                        openSection: $openSection
                                    )
                                    
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
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                    VStack(alignment: .leading, spacing: 16) {
                                        // From
                                        timeBox(
                                            title: "Start Time",
                                            value: accessStartTime,
                                            action: {
                                                showStartTimePicker = true
                                            }
                                        )
                                        
                                        // To
                                        timeBox(
                                            title: "End Time",
                                            value: accessEndTime,
                                            action: {
                                                showEndTimePicker = true
                                                
                                            }
                                        )
                                    }
                                    .padding()
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
                                            columns: [
                                                GridItem(.flexible()),
                                                GridItem(.flexible()),
                                                GridItem(.flexible()),
                                                GridItem(.flexible())
                                            ],
                                            spacing: 15
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
                                        .padding()   // ✅ indent
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
                                    
                                    // ✅ Selected Door List
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
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.red)
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
                            
                                .sheet(isPresented: $showStartTimePicker) {
                                    pickerSheet(
                                        title: "Select Start Time",
                                        selection: $accessStartTime,
                                        components: .hourAndMinute
                                    ) {
                                        showStartTimePicker = false
                                    }
                                }
                            
                                .sheet(isPresented: $showEndTimePicker) {
                                    pickerSheet(
                                        title: "Select End Time",
                                        selection: $accessEndTime,
                                        components: .hourAndMinute
                                    ) {
                                        showEndTimePicker = false
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
                if addUserVM.isLoading || getAccessGroupVM.isLoading{
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
                await getAccessGroupVM.getAccessGroupList()
                await doorListVM.getDoorList(force: true)
                
                
                guard let user = editUser else { return }
                
                fullName = user.full_name
                phone = user.phone_number
                nfcId = user.nfc_digital ?? ""
                email =  user.email
                
                digitalAccess =  user.is_digital
                remoteAccess =  user.is_remote
                
                if user.creation_method == "door_selection" {
                    isSelectAccessGroup = false
                    isSelectDoor = true
                } else{  // access_group
                    isSelectAccessGroup = true
                    isSelectDoor = false
                }
                
                
                if user.creation_method == "access_group",
                   let firstGroup = user.access_groups_detail.first {
                    
                    selectedAccessGroup = AccessGroupItem(
                        id: firstGroup.access_group_id,
                        name: firstGroup.access_group_name,
                        description: nil,
                        doors: user.doors
                    )
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
                    
                    if let firstSlot = user.time_slots.first {
                        
                        if let startTime = apiTimeFormatter.date(from: firstSlot.start_time) {
                            accessStartTime = startTime
                        }
                        
                        if let endTime = apiTimeFormatter.date(from: firstSlot.end_time) {
                            accessEndTime = endTime
                        }
                    }
                    
                    if let weekDays = user.week_days {
                        selectedWeekdays = Set(
                            weekDays
                                .split(separator: ",")
                                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                        )
                    }
                    
                    
                    selectedDoors = doorListVM.doorList.filter {
                        user.doors.contains($0.id)
                    }
                    
                    print("selectedDoors is :\(selectedDoors)")
                    
                }
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
   
    func validateForm() -> String? {
        
        guard let userId = UserDefaults.standard.string(forKey: "user_id"),
                  !userId.trimmingCharacters(in: .whitespaces).isEmpty else {
                return "User session expired. Please login again."
            }

        if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Full name is required"
        }
        
        if phone.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Phone number is required"
        }

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Email is required"
        }

        if !isValidEmail(email) {
            return "Please enter a valid email address"
        }

        if nfcId.trimmingCharacters(in: .whitespaces).isEmpty {
            return "NFC Card ID is required"
        }

        if !digitalAccess && !remoteAccess {
            return "Please select at least one device access (Digital or Remote)"
        }
        
        if isSelectDoor {
            
            if accessStartDate == nil || accessEndDate == nil {
                return "Please select access start and end date"
            }
            
            if accessStartTime == nil || accessEndTime == nil {
                return "Please select access start and end time"
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
        
        if isSelectAccessGroup {
            if selectedAccessGroup == nil {
                    return "Please select an access group"
            }
        }

        return nil // All good
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

            let timeSlots: [TimeSlot] = {
                guard let start = accessStartTime,
                      let end = accessEndTime else {
                    return []
                }
                return [
                    TimeSlot(
                        start_time: start.toAPITime(),
                        end_time: end.toAPITime()
                    )
                ]
            }()
            
            
            let weekDaysString: String? = isScheduledAccess
                ? selectedWeekdays
                    .sorted()
                    .map(String.init)
                    .joined(separator: ", ")
                : ""
        
            
            let request = AddUserRequest(
                user_id: isEditMode ? nil : userId,
                id: isEditMode ? editUser?.id : nil, // for edit
                username: username,
                password: password,
                full_name: fullName,
                email: email,
                phone_number: phone,
                user_type: "non_staff",

                // Access
                is_digital: digitalAccess,
                is_remote: remoteAccess,

                // NFC
                nfc_type: "DIGITAL",
                nfc_physical: "",
                nfc_digital: nfcId,

                // Doors
                doors: isSelectDoor ? selectedDoors.map { $0.id } : [],

                //access group
                access_groups: isSelectAccessGroup ? (selectedAccessGroup != nil ? [selectedAccessGroup!.id] : nil)  : [],
                
                // Schedule
                start_date: isSelectDoor ? accessStartDate?.toAPIDate() : "",
                end_date: isSelectDoor ?  accessEndDate?.toAPIDate() : "",
                time_slots:  isSelectDoor ?  timeSlots : [],
                week_days: isSelectDoor ?  weekDaysString : "",


                // Meta
                source: "app",
                is_mqtt_sync: true,
                creation_method: isSelectDoor ? "door_selection" : "access_group",
                schedule_type: isSelectDoor ? (isOneTimeAccess ? "one_time" : "schedule") : ""
            )

            await addUserVM.addUser(request: request,isEditUser: isEditMode)
            
            if addUserVM.Successflag{
                resetForm()
                showAddUserSuccess = true
            }else{
                resetForm()
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
        accessStartTime = nil
        accessEndTime = nil
        
        // MARK: - Weekdays
        selectedWeekdays.removeAll()
        
        // MARK: - Doors
        selectedDoors.removeAll()
        
        // MARK: - Access Group
        selectedAccessGroup = nil
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

            DatePicker(
                "",
                selection: internalDate,
                displayedComponents: components
            )
            .datePickerStyle(.wheel)
            .labelsHidden()

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

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack{

                Text(title)
                    .foregroundColor(.white)
                    .font(.custom("Inter-Regular", size: 15))
                
                Spacer()
                
                Image( isChecked ? "square-check" : "square-uncheck")
                    .resizable()
                    .frame(width: 22, height: 22)

                
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
                    : value!.formatted(date: .omitted, time: .shortened)
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
                .padding(.horizontal, 15)
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



struct AccessGroupDropDown: View {
    
    let id: Int
    let options: [AccessGroupItem]
    
    @Binding var selectedGroup: AccessGroupItem?
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
            
            // 🔹 Dropdown Button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    openSection = isOpen ? nil : id
                }
            } label: {
                HStack {
                    
                    Text(selectedGroup?.name ?? "Select Access Group")
                        .foregroundColor(selectedGroup == nil ? .white.opacity(0.6) : .white)
                        .font(.custom("Inter-Regular", size: 14))
                    
                    Spacer()
                    
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // 🔹 Dropdown List
            if isOpen {
                VStack(spacing: 0) {
                    ForEach(options) { item in
                        
                        Button {
                            selectedGroup = item
                            withAnimation {
                                openSection = nil
                            }
                        } label: {
                            HStack {
                                Text(item.name)
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Regular", size: 14))
                                
                                Spacer()
                                
                                if selectedGroup?.id == item.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                        }
                        
                        Divider()
                            .overlay(Color.white.opacity(0.08))
                    }
                }
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity)
                .padding(.top, -9)
            }
        }
    }
}
