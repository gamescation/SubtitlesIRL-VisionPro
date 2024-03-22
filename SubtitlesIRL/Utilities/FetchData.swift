//
//  FetchData.swift
//  SubtitlesIRL
//
//  Created by David on 3/16/24.
//

import Foundation

class FetchData {
    public static func fetchJSONData<T: Decodable>(url: String, appState: AppState? = nil) async throws -> T {
        guard let url = URL(string: url) else {
                fatalError("Invalid URL")
        }

        print("Url: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if appState != nil && appState!.device.data.t != nil {
            request.addValue("Bearer \(appState!.device.data.t!)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        print("HttpResponse: \(data)")

        let decodedData = try JSONDecoder().decode(T.self, from: data)
        print("DecodedData: \(decodedData)")
        return decodedData
        
    }
}
