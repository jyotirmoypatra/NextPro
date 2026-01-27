//
//  AddUserView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct AddUserView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var addUserVM = AddUserViewModel()
    @State private var showAddUserVMError = false
    @State private var navigateToUserManagement = false
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var nfcId = ""
   
    @State private var digitalAccess = false
    @State private var remoteAccess = false

    @State private var showAccessTypePicker = false

    @State private var isOneTimeAccess: Bool = true
    @State private var isScheduledAccess: Bool = false

    // One-time
    @State private var showOneTimeDatePicker = false
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    
    @State private var oneTimeDate = Date()
    @State private var oneTimeStartTime = Date()
    @State private var oneTimeEndTime = Date()

    // Scheduled
    @State private var showScheduleStartDatePicker = false
    @State private var showScheduleEndDatePicker = false
    @State private var showScheduleStartTimePicker = false
    @State private var showScheduleEndTimePicker = false

    
    @State private var scheduleStartDate = Date()
    @State private var scheduleEndDate = Date()
    @State private var scheduleStartTime = Date()
    @State private var scheduleEndTime = Date()

    @State private var selectedWeekdays: Set<Int> = []   // 1 = Sun ... 7 = Sat


    
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
                        Text("Add User")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                    
                    
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            
                            LabeledTextField(
                                title: "Full Name",
                                placeholder: "Enter full name",
                                isRequired: true,
                                text: $fullName,
                            )

                            LabeledTextField(
                                title: "Email",
                                placeholder: "Enter email",
                                isRequired: true,
                                text: $email,
                                
                            )

                            LabeledTextField(
                                title: "User Name",
                                placeholder: "Enter username",
                                isRequired: true,
                                text: $username,
                               
                            )

                            LabeledTextField(
                                title: "Password",
                                placeholder: "Enter password",
                                isRequired: true,
                                text: $password,
                                isSecure: true,
                               
                            )

                            LabeledTextField(
                                title: "NFC Card ID",
                                placeholder: "Physical NFC ID",
                                isRequired: true,
                                text: $nfcId,
                               
                            )

                            LabeledTextField(
                                title: "Phone Number",
                                placeholder: "Enter phone",
                                text: $phone,
                               
                            )
                            
                            
                            // Device Access
                            VStack(alignment: .leading, spacing: 10) {

                                Text("Device Access")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)

                                HStack(spacing: 25) {

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
                            }

                            
                            // Access Type Dropdown
                            // Access Type Dropdown
                            VStack(alignment: .leading, spacing: 6) {

                                Text("Selected Access Type")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)

                                Button {
                                    showAccessTypePicker = true
                                } label: {

                                    HStack {

                                        Text(isOneTimeAccess ? "One-time Access" : "Scheduled Access")
                                            .foregroundColor(.white)
                                            .font(.custom("Inter-Regular", size: 16))

                                        Spacer()

                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding(.horizontal, 14)
                                    .frame(height: 50)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(10)
                                }
                            }
                            .confirmationDialog(
                                "Select Access Type",
                                isPresented: $showAccessTypePicker,
                                titleVisibility: .visible
                            ) {

                                Button("One-time Access") {
                                    isOneTimeAccess = true
                                    isScheduledAccess = false
                                }

                                Button("Scheduled Access") {
                                    isOneTimeAccess = false
                                    isScheduledAccess = true
                                }

                                Button("Cancel", role: .cancel) {}
                            }


                            // MARK: - One-time Access Fields
                            if isOneTimeAccess {

                                VStack(alignment: .leading, spacing: 16) {

                                    // Date
                                    VStack(alignment: .leading, spacing: 6) {

                                        Text("Date")
                                            .font(.custom("Inter-Medium", size: 16))
                                            .foregroundColor(.white)

                                        Button {
                                            showOneTimeDatePicker = true
                                        } label: {

                                            HStack {

                                                Text(oneTimeDate.formatted(date: .abbreviated, time: .omitted))
                                                    .foregroundColor(.white)
                                                    .font(.custom("Inter-Regular", size: 16))

                                                Spacer()

                                                Image(systemName: "calendar")
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                            .padding(.horizontal, 14)
                                            .frame(height: 50)
                                            .background(Color.white.opacity(0.15))
                                            .cornerRadius(10)
                                        }
                                    }


                                    .sheet(isPresented: $showOneTimeDatePicker) {
                                        pickerSheet(
                                            title: "Select Date",
                                            selection: $oneTimeDate,
                                            components: .date
                                        ) {
                                            showOneTimeDatePicker = false
                                        }
                                    }



                                    // Time Fields
                                    HStack(spacing: 12) {

                                        // Start Time
                                        VStack(alignment: .leading, spacing: 6) {

                                            Text("Start Time")
                                                .font(.custom("Inter-Medium", size: 16))
                                                .foregroundColor(.white)

                                            Button {
                                                showStartTimePicker = true
                                            } label: {

                                                HStack {

                                                    Text(oneTimeStartTime.formatted(date: .omitted, time: .shortened))
                                                        .foregroundColor(.white)
                                                        .font(.custom("Inter-Regular", size: 16))

                                                    Spacer()

                                                    Image(systemName: "clock")
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                                .padding(.horizontal, 14)
                                                .frame(height: 50)
                                                .background(Color.white.opacity(0.15))
                                                .cornerRadius(10)
                                            }
                                        }

                                        
                                        .sheet(isPresented: $showStartTimePicker) {
                                            pickerSheet(
                                                title: "Select Start Time",
                                                selection: $oneTimeStartTime,
                                                components: .hourAndMinute
                                            ) {
                                                showStartTimePicker = false
                                            }
                                        }
                                        

                                        // End Time
                                        VStack(alignment: .leading, spacing: 6) {

                                            Text("End Time")
                                                .font(.custom("Inter-Medium", size: 16))
                                                .foregroundColor(.white)

                                            Button {
                                                showEndTimePicker = true
                                            } label: {

                                                HStack {

                                                    Text(oneTimeEndTime.formatted(date: .omitted, time: .shortened))
                                                        .foregroundColor(.white)
                                                        .font(.custom("Inter-Regular", size: 16))

                                                    Spacer()

                                                    Image(systemName: "clock")
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                                .padding(.horizontal, 14)
                                                .frame(height: 50)
                                                .background(Color.white.opacity(0.15))
                                                .cornerRadius(10)
                                            }
                                        }

                                        
                                            .sheet(isPresented: $showEndTimePicker) {
                                                pickerSheet(
                                                    title: "Select End Time",
                                                    selection: $oneTimeEndTime,
                                                    components: .hourAndMinute
                                                ) {
                                                    showEndTimePicker = false
                                                }
                                            }
                                    }

                                }
                            }


                            
                            // MARK: - Scheduled Access Fields
                            if isScheduledAccess {

                                VStack(alignment: .leading, spacing: 16) {

                                    // Start Date
                                    VStack(alignment: .leading, spacing: 6) {

                                        Text("Start Date")
                                            .font(.custom("Inter-Medium", size: 16))
                                            .foregroundColor(.white)

                                        Button {
                                            showScheduleStartDatePicker = true
                                        } label: {

                                            HStack {
                                                Text(scheduleStartDate.formatted(date: .abbreviated, time: .omitted))
                                                    .foregroundColor(.white)
                                                    .font(.custom("Inter-Regular", size: 16))

                                                Spacer()

                                                Image(systemName: "calendar")
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                            .padding(.horizontal, 14)
                                            .frame(height: 50)
                                            .background(Color.white.opacity(0.15))
                                            .cornerRadius(10)
                                        }
                                    }
                                    
                                    .sheet(isPresented: $showScheduleStartDatePicker) {
                                        pickerSheet(
                                            title: "Select Start Date",
                                            selection: $scheduleStartDate,
                                            components: .date
                                        ) {
                                            showScheduleStartDatePicker = false
                                        }
                                    }


                                    // End Date
                                    VStack(alignment: .leading, spacing: 6) {

                                        Text("End Date")
                                            .font(.custom("Inter-Medium", size: 16))
                                            .foregroundColor(.white)

                                        Button {
                                            showScheduleEndDatePicker = true
                                        } label: {

                                            HStack {
                                                Text(scheduleEndDate.formatted(date: .abbreviated, time: .omitted))
                                                    .foregroundColor(.white)
                                                    .font(.custom("Inter-Regular", size: 16))

                                                Spacer()

                                                Image(systemName: "calendar")
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                            .padding(.horizontal, 14)
                                            .frame(height: 50)
                                            .background(Color.white.opacity(0.15))
                                            .cornerRadius(10)
                                        }
                                    }
                                    .sheet(isPresented: $showScheduleEndDatePicker) {
                                        pickerSheet(
                                            title: "Select End Date",
                                            selection: $scheduleEndDate,
                                            components: .date
                                        ) {
                                            showScheduleEndDatePicker = false
                                        }
                                    }

                                    // Time Fields
                                    HStack(spacing: 12) {

                                        // Start Time
                                        VStack(alignment: .leading, spacing: 6) {

                                            Text("Start Time")
                                                .font(.custom("Inter-Medium", size: 16))
                                                .foregroundColor(.white)

                                            Button {
                                                showScheduleStartTimePicker = true
                                            } label: {

                                                HStack {
                                                    Text(scheduleStartTime.formatted(date: .omitted, time: .shortened))
                                                        .foregroundColor(.white)

                                                    Spacer()

                                                    Image(systemName: "clock")
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                                .padding(.horizontal, 14)
                                                .frame(height: 50)
                                                .background(Color.white.opacity(0.15))
                                                .cornerRadius(10)
                                            }
                                        }
                                        
                                        
                                        .sheet(isPresented: $showScheduleStartTimePicker) {
                                            pickerSheet(
                                                title: "Select Start Time",
                                                selection: $scheduleStartTime,
                                                components: .hourAndMinute
                                            ) {
                                                showScheduleStartTimePicker = false
                                            }
                                        }

                                        // End Time
                                        VStack(alignment: .leading, spacing: 6) {

                                            Text("End Time")
                                                .font(.custom("Inter-Medium", size: 16))
                                                .foregroundColor(.white)

                                            Button {
                                                showScheduleEndTimePicker = true
                                            } label: {

                                                HStack {
                                                    Text(scheduleEndTime.formatted(date: .omitted, time: .shortened))
                                                        .foregroundColor(.white)

                                                    Spacer()

                                                    Image(systemName: "clock")
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                                .padding(.horizontal, 14)
                                                .frame(height: 50)
                                                .background(Color.white.opacity(0.15))
                                                .cornerRadius(10)
                                            }
                                        }
                                    
                                        .sheet(isPresented: $showScheduleEndTimePicker) {
                                            pickerSheet(
                                                title: "Select End Time",
                                                selection: $scheduleEndTime,
                                                components: .hourAndMinute
                                            ) {
                                                showScheduleEndTimePicker = false
                                            }
                                        }
                                    }

                                    // Weekdays
                                    Text("Repeat On")
                                        .font(.custom("Inter-Medium", size: 16))
                                        .foregroundColor(.white)

                                    LazyVGrid(
                                        columns: [
                                            GridItem(.flexible()),
                                            GridItem(.flexible())
                                        ],
                                        spacing: 12
                                    ) {
                                        ForEach(1...7, id: \.self) { day in
                                            WeekdayCheckBoxRow(
                                                title: fullWeekdayName(day),
                                                isChecked: selectedWeekdays.contains(day)
                                            ) {
                                                toggleDay(day)
                                            }
                                        }
                                    }


                                }
                            }



                            
                        }.padding(.bottom,10)
                    }
                    .frame(maxHeight: .infinity)
                    .keyboardAware()
                }
                .padding(.horizontal,10)
                .padding(.bottom, 100)
                
                VStack(spacing: 16) {
                    // Buttons
                    HStack(spacing: 15) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        
                        Button("Create User") {
                            // submit
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.custom("Inter-SemiBold", size: 16))
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
                
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToUserManagement) {
            UserManagementView()
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
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
    }
    
    
    func toggleDay(_ day: Int) {
        if selectedWeekdays.contains(day) {
            selectedWeekdays.remove(day)
        } else {
            selectedWeekdays.insert(day)
        }
    }
    func fullWeekdayName(_ day: Int) -> String {
        let names = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]
        return names[day-1]
    }

    struct WeekdayCheckBoxRow: View {

        let title: String
        var isChecked: Bool
        var action: () -> Void

        var body: some View {
            Button(action: action) {

                HStack(spacing: 10) {

                    Image(systemName: isChecked
                          ? "checkmark.square.fill"
                          : "square")
                        .foregroundColor(isChecked ? .white : .gray)
                        .font(.system(size: 18))

                    Text(title)
                        .foregroundColor(.white)
                        .font(.custom("Inter-Regular", size: 15))

                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 46)
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
            }
        }
    }
    
    @ViewBuilder
    func pickerSheet(
        title: String,
        selection: Binding<Date>,
        components: DatePickerComponents,
        onDone: @escaping () -> Void
    ) -> some View {

        VStack(spacing: 20) {

            Text(title)
                .font(.headline)

            DatePicker(
                "",
                selection: selection,
                displayedComponents: components
            )
            .datePickerStyle(.wheel)
            .labelsHidden()

            Button("Done") {
                onDone()
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

    @State private var isPasswordVisible: Bool = false   // 👈 NEW

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
                    .foregroundColor(.white)
                    .font(.custom("Inter-Regular", size: 16))

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
    }
}


struct CheckBoxView: View {

    let title: String
    @Binding var isChecked: Bool

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack(spacing: 8) {

                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .white : .gray)
                    .font(.system(size: 18))

                Text(title)
                    .foregroundColor(.white)
                    .font(.custom("Inter-Regular", size: 15))
            }
        }
    }
}
