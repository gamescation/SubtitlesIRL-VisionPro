//
//  PostData.swift
//  SubtitlesIRL
//
//  Created by David on 3/16/24.
//
import Foundation

class PostData {
    public static func postJSONData<T: Decodable>(url: String, appState: AppState? = nil, body: Data) async throws -> T {
        guard let url = URL(string: url) else {
                fatalError("Invalid URL")
        }
//        print("Url: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if appState != nil && appState!.device.data.t != nil {
            request.addValue("Bearer \(appState!.device.data.t!)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        
//
//        let (data, response) = try await URLSession.shared.data(from: url)
//
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 400 else {
            throw URLError(.badServerResponse)
        }
//        print("postData: \(data)")

        let decodedData = try JSONDecoder().decode(T.self, from: data)
//        print("DecodedPostData: \(decodedData)")
        return decodedData
        
    }
}
