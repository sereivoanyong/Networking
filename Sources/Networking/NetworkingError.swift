//
//  NetworkingError.swift
//  Networking
//
//  Created by Sereivoan Yong on 1/28/25.
//

import Foundation
import Alamofire

public enum NetworkingError: Error {

  case af(AFError)
  case url(URLError)
  case server(any LocalizedError)
  case response(any ResponseErrorProtocol)
  case decoding(Data, DecodingError)
  case unknown

  public var isCancelled: Bool {
    switch self {
    case .af(.explicitlyCancelled):
      return true
    case .url(let error):
      return error.code == .cancelled
    default:
      return false
    }
  }

  public static func flattened(_ afError: AFError) -> Self {
    switch afError {
    case .createUploadableFailed:
      return .af(afError)
    case .createURLRequestFailed:
      return .af(afError)
    case .downloadedFileMoveFailed:
      return .af(afError)
    case .explicitlyCancelled:
      return .af(afError)
    case .invalidURL:
      return .af(afError)
    case .multipartEncodingFailed:
      return .af(afError)
    case .parameterEncodingFailed:
      return .af(afError)
    case .parameterEncoderFailed:
      return .af(afError)
    case .requestAdaptationFailed:
      return .af(afError)
    case .requestRetryFailed:
      return .af(afError)
    case .responseValidationFailed:
      return .af(afError)
    case .responseSerializationFailed(let reason):
      switch reason {
      case .inputDataNilOrZeroLength:
        return .af(afError)
      case .inputFileNil:
        return .af(afError)
      case .inputFileReadFailed:
        return .af(afError)
      case .stringSerializationFailed:
        return .af(afError)
      case .jsonSerializationFailed:
        return .af(afError)
      case .decodingFailed(let error):
        // This should never invoke because we decode response by ourself
        if let error = error as? DecodingError {
          return .decoding(Data(), error)
        }
        return .af(afError)
      case .customSerializationFailed:
        return .af(afError)
      case .invalidEmptyResponse:
        return .af(afError)
      }
    case .serverTrustEvaluationFailed:
      return .af(afError)
    case .sessionDeinitialized:
      return .af(afError)
    case .sessionInvalidated:
      return .af(afError)
    case .sessionTaskFailed(let error):
      if let error = error as? URLError {
        return .url(error)
      }
      return .af(afError)
    case .urlRequestValidationFailed:
      return .af(afError)
    }
  }
}

extension NetworkingError: LocalizedError {

  public var errorDescription: String? {
    switch self {
    case .af(let error):
      return error.errorDescription
    case .url(let error):
      return error.localizedDescription
    case .server(let error):
      return error.errorDescription
    case .response(let error):
      return error.errorDescription
    case .decoding(_, let error):
      return error.errorDescription
      /*
      if let context = error.context {
        let path = context.codingPath.map { codingKey in
          if let intValue = codingKey.intValue {
            return "\(intValue)"
          }
          return codingKey.stringValue
        }.joined(separator: ".")
        return context.debugDescription + " " + path
      }
      return error.errorDescription
       */
    case .unknown:
      return "An unknown error occured."
    }
  }
}

extension Result where Failure == NetworkingError {

  public static var nilOrZeroLengthFailure: Self {
    return .failure(.af(.responseSerializationFailed(reason: .inputDataNilOrZeroLength)))
  }
}

/*
extension DecodingError {

  var context: Context? {
    switch self {
    case .typeMismatch(_, let context):
      return context
    case .valueNotFound(_, let context):
      return context
    case .keyNotFound(_, let context):
      return context
    case .dataCorrupted(let context):
      return context
    @unknown default:
      return nil
    }
  }
}
 */
