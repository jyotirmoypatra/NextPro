//
//  UploadProfileImgResponseModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 25/11/25.
//




struct UploadProfileImgResponseModel: Decodable {
    let status: Bool
    let message: String
    let image_url: String?
}
