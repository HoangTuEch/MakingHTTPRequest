//
//  APIErrorResponse.swift
//  MakingHTTPRequest
//
//  Created by DatND2 on 7/25/22.
//

struct APIErrorResponse: Error, Decodable {
    let message: String
    let status: Int
    let error: String
}
