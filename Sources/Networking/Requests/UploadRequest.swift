//
//  UploadRequest.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/28/25.
//

import Foundation
import Alamofire

public protocol UploadRequest<ResponseData>: Request {

  func makeFormData() -> MultipartFormData
}
