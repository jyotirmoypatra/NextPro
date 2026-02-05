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
    @State private var navigateToDoorAddView = false
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var nfcId = ""
   
    @State private var digitalAccess = false
    @State private var remoteAccess = false


    @State private var isOneTimeAccess: Bool = true
    @State private var isScheduledAccess: Bool = false

    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    
//    @State private var accessStartTime = Date()
//    @State private var accessEndTime = Date()


    @State private var accessStartTime: Date? = nil
    @State private var accessEndTime: Date? = nil
    
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false

//    @State private var accessStartDate = Date()
//    @State private var accessEndDate = Date()
    
    @State private var accessStartDate: Date? = nil
    @State private var accessEndDate: Date? = nil


    @State private var selectedWeekdays: Set<Int> = []   // 1 = Sun ... 7 = Sat

    @State private var selectedDoors: [DoorModel] = []


    
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
                                title: "Phone Number",
                                placeholder: "Enter phone",
                                text: $phone,
                               
                            )
                            
                            LabeledTextField(
                                title: "Email ID",
                                placeholder: "Enter email",
                                isRequired: true,
                                text: $email,
                                
                            )

                            
                            VStack(alignment: .leading, spacing: 10) {

                                Text("Device Access")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)

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
                            
                            LabeledTextField(
                                title: "NFC Card ID",
                                placeholder: "Generate NFC Card Id",
                                isRequired: true,
                                text: $nfcId,
                                isHaveBtn: true
                                
                            )
                            
                            // ACCESS TYPE
                            VStack(alignment: .leading, spacing: 10) {

                                Text("ACCESS TYPE")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)

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

                                Text("ACCESS DATE")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)

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

                                Text("ACCESS TIME")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
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

                                    Text("REPEAT EVERY")
                                        .font(.custom("Inter-Medium", size: 16))
                                        .foregroundColor(.white)

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


                            
//                            VStack(alignment: .leading, spacing: 12) {
//
//                                Text("DOOR ACCESS")
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .foregroundColor(.white)
//                                Button(action: {
//                                    navigateToDoorAddView = true
//                                }) {
//                                    HStack{
//                                        Image(systemName: "plus")
//                                            .font(.system(size: 15))
//                                            .foregroundColor(.white)
//                                            .fontWeight(.bold)
//                                        
//                                        Text("Add Door")
//                                            .font(.custom("Inter-SemiBold", size: 15))
//                                            .foregroundColor(.white)
//                                    }
//                                    
//                                }
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 14)
//                                        .stroke(
//                                            Color.white.opacity(0.4),
//                                            lineWidth: 1
//                                        )
//                                )
//                                
//                            }
                            
                            
                            VStack(alignment: .leading, spacing: 12) {

                                Text("DOOR ACCESS")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)

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
                                ForEach(selectedDoors) { door in
                                    HStack {

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(door.name)
                                                .foregroundColor(.white)

                                            Text(door.id)
                                                .foregroundColor(.white.opacity(0.6))
                                                .font(.system(size: 13))
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
                            
                            print("-------- USER INFO --------")
                            print("Full Name:", fullName)
                            print("Phone:", phone)
                            print("Email:", email)

                            print("-------- DEVICE ACCESS --------")
                            print("Digital:", digitalAccess)
                            print("Remote:", remoteAccess)

                            print("-------- ACCESS TYPE --------")
                            print("One Time:", isOneTimeAccess)
                            print("Scheduled:", isScheduledAccess)

                            print("-------- ACCESS DATE --------")
                            print("Start Date:", accessStartDate)
                            print("End Date:", accessEndDate)

                            print("-------- ACCESS TIME --------")
                            print("Start Time:", accessStartTime)
                            print("End Time:", accessEndTime)

                            print("-------- REPEAT DAYS --------")
                            let repeatDays = isScheduledAccess ? selectedWeekdays : []
                            print(repeatDays)

                            print("-------- DOOR ACCESS --------")
                            // Later you will replace this with selected doors
                            print("Selected Doors Coming Soon")
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
        .navigationDestination(isPresented: $navigateToDoorAddView) {
            DoorAccessView(selectedDoors: $selectedDoors)
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
   

//    
//    @ViewBuilder
//    func pickerSheet(
//        title: String,
//        selection: Binding<Date>,
//        components: DatePickerComponents,
//        onDone: @escaping () -> Void
//    ) -> some View {
//
//        VStack(spacing: 20) {
//
//            Text(title)
//                .font(.headline)
//
//            DatePicker(
//                "",
//                selection: selection,
//                displayedComponents: components
//            )
//            .datePickerStyle(.wheel)
//            .labelsHidden()
//
//            Button("Done") {
//                onDone()
//            }
//        }
//        .presentationDetents([.height(350)])
//    }
    
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
                
//                if isHaveBtn {
//                    Button {
//                        generateNfc()
//                    } label: {
//                        ZStack {
//                            if isGeneratingNfc {
//                                ProgressView()
//                                    .scaleEffect(0.7)
//                                    .tint(.black)
//                            } else {
//                                Text("Generate")
//                                    .foregroundColor(.black)
//                                    .font(.system(size: 13, weight: .medium))
//                            }
//                        }
//                        .frame(height: 22)
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 4)
//                        .background(Color.white)
//                        .cornerRadius(6)
//                    }
//                    .padding(.leading,10)
//                    .disabled(isGeneratingNfc)
//                }
                
                if isHaveBtn {
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
            await generateNfcVm.generateNfcId()
            isGeneratingNfc = false

            if let id = generateNfcVm.nfcCardId {
                text = String(id)   // 👈 Sets TextField value
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


// Date Field Box
//func dateBox(title: String, value: Date, action: @escaping () -> Void) -> some View {
//    VStack(alignment: .leading, spacing: 6) {
//        Text(title)
//            .foregroundColor(.white)
//            .font(.custom("Inter-Regular", size: 15))
//
//        Button(action: action) {
//            HStack {
//                Image("calendar")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                Text(value.formatted(date: .numeric, time: .omitted))
//                    .font(.custom("Inter-Regular", size: 15))
//                Spacer()
//            }
//            .foregroundColor(.white)
//            .padding()
//            
//        } .overlay(
//            RoundedRectangle(cornerRadius: 5)
//                .stroke(Color.white.opacity(0.4), lineWidth: 1)
//        )
//    }
//   
//}

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
                    : value!.formatted(date: .numeric, time: .omitted)
                )
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


// Time Field Box
//func timeBox(title: String, value: Date, action: @escaping () -> Void) -> some View {
//    VStack(alignment: .leading, spacing: 6) {
//        Text(title)
//            .foregroundColor(.white)
//            .font(.custom("Inter-Regular", size: 15))
//
//        Button(action: action) {
//            HStack {
//                Image("clock")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                Text(value.formatted(date: .omitted, time: .shortened))
//                    .font(.custom("Inter-Regular", size: 15))
//                Spacer()
//            }
//            .foregroundColor(.white)
//            .padding()
//            .overlay(
//                RoundedRectangle(cornerRadius: 5)
//                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
//            )
//        }
//    }
//}

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
    ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][day-1]
}
