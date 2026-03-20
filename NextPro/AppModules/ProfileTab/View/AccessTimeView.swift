//
//  AccessTimeView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 20/03/26.
//

import SwiftUI

struct AccessTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWeekdays: Set<Int> = []
    let userData : UserProfileData?
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
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
                        Text("Access Time")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {

                            Spacer(minLength: 5)
                            // ACCESS DATE
                            Text("ACCESS DATE")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)

                           
                            HStack {
                                dateItem(title: "Start Date", value: formatDate(userData?.start_date))
                                Spacer()
                                dateItem(title: "End Date", value: formatDate(userData?.end_date))
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1))
                                ))

                            // ACCESS TIME
                            Text("ACCESS TIME")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 16) {
                                if let slots = userData?.time_slots, !slots.isEmpty {

                                    ForEach(slots.indices, id: \.self) { index in
                                        let slot = slots[index]

                                        VStack(alignment: .leading, spacing: 10) {

                                            // Slot Title
                                            if slots.count > 1 {
                                                Text("Time Slot \(index + 1)")
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .font(.system(size: 13, weight: .medium))
                                            }

                                            HStack(spacing: 20) {
                                                timeItem(
                                                    title: "Start Time",
                                                    value: formatTime(slot.start_time)
                                                )

                                                Spacer()

                                                timeItem(
                                                    title: "End Time",
                                                    value: formatTime(slot.end_time)
                                                )
                                            }
                                        }
                                        .padding(.vertical, 3)

                                        // ✅ Cleaner Divider
                                        if index != slots.count - 1 {
                                            Divider()
                                                .background(Color.white.opacity(0.15))
                                                .padding(.vertical, 4)
                                        }
                                    }

                                } else {
                                    Text("No time slots available")
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 10)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1))
                                    )
                            )

                            // REPEAT EVERY
                            Text("REPEAT EVERY")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7),
                                spacing: 10
                            ) {
                                ForEach(1...7, id: \.self) { day in
                                    DayPill(
                                        title: shortDay(day),
                                        isSelected: selectedWeekdays.contains(day)
                                    ) {
                                       
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(10)

                            // ACCESSIBLE DOORS
                            Text("ACCESSIBLE DOORS")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if let groups = userData?.access_groups_detail {
                                let doors = groups.flatMap { $0.doors }

                                if !doors.isEmpty {
                                    ForEach(doors.indices, id: \.self) { index in
                                        let door = doors[index]

                                        doorCard(
                                            title: door.door_name,
                                            subtitle: ""
                                        )
                                    }
                                } else {
                                    Text("No accessible doors")
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }

                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .onAppear {
            selectedWeekdays = parseWeekDays(userData?.week_days)
        }
    }
    
    func dateItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.custom("Inter-Regular", size: 15))

            HStack {
                Image("calendar")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(value)
                    .font(.custom("Inter-Regular", size: 15))
                    .foregroundColor(.white)
            }
            .foregroundColor(.white)
        }
    }
    
    func timeItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.custom("Inter-Regular", size: 15))

            HStack {
                Image("clock")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(value)
                    .font(.custom("Inter-Regular", size: 15))
                    .foregroundColor(.white)
            }
            .foregroundColor(.white)
        }
    }
    func doorCard(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: subtitle.isEmpty ? 0 : 6) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))

            if !subtitle.isEmpty {
                Text(subtitle)
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1))
                )
        )
    }
    
    func formatTime(_ time: String?) -> String {
        guard let time = time else { return "--" }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        if let date = formatter.date(from: time) {
            formatter.dateFormat = "hh:mm a"
            return formatter.string(from: date)
        }

        return time
    }
    func formatDate(_ date: String?) -> String {
        guard let date = date else { return "--" }

        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let parsedDate = formatter.date(from: date) {
            formatter.dateFormat = "MM/dd/yyyy"
            return formatter.string(from: parsedDate)
        }

        return date
    }
    
    func parseWeekDays(_ weekDays: String?) -> Set<Int> {
        guard let weekDays = weekDays else { return [] }

        return Set(
            weekDays
                .split(separator: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        )
    }

}

