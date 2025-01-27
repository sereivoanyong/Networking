//
//  JSONRepresentation.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/28/25.
//

import Foundation

public enum JSONRepresentation {

  case encoding(any Encodable)
  case serialization(Any)
}
