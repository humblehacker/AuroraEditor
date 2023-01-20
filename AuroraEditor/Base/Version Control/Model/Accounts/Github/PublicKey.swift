//
//  PublicKey.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension GithubAccount {
    /// Post Public key
    /// - Parameters:
    ///   - session: URL Session
    ///   - publicKey: Public key
    ///   - title: title
    ///   - completion: completion
    /// - Returns: URLSessionDataTaskProtocol
    func postPublicKey(_ session: GitURLSession = URLSession.shared,
                       publicKey: String,
                       title: String,
                       completion: @escaping (
                        _ response: Result<String, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = PublicKeyRouter.postPublicKey(publicKey, title, configuration)

        return router.postJSON(
            session,
            expectedResultType: [String: AnyObject].self) { json, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if json != nil {
                    completion(.success(publicKey))
                }
            }
        }
    }
}

enum PublicKeyRouter: JSONPostRouter {
    case postPublicKey(String, String, GitConfiguration)

    var configuration: GitConfiguration? {
        switch self {
        case let .postPublicKey(_, _, config): return config
        }
    }

    var method: HTTPMethod {
        switch self {
        case .postPublicKey:
            return .POST
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .postPublicKey:
            return .json
        }
    }

    var path: String {
        switch self {
        case .postPublicKey:
            return "user/keys"
        }
    }

    var params: [String: Any] {
        switch self {
        case let .postPublicKey(publicKey, title, _):
            return ["title": title, "key": publicKey]
        }
    }
}
