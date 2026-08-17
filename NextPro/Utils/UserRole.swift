//
//  UserRole.swift
//  NextPro
//

import Foundation

/// Maps the "user_type" UserDefaults value to the display title/icon used by
/// the role capsule shown in both TopHeaderView and ProfileEndUserView.
enum UserRole {
    static var current: String {
        UserDefaults.standard.string(forKey: "user_type") ?? ""
    }

    static var title: String {
        switch current {
        case "organization_admin":
            return "Organization Admin"
        case "org_sub_admin":
            return "Organization Sub Admin"
        case "staff":
            return "Organization Staff"
        case "non_staff":
            return "Member"
        default:
            return "Member"
        }
    }

    static var icon: String {
        switch current {
        case "organization_admin":
            return "crown.fill"
        case "org_sub_admin":
            return "shield.fill"
        case "staff":
            return "person.fill"
        case "non_staff":
            return "person.fill"
        default:
            return "person.fill"
        }
    }
}
