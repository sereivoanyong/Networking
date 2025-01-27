//
//  DataRequest.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/27/25.
//

import Foundation
import Alamofire

public protocol DataRequest<Response>: Request, BodyContaining {
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
