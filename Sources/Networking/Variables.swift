//
//  Variables.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/28/25.
//

import Foundation

public protocol Variables {

  static var environment: String! { get }

  static var baseURL: URL! { get }

  static var accessToken: String? { get }
}

extension Variables {

  public static var accessToken: String? {
    return nil
  }
}
