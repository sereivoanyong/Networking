//
//  Client.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/28/25.
//

import Foundation
import Alamofire
import Combine

// any Request<T> will cause crash on iOS 15

open class Client<Variables: Networking.Variables> {

  public let session: Session
  
  open var dateFormatter: DateFormatter?

  public init() {
    var eventMonitors: [EventMonitor] = []
#if DEBUG
    eventMonitors.append(AlamofireLogger())
#endif
    session = Session(
      configuration: Self.makeSessionConfiguration(),
      eventMonitors: eventMonitors
    )
  }

  // MARK: Requests

  @discardableResult
  public func request<R: Request<Response.T>, Response: ResponseProtocol>(_ request: R, completion: @escaping (Result<(Response.T, Response), NetworkingError>) -> Void) -> any Cancellable {
    let urlRequest = makeURLRequest(request)
    let decoder = makeResponseDecoder(for: request)
    let dataRequest = session
      .request(urlRequest)
      .validate()
      .responseData(queue: .main) { [unowned self] response in
        process(response, decoder: decoder, completion: completion)
      }
    return dataRequest
  }

  @discardableResult
  public func request<R: UploadRequest<Response.T>, Response: ResponseProtocol>(_ request: R, completion: @escaping (Result<(Response.T, Response), NetworkingError>) -> Void) -> any Cancellable {
    let urlRequest = makeURLRequest(request)
    let decoder = makeResponseDecoder(for: request)
    let uploadRequest = session
      .upload(
        multipartFormData: request.makeFormData(),
        with: urlRequest
      )
      .validate()
      .responseData(queue: .main) { [unowned self] response in
        process(response, decoder: decoder, completion: completion)
      }
    return uploadRequest
  }

  private func process<Response: ResponseProtocol>(_ dataResponse: AFDataResponse<Data>, decoder: JSONDecoder, completion: @escaping (Result<(Response.T, Response), NetworkingError>) -> Void) {
    switch dataResponse.result {
    case .success(let data):
      let result = decodeResponseResult(Response.self, from: data, using: decoder)
      completion(result)

    case .failure(let error):
      if let data = dataResponse.data {
        if let urlResponse = dataResponse.response, 500..<600 ~= urlResponse.statusCode {
          if case .success(let serverError) = decodeServerError(from: data, using: decoder) {
            completion(.failure(.server(serverError)))
            return
          }
        }
        if case .success(let responseError) = decodeResponseError(Response.self, from: data, using: decoder) {
          completion(.failure(.response(responseError)))
          return
        }
      }
      completion(.failure(.flattened(error)))
    }
  }

  open func decodeResponseResult<Response: ResponseProtocol>(_ responseType: Response.Type, from data: Data, using decoder: JSONDecoder) -> Result<(Response.T, Response), NetworkingError> {
    do {
      let response = try decoder.decode(responseType, from: data)
      return response.result
    } catch {
      return .failure(.decoding(data, error as! DecodingError))
    }
  }

  open func decodeServerError(from data: Data, using decoder: JSONDecoder) -> Result<any LocalizedError, DecodingError>? {
    return nil
  }

  open func decodeResponseError<Response: ResponseProtocol>(_ responseType: Response.Type, from data: Data, using decoder: JSONDecoder) -> Result<Response.ResponseError, DecodingError>? {
    do {
      let response = try decoder.decode(responseType, from: data)
      if let error = response.error {
        return .success(error)
      }
      return nil
    } catch {
      return .failure(error as! DecodingError)
    }
  }

  // MARK: Modifiers

  open func setHeaders<R: Request>(from request: R, to urlRequest: inout URLRequest) {
    var headers: HTTPHeaders = .default
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

  open func setQuery<R: Request>(from request: R, to urlRequest: inout URLRequest) {
    guard let queryParameters = request.queryParameters else { return }
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

  open func setBody<R: Request>(from request: R, to urlRequest: inout URLRequest) {
    guard let bodyRequest = request as? _BodyContaining, let body = bodyRequest.body else { return }
    do {
      switch body {
      case .encoding(let encodable):
        let encoder = makeBodyEncoder(for: request)
        urlRequest.httpBody = try encoder.encode(encodable)
      case .serialization(let object):
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: object, options: [])
      }
    } catch {
      print(error)
    }
  }

  // MARK: Factory Methods

  open class func makeSessionConfiguration() -> URLSessionConfiguration {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 60
    configuration.httpMaximumConnectionsPerHost = 100
    configuration.requestCachePolicy = .useProtocolCachePolicy
    return configuration
  }

  open func makeURLRequest<R: Request>(_ request: R) -> URLRequest {
    let baseURL = request.overrideBaseURL ?? Variables.baseURL!
    let url = baseURL.appendingPathComponent(request.path)
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.rawValue
    setHeaders(from: request, to: &urlRequest)
    setQuery(from: request, to: &urlRequest)
    setBody(from: request, to: &urlRequest)
    return urlRequest
  }

  /// Used for body encoding to URL request
  open func makeBodyEncoder<R: Request>(for request: R) -> JSONEncoder {
    let encoder = JSONEncoder()
    if let dateFormatter {
      encoder.dateEncodingStrategy = .formatted(dateFormatter)
    }
    return encoder
  }

  /// Used for response decoding
  open func makeResponseDecoder<R: Request>(for request: R) -> JSONDecoder {
    let decoder = JSONDecoder()
    if let dateFormatter {
      decoder.dateDecodingStrategy = .formatted(dateFormatter) // 2024-03-11T07:33:47.564163451
    }
    decoder.userInfo = request.decodingUserInfo ?? [:]
    return decoder
  }
}
