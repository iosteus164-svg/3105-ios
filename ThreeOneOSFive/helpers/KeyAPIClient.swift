import Foundation

enum KeyAPIConfig {
    static let baseURL = URL(
        string: "https://world-situated-fork-appointed.trycloudflare.com"
    )!
}

struct KeyAuthResponse: Decodable {
    let success: Bool
    let status: String
    let reason: String?
    let expiresAt: Date?
    let message: String

    enum CodingKeys: String, CodingKey {
        case success, status, reason, message
        case expiresAt = "expires_at"
    }
}

enum KeyAPIError: LocalizedError {
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Resposta inválida da API."
        case .server(let message): return message
        }
    }
}

final class KeyAPIClient {
    static let shared = KeyAPIClient()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func validate(key: String, deviceID: String) async throws -> KeyAuthResponse {
        let url = KeyAPIConfig.baseURL.appendingPathComponent("api/auth")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "key": key.trimmingCharacters(in: .whitespacesAndNewlines),
            "device_id": deviceID
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw KeyAPIError.invalidResponse
        }

        if let decoded = try? decoder.decode(KeyAuthResponse.self, from: data) {
            return decoded
        }

        throw KeyAPIError.server("Erro HTTP \(http.statusCode).")
    }
}

enum LocalDeviceIdentity {
    private static let storageKey = "api.device.id"

    static func current() -> String {
        if let saved = UserDefaults.standard.string(forKey: storageKey), !saved.isEmpty {
            return saved
        }
        let value = UUID().uuidString
        UserDefaults.standard.set(value, forKey: storageKey)
        return value
    }
}
