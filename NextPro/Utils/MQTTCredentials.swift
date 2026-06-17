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


        // MARK: Step 1 — HKDF Key Derivation
        // ikm = (access_token + user_id).encode()

        let ikm  = (accessToken + userId).data(using: .utf8)!
        let hkdf = HKDF<SHA256>.self
        let derivedKey = hkdf.deriveKey(
            inputKeyMaterial: SymmetricKey(data: ikm),
            info: Data("mqtt-blob-v2".utf8),
            outputByteCount: 16
        )

        let keyBytes = derivedKey.withUnsafeBytes { Data($0) }

        // MARK: Step 2 — Base64 decode blob
        // raw = [ iv(12) | ciphertext(N) | gcm_tag(16) ]

        guard let raw = Data(base64Encoded: ctxBlob, options: .ignoreUnknownCharacters),
              raw.count > 28 else {
            print("❌ base64 decode failed or blob too short")
            throw MQTTBlobError.invalidBlob
        }

        // MARK: Step 3 — Split IV, ciphertext, tag

        let iv       = raw.prefix(12)
        let ctAndTag = raw.dropFirst(12)
        let ctBytes  = ctAndTag.dropLast(16)
        let tagBytes = ctAndTag.suffix(16)


        // MARK: Step 4 — AES-128-GCM Decrypt

        let nonce     = try AES.GCM.Nonce(data: iv)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ctBytes, tag: tagBytes)
        let decrypted = try AES.GCM.open(sealedBox, using: derivedKey)


        // MARK: Step 5 — Reverse string

        guard let reversedB64 = String(data: decrypted, encoding: .utf8) else {
            throw MQTTBlobError.invalidUTF8
        }

        let b64Json = String(reversedB64.reversed())

        // MARK: Step 6 — Base64 decode → JSON

        guard let jsonData = Data(base64Encoded: b64Json) else {
            print("❌ base64 decode of reversed string failed")
            throw MQTTBlobError.invalidBlob
        }

        print("🔓 json string     : \(String(data: jsonData, encoding: .utf8) ?? "<non-utf8>")")
        print("──────────── MQTT BLOB DECRYPT END ────────────")

        // MARK: Step 7 — Parse JSON → MQTTCredentials

        return try JSONDecoder().decode(MQTTCredentials.self, from: jsonData)
    }
}
