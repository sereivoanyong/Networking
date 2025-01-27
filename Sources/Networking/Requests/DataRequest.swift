//
//  DataRequest.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/28/25.
//

import Foundation
import Alamofire

// Workaround for iOS 15
public protocol _BodyContaining {

  var body: JSONRepresentation? { get }
}

public protocol DataRequest<ResponseData>: Request, _BodyContaining {

  var body: JSONRepresentation? { get }
}

extension DataRequest {

  public var queryParameters: JSONRepresentation? {
    return nil
  }

  public var body: JSONRepresentation? {
    return nil
  }
}

extension DataRequest where Self: Encodable {

  public var body: JSONRepresentation? {
    return .encoding(self)
  }
}
