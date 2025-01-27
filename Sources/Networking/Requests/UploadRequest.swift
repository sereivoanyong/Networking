//
//  UploadRequest.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/27/25.
//

import Foundation
import Alamofire

public protocol UploadRequest<Response>: Request {

  func makeFormData() -> MultipartFormData
}
