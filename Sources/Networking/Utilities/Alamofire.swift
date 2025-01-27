//
//  Alamofire.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/28/25.
//

import Foundation
import Alamofire
import Combine

extension Alamofire.Request: @retroactive Cancellable {

  public func cancel() {
    _ = cancel() as Alamofire.Request
  }
}
