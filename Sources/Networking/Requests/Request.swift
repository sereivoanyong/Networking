//
//  Request.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/27/25.
//

import Foundation
import Alamofire

public enum JSONRepresentation {

  case encoding(any Encodable)
  case serialization(Any)
}

public protocol BodyContaining {

  var body: JSONRepresentation? { get }
}

public protocol Request<Response> {

  /// The type of `data` in json reponse
  associatedtype Response: Decodable

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
