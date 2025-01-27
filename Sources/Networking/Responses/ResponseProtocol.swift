//
//  ResponseProtocol.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/28/25.
//

import Foundation

public protocol ResponseProtocol<T>: Decodable {

  associatedtype T: Decodable

  associatedtype ResponseError: ResponseErrorProtocol

  var error: ResponseError? { get }

  /// Returns `.nilOrZeroLengthFailure` if both data and error are `nil`.
  var result: Result<(T, Self), NetworkingError> { get }
}
