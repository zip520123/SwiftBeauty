//
//  TimLiaoFetcher.swift
//  SwiftBeauty
//
//  Created by Nelson on 2018/8/8.
//  Copyright © 2018年 Nelson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

final class TimLiaoFetcher: SourceFetchable {
    private static let cfEncoding = CFStringEncodings.big5
    private static let nsEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
    private static let encoding = String.Encoding(rawValue: nsEncoding)
    // MARK: - SourceFetchable

    static var sourceName: String {
        return "提姆正妹"
    }

    func fetchPosts(at page: UInt, completionHandler: @escaping (FetchResult<[Post]>) -> Void) {
        let path = "http://www.timliao.com/bbs/forumdisplay.php?fid=18&filter=0&orderby=dateline&page=\(page)"
        AF.request(path).validate().response(responseSerializer: HTMLResponseSerializerBig5()) { (response) in
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
        let query = "#container_all > form li.forum-card > div.pic > a:not([href='http://www.timliao.com'])"
        let elements = try document.select(query)

        let posts = elements.array().compactMap { e -> Post? in
            guard let image = try? e.select("img").first(),
                let title = try? e.parent()?.parent()?.select("h2.subject > a").first()
            else {
                return nil
            }
            
            var src = try? image.attr("src")
            
            if src == "" {
                src = try? image.attr("data-src")
            }
            
            guard src != nil else {return nil}
            
            guard let t = try? title.text(),
                let href = try? title.attr("href")
            else {
                return nil
            }
            let post = Post(title: t,
                            coverURL: URL(string: "http://www.timliao.com/bbs/\(src!)")!,
                            url: URL(string: "http://www.timliao.com/bbs/\(href)")!)
            return post
        }
        return posts
    }

    private func parse(_ document: Document) throws -> [URL] {
        let query = "div.postcontent > div.mt10 > a > img"
        let elements = try document.select(query)

        let urls = elements.array().compactMap { e -> URL? in
            guard let src = try? e.attr("src") else {
                return nil
            }
            return URL(string: src)
        }
        return urls
    }
}
