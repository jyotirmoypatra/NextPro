//
//  ForgetPasswordRequestModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 25/11/25.
//

import Foundation

struct ForgetPasswordResponseModel: Decodable {
    let status: Bool
    let message: String
}


struct ForgetPasswordOtpVerifyresponse: Decodable {
    let status: Bool
    let message: String
}
