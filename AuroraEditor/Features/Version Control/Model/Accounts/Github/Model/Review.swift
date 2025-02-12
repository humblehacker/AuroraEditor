//
//  Review.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Review
public struct Review {
    /// Body
    public let body: String

    /// Commit ID
    public let commitID: String

    /// ID
    public let id: Int

    /// State
    public let state: State

    /// Date
    public let submittedAt: Date

    /// User
    public let user: GithubUser
}

extension Review: Codable {
    /// Coding Keys
    enum CodingKeys: String, CodingKey {
        case body
        case commitID = "commit_id"
        case id
        case state
        case submittedAt = "submitted_at"
        case user
    }
}

public extension Review {
    /// State
    enum State: String, Codable, Equatable {

        /// Approved
        case approved = "APPROVED"

        /// Changes Requested
        case changesRequested = "CHANGES_REQUESTED"

        /// Commented
        case comment = "COMMENTED"

        /// Dismissed
        case dismissed = "DISMISSED"

        /// Pending
        case pending = "PENDING"
    }
}

public extension GithubAccount {
    /// List reviews
    /// 
    /// - Parameters:
    ///   - session: GIT URLSession
    ///   - owner: Owner
    ///   - repository: Repository
    ///   - pullRequestNumber: Pullrequest number
    ///   - completion: Completion
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func listReviews(_ session: GitURLSession = URLSession.shared,
                     owner: String,
                     repository: String,
                     pullRequestNumber: Int,
                     completion: @escaping (
                        _ response: Result<[Review], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = ReviewsRouter.listReviews(configuration, owner, repository, pullRequestNumber)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Review].self) { pullRequests, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let pullRequests = pullRequests {
                    completion(.success(pullRequests))
                }
            }
        }
    }
}
