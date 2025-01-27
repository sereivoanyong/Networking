//
//  Request.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/28/25.
//

import Foundation
import Alamofire

public protocol Request<ResponseData> {

  /// The type of `data` in json reponse
  associatedtype ResponseData: Decodable

  var queryParameters: JSONRepresentation? { get }

  var path: String { get }
  var method: HTTPMethod { get }
  var headers: [String: String]? { get }
  var overrideBaseURL: URL? { get }

  var decodingUserInfo: [CodingUserInfoKey: Any]? { get }
}

extension Request {

  public var queryParameters: JSONRepresentation? {
    return nil
  }

  public var headers: [String: String]? {
    return nil
  }

  public var overrideBaseURL: URL? {
    return nil
  }

  public var decodingUserInfo: [CodingUserInfoKey: Any]? {
    return nil
  }
}

extension Request where Self: Encodable {

  public var queryParameters: JSONRepresentation? {
    return .encoding(self)
  }
}
