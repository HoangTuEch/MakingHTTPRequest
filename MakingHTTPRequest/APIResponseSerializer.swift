//
//  APIResponseSerializer.swift
//  MakingHTTPRequest
//
//  Created by DatND2 on 7/25/22.
//

import Foundation
import Alamofire

final class APIResponseSerializer<T: Decodable>: ResponseSerializer {
    
    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private lazy var successSerializer = DecodableResponseSerializer<T>(decoder: decoder)
    private lazy var errorSerializer = DecodableResponseSerializer<APIErrorResponse>(decoder: decoder)

    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Result<T, APIErrorResponse> {

        guard error == nil else { return .failure(APIErrorResponse(message: "Error", status: 500, error: "bad request")) }

        guard let response = response else { return .failure(APIErrorResponse(message: "Error", status: 500, error: "bad request")) }
        do {
            if response.statusCode < 200 || response.statusCode >= 300 {
                let result = try errorSerializer.serialize(request: request, response: response, data: data, error: nil)
                return .failure(result)
            } else {
                let result = try successSerializer.serialize(request: request, response: response, data: data, error: nil)
                return .success(result)
            }
        } catch(let err) {
            print("ERROR: ", err)
            return .failure(APIErrorResponse(message: "Error", status: 400, error: err.localizedDescription))
        }

    }

}

extension DataRequest {
    @discardableResult func responseAPI<T: Decodable>(queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated), of t: T.Type, completionHandler: @escaping (Result<T, APIErrorResponse>) -> Void) -> Self {
        return response(queue: .main, responseSerializer: APIResponseSerializer<T>()) { response in
            switch response.result {
            case .success(let result):
                completionHandler(result)
            case .failure(_):
                completionHandler(.failure(APIErrorResponse(message: "Error", status: 500, error: "bad request")))
            }
        }
    }
}
