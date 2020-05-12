//
//  HTMLResponseSerialization.swift
//  SwiftBeauty
//
//  Created by Nelson on 2018/8/3.
//  Copyright © 2018年 Nelson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

struct HTMLResponseSerializer: ResponseSerializer {
    typealias SerializedObject = Document
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Document {
        
        let string = try StringResponseSerializer().serialize(request: request, response: response, data: data, error: error)

        return try SwiftSoup.parse(string)
        
    }
    
}

struct HTMLResponseSerializerBig5: ResponseSerializer {
    typealias SerializedObject = Document
    private static let cfEncoding = CFStringEncodings.big5
    private static let nsEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
    private static let encoding = String.Encoding(rawValue: nsEncoding)
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Document {
        
        let string = try StringResponseSerializer(encoding: HTMLResponseSerializerBig5.encoding).serialize(request: request, response: response, data: data, error: error)

        return try SwiftSoup.parse(string)
        
    }
    
}
