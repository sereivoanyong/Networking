//
//  Client.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/27/25.
//

import Foundation
import Alamofire

open class Client<Variables: Networking.Variables> {

  open var dateFormatter: DateFormatter? {
    return nil
  }

  public let session: Session = {
    let eventMonitors: [EventMonitor]
#if DEBUG
    eventMonitors = [AlamofireLogger()]
#else
    eventMonitors = []
#endif
    return Session(
      configuration: Client.makeSessionConfiguration(),
      eventMonitors: eventMonitors
    )
  }()

  public init() {
  }

  // MARK: Factory Methods

  open class func makeSessionConfiguration() -> URLSessionConfiguration {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 60
    configuration.httpMaximumConnectionsPerHost = 100
    configuration.requestCachePolicy = .useProtocolCachePolicy
    return configuration
  }

  open func makeEncoder<T>(_ request: any Networking.Request<T>) -> JSONEncoder {
    let encoder = JSONEncoder()
    if let dateFormatter {
      encoder.dateEncodingStrategy = .formatted(dateFormatter)
    }
    return encoder
  }

  open func makeDecoder<T>(_ request: any Networking.Request<T>) -> JSONDecoder {
    let decoder = JSONDecoder()
    if let dateFormatter {
      decoder.dateDecodingStrategy = .formatted(dateFormatter) // 2024-03-11T07:33:47.564163451
    }
    decoder.userInfo = request.decodingUserInfo ?? [:]
    return decoder
  }

  open func makeURLRequest<T>(_ request: any Networking.Request<T>) -> URLRequest {
    let baseURL = request.overrideBaseURL ?? Variables.baseURL!
    let url = baseURL.appendingPathComponent(request.path)
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.rawValue

    // Headers
    do {
      var headers = HTTPHeaders.default
      headers.add(.contentType("application/json"))
      if let requestHeaders = request.headers {
        for (requestHeaderKey, requestHeaderValue) in requestHeaders {
          headers[requestHeaderKey] = requestHeaderValue
        }
      }
      if let accessToken = Variables.accessToken {
        headers.add(.authorization(bearerToken: accessToken))
      }
      urlRequest.headers = headers
    }

    // Query
    if let queryParameters = request.queryParameters {
      switch queryParameters {
      case .encoding(let encodable):
        do {
          let encoder = URLEncodedFormParameterEncoder(destination: .queryString)
          urlRequest = try encoder.encode(encodable, into: urlRequest)
        } catch {
          assertionFailure(error.localizedDescription)
        }
      case .serialization(let any):
        if let dictionary = any as? [String: Any] {
          do {
            let encoding = URLEncoding(destination: .queryString)
            urlRequest = try encoding.encode(urlRequest, with: dictionary)
          } catch {
            assertionFailure(error.localizedDescription)
          }
        } else {
          assertionFailure("Invalid query serialization")
        }
      }
    }

    // Body
    if let bodyRequest = request as? BodyContaining, let body = bodyRequest.body {
      do {
        switch body {
        case .encoding(let encodable):
          let encoder = makeEncoder(request)
          urlRequest.httpBody = try encoder.encode(encodable)
        case .serialization(let object):
          urlRequest.httpBody = try JSONSerialization.data(withJSONObject: object, options: [])
        }
      } catch {
        print(error)
      }
    }
    return urlRequest
  }
}
