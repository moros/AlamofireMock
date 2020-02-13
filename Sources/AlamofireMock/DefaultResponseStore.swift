//
//  File.swift
//  
//
//  Created by dmason on 2/12/20.
//

import Foundation
import Alamofire

public class DefaultResponseStore: ResponseStore
{
    private var data: Data?
    public var error: Error?
    public var request: URLRequest?
    public var response: HTTPURLResponse?
    
    public var currentProgress: Progress? = nil
    public var propertyListResponse: DataResponse<Any>? = nil
    public var downloadPropertyListResponse: DownloadResponse<Any>? = nil
    
    public init(data: Data? = nil, error: Error? = nil, request: URLRequest? = nil, response: HTTPURLResponse? = nil)
    {
        self.data = data
        self.error = error
        self.request = request
        self.response = response
    }
    
    public func error(for: URLRequest) -> Error?
    {
        return self.error
    }
    
    public func data(for: URL) -> Data
    {
        return self.data ?? Data()
    }
    
    public func data(for request: URLRequest) -> Data
    {
        return self.data ?? Data()
    }
    
    public func data(for url: URL, withParameters params: Parameters?) -> Data
    {
        return self.data ?? Data()
    }
}
