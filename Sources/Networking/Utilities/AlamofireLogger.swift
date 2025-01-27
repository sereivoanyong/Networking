//
//  AlamofireLogger.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/27/25.
//

import Foundation
import Alamofire

#if DEBUG

extension JSONSerialization {

  static func prettyPrinted(jsonObject: Any) throws -> String? {
    let data = try data(withJSONObject: jsonObject, options: .prettyPrinted)
    return String(data: data, encoding: .utf8)
  }

  @usableFromInline
  static func prettyPrinted(data: Data) throws -> String? {
    return try prettyPrinted(jsonObject: jsonObject(with: data, options: []))
  }
}

final public class AlamofireLogger: EventMonitor {

  public init() {
  }

  public func requestDidResume(_ request: Alamofire.Request) {
    guard let urlRequest = request.request else {
      return
    }
    var components = ["⚡️⚡️⚡️ \(request)"]
    let headersString = try! JSONSerialization.prettyPrinted(jsonObject: urlRequest.allHTTPHeaderFields ?? [:])!
    components.append("Headers: \(headersString)")
    if let body = urlRequest.httpBody {
      let bodyString = try! JSONSerialization.prettyPrinted(data: body)!
      components.append("Body: \(bodyString)")
    }
    print(components.joined(separator: "\n"))
  }

  public func request<Value>(_ request: Alamofire.DataRequest, didParseResponse response: AFDataResponse<Value>) {
    switch response.result {
    case .success:
      do {
        let jsonObject = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: Any]
        if let prettyString = try JSONSerialization.prettyPrinted(jsonObject: jsonObject) {
          if let response = response.response, 200...299 ~= response.statusCode {
            print("🟢🟢🟢 \(request)", "Response: \(prettyString)", separator: "\n")
          } else {
            print("🟡🟡🟡 \(request)", "Response: \(prettyString)", separator: "\n")
          }
        }
      } catch {
        // Here, I like to keep a track of error if it occurs, and also print the response data if possible into String with UTF8 encoding
        // I can't imagine the number of questions on SO where the error is because the API response simply not being a JSON and we end up asking for that "print", so be sure of it
      }

    case .failure(let error):
      print("🔴🔴🔴 \(request)", "Error: \(error.localizedDescription)", separator: "\n")
    }
  }
}

#endif
