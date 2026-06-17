//
//  MQTTCredentials.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/06/26.
//


import Foundation
import CryptoKit

struct MQTTCredentials: Codable {
    let username: String
    let password: String
    let host: String
    let port: Int
}

enum MQTTBlobError: Error {
    case invalidBlob
    case invalidUTF8
}

final class MQTTBlobDecoder {

    static func decrypt(
        ctxBlob: String,
        accessToken: String,
        userId: String
    ) throws -> MQTTCredentials {

        // MARK: HKDF Key Derivation

        let ikm = Data((accessToken + userId).utf8)

//        let derivedKey = HKDF<SHA256>.deriveKey(
//            inputKeyMaterial: SymmetricKey(data: ikm),
//            info: Data("mqtt-blob-v2".utf8),
//            outputByteCount: 16
//        )
        
        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: ikm),
            salt: Data(),
            info: Data("mqtt-blob-v2".utf8),
            outputByteCount: 16
        )

        // MARK: Decode Blob

        guard let raw = Data(base64Encoded: ctxBlob),
              raw.count > 28 else {
            throw MQTTBlobError.invalidBlob
        }

        let iv = raw.prefix(12)
        let encrypted = raw.dropFirst(12)

        let tag = encrypted.suffix(16)
        let ciphertext = encrypted.dropLast(16)

        let nonce = try AES.GCM.Nonce(data: iv)

        let sealedBox = try AES.GCM.SealedBox(
            nonce: nonce,
            ciphertext: ciphertext,
            tag: tag
        )

        let decryptedData = try AES.GCM.open(
            sealedBox,
            using: derivedKey
        )

        guard let reversedB64 = String(
            data: decryptedData,
            encoding: .utf8
        ) else {
            throw MQTTBlobError.invalidUTF8
        }

        // Reverse string
        let b64Json = String(reversedB64.reversed())

        guard let jsonData = Data(base64Encoded: b64Json) else {
            throw MQTTBlobError.invalidBlob
        }

        return try JSONDecoder().decode(
            MQTTCredentials.self,
            from: jsonData
        )
    }
}
