//
//  JKForumFetcher.swift
//  SwiftBeauty
//
//  Created by Nelson on 2018/8/18.
//  Copyright © 2018年 Nelson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

final class JKForumWesternFetcher: JKForumFetcher, SourceFetchable {
    static var sourceName: String {
        return "JKF - 歐美美女"
    }

    func fetchPosts(at page: UInt, completionHandler: @escaping (FetchResult<[Post]>) -> Void) {
        self.fetchPosts(with: "522", at: page, completionHandler: completionHandler)
    }
}

final class JKForumAsiaFetcher: JKForumFetcher, SourceFetchable {
    static var sourceName: String {
        return "JKF - 亞洲美女"
    }

    func fetchPosts(at page: UInt, completionHandler: @escaping (FetchResult<[Post]>) -> Void) {
        self.fetchPosts(with: "393", at: page, completionHandler: completionHandler)
    }
}

final class JKForumAmateurFetcher: JKForumFetcher, SourceFetchable {
    static var sourceName: String {
        return "JKF - 素人正妹"
    }

    func fetchPosts(at page: UInt, completionHandler: @escaping (FetchResult<[Post]>) -> Void) {
        self.fetchPosts(with: "574", at: page, completionHandler: completionHandler)
    }
}

final class JKForumJkfGirlFetcher: JKForumFetcher, SourceFetchable {
    static var sourceName: String {
        return "JKF - JKF女郎"
    }

    func fetchPosts(at page: UInt, completionHandler: @escaping (FetchResult<[Post]>) -> Void) {
        self.fetchPosts(with: "1112", at: page, completionHandler: completionHandler)
    }
}

final class JKForumCosplayFetcher: JKForumFetcher, SourceFetchable {
    static var sourceName: String {
        return "JKF - cosplay"
    }
    func fetchPosts(at page: UInt, completionHandler: @escaping (FetchResult<[Post]>) -> Void) {
        self.fetchPosts(with: "640", at: page, completionHandler: completionHandler)
    }
}
class JKForumFetcher {

    // MARK: - Public Methods

    func fetchPosts(with forumID: String, at page: UInt, completionHandler: @escaping (FetchResult<[Post]>) -> Void) {
        let path = "https://www.jkforum.net/forum.php?mod=forumdisplay&fid=\(forumID)&mobile=yes&page=\(page)"

        let headers: HTTPHeaders = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"
        ]
        
        AF.request(path, headers: headers ).validate().response(responseSerializer: HTMLResponseSerializer()) { (response) in
            guard let doc = response.value else {
                let result: FetchResult<[Post]> = .failure(CustomError.parse(error: response.error!))
                completionHandler(result)
                return
            }
            do {
                let posts: [Post] = try self.parse(doc)
                let result: FetchResult<[Post]> = (posts.isEmpty ? .failure(.emptyData) : .success(posts))
                completionHandler(result)
            } catch {
                let result: FetchResult<[Post]> = .failure(.parse(error: error))
                completionHandler(result)
            }
   
        }
    }

    func fetchPhotos(at url: URL, completionHandler: @escaping (FetchResult<[URL]>) -> Void) {
        AF.request(url).validate().response(responseSerializer: HTMLResponseSerializer()) { (response) in
            guard let doc = response.value else {
                let result: FetchResult<[URL]> = .failure(CustomError.parse(error: response.error!))
                completionHandler(result)
                return
            }
            do {
                let urls: [URL] = try self.parse(doc)
                let result: FetchResult<[URL]> = (urls.isEmpty ? .failure(.emptyData) : .success(urls))
                completionHandler(result)
            } catch {
                let result: FetchResult<[URL]> = .failure(.parse(error: error))
                completionHandler(result)
            }
            
            
        }

    }

    // MARK: - Private Methods

    private func parse(_ document: Document) throws -> [Post] {
        let elements = try document.select("ul#waterfall a")
        let baseURL = URL(string: "https://www.jkforum.net/")!

        let posts = elements.array().compactMap { e -> Post? in
            guard let href = try? e.attr("href"),
                let t = try? e.attr("title"),
                let style = try? e.attr("style")
                else {
                    return nil
            }
            
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: style, options: [], range: NSRange(location: 0, length: style.utf16.count))
            guard let firstMatch = matches.first, let src = firstMatch.url else { return nil }
        
            
            let post = Post(title: t,
                            coverURL: src,
                            url: URL(string: "\(href)", relativeTo: baseURL)!)
            return post
        }
        return posts
    }

    private func parse(_ document: Document) throws -> [URL] {
        let elements = try document.select("div.first ignore_js_op > img")
        let urls = elements.array().compactMap { e -> URL? in
            guard let src = try? e.attr("file") else {
                return nil
            }
            return URL(string: src)
        }
        return urls
    }
}
