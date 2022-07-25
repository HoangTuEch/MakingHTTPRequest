//
//  ResponsePost.swift
//  MakingHTTPRequest
//
//  Created by DatND2 on 7/25/22.
//

struct ResponsePost: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
