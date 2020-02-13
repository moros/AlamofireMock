//
//  File.swift
//  
//
//  Created by dmason on 2/12/20.
//

import Foundation
import Alamofire
import AlamofireExtended

public class RequestMock: RequestProtocol
{
    public var task: URLSessionTask?
    
    public var runningSession: URLSession?
    
    public var request: URLRequest?
    
    public var response: HTTPURLResponse?
    
    public var retryCount: UInt
    
    public var description: String
    
    public var debugDescription: String
    
    let error: Error?
    
    public init(session: URLSession? = nil, task: URLSessionTask? = nil, request: URLRequest? = nil, response: HTTPURLResponse? = nil, retryCount: UInt = 1, description: String = "", debugDescription: String = "", error: Error? = nil)
    {
        self.runningSession = session
        self.task = task
        self.request = request
        self.response = response
        self.retryCount = retryCount
        self.description = description
        self.debugDescription = debugDescription
        self.error = error
    }
    
    @discardableResult
    public func authenticate(
        user: String,
        password: String,
        persistence: URLCredential.Persistence = .forSession)
        -> Self
    {
        return self
    }
    
    @discardableResult
    public func authenticate(usingCredential credential: URLCredential) -> Self
    {
        return self
    }
    
    public func resume()
    {
    }
    
    public func suspend()
    {
    }
    
    public func cancel()
    {
    }
}

// Should be in tests target but being used for demo purposes so server responses can be mocked
// when demo app is run!
public class DataRequestMock: RequestMock, DataRequestProtocol
{
    public var currentProgress: Progress?
    
    let data: Data?
    let propertyListResponse: DataResponse<Any>?
    
    public init(session: URLSession? = nil, task: URLSessionTask? = nil, request: URLRequest? = nil, response: HTTPURLResponse? = nil, retryCount: UInt = 1, description: String = "", debugDescription: String = "", data: Data? = nil, error: Error? = nil, propertyListResponse: DataResponse<Any>? = nil)
    {   
        self.data = data
        self.propertyListResponse = propertyListResponse
        super.init(session: session, task: task, request: request, response: response, retryCount: retryCount, description: description, debugDescription: debugDescription, error: error)
    }
    
    @discardableResult
    public func response(queue: DispatchQueue?,
                         completionHandler: @escaping (DefaultDataResponse) -> Void) -> Self
    {
        let response = DefaultDataResponse(request: self.request, response: self.response, data: self.data, error: self.error)
        completionHandler(response)
        return self
    }
    
    @discardableResult
    public func responseData(queue: DispatchQueue?,
                             completionHandler: @escaping (DataResponse<Data>) -> Void) -> Self
    {
        let result = self.error == nil ? Result.success(self.data!) : Result.failure(self.error!)
        let response = DataResponse<Data>(request: self.request, response: self.response, data: self.data, result: result)
        completionHandler(response)
        return self
    }
    
    @discardableResult
    public func responseString(queue: DispatchQueue?,
                               encoding: String.Encoding?,
                               completionHandler: @escaping (DataResponse<String>) -> Void) -> Self
    {
        let result = self.error == nil ? Result.success(String(decoding: self.data!, as: UTF8.self)) : Result.failure(self.error!)
        let response = DataResponse<String>(request: self.request, response: self.response, data: self.data, result: result)
        completionHandler(response)
        return self
    }
    
    @discardableResult
    public func responseJSON(queue: DispatchQueue?,
                      options: JSONSerialization.ReadingOptions,
                      completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self
    {
        let result = Result {
            return try convertToJsonObject(with: data!, options: options, error: error)
        }
        let dataResponse = DataResponse(request: self.request, response: self.response, data: data, result: result)
        completionHandler(dataResponse)
        return self
    }
    
    @discardableResult
    public func responsePropertyList(queue: DispatchQueue?,
                                     options: PropertyListSerialization.ReadOptions,
                                     completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self
    {
        // Cheating a bit by having the mock take in a data response dependency!
        guard let propListResponse = propertyListResponse else {
            fatalError("responsePropertyList(queue:options:completionHandler:) failed; mocked response not passed in.")
        }
        
        completionHandler(propListResponse)
        return self
    }
    
    // TODO: May need to move this to a MockDownloadRequest class
    @discardableResult
    public func downloadProgress(queue: DispatchQueue, closure: @escaping Request.ProgressHandler) -> Self
    {
        guard let progress = currentProgress else {
            fatalError("downloadProgress(queue: queue, closure: closure) has not been implemented")
        }
        
        closure(progress)
        return self
    }
    
    private func convertToJsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions = [], error: Error?) throws -> Any
    {
        // If no error, else block will execute.
        guard let error = error else {
            return try JSONSerialization.jsonObject(with: data, options: opt)
        }
        
        // If we are given error, throw it so that Result<Value> will be .failure instead of .success
        throw error
    }
}

public class DownloadRequestMock: RequestMock, DownloadRequestProtocol
{
    public var resumeData: Data?
    public var currentProgress: Progress?
    let propertyListResponse: DownloadResponse<Any>?
    
    public init(session: URLSession? = nil, task: URLSessionTask? = nil, request: URLRequest? = nil, response: HTTPURLResponse? = nil, retryCount: UInt = 1, description: String = "", debugDescription: String = "", data: Data? = nil, error: Error? = nil, propertyListResponse: DownloadResponse<Any>? = nil)
    {
        self.resumeData = data
        self.propertyListResponse = propertyListResponse
        super.init(session: session, task: task, request: request, response: response, retryCount: retryCount, description: description, debugDescription: debugDescription, error: error)
    }
    
    @discardableResult
    public func response(queue: DispatchQueue? = nil, completionHandler: @escaping (DefaultDownloadResponse) -> Void) -> Self
    {
        let response = DefaultDownloadResponse(request: self.request, response: self.response, temporaryURL: nil, destinationURL: nil, resumeData: self.resumeData, error: self.error)
        completionHandler(response)
        return self
    }
    
    public func response<T>(queue: DispatchQueue?, responseSerializer: T, completionHandler: @escaping (DownloadResponse<T.SerializedObject>) -> Void) -> Self where T : DownloadResponseSerializerProtocol
    {
        fatalError("response<T>(queue:responseSerializer:completionHandler:) has not been implemented")
    }
    
    @discardableResult
    public func responseData(queue: DispatchQueue? = nil,
                      completionHandler: @escaping (DownloadResponse<Data>) -> Void) -> Self
    {
        let result = self.error == nil ? Result.success(self.resumeData!) : Result.failure(self.error!)
        let response = DownloadResponse(request: self.request, response: self.response, temporaryURL: nil, destinationURL: nil, resumeData: self.resumeData, result: result)
        completionHandler(response)
        return self
    }
    
    @discardableResult
    public func responseString(queue: DispatchQueue? = nil,
                        encoding: String.Encoding? = nil,
                        completionHandler: @escaping (DownloadResponse<String>) -> Void) -> Self
    {
        let result = self.error == nil ? Result.success(String(decoding: self.resumeData!, as: UTF8.self)) : Result.failure(self.error!)
        let response = DownloadResponse(request: self.request, response: self.response, temporaryURL: nil, destinationURL: nil, resumeData: self.resumeData, result: result)
        completionHandler(response)
        return self
    }
    
    @discardableResult
    public func responseJSON(queue: DispatchQueue? = nil,
                      options: JSONSerialization.ReadingOptions = .allowFragments,
                      completionHandler: @escaping (DownloadResponse<Any>) -> Void) -> Self
    {
        let result = Result {
            return try convertToJsonObject(with: self.resumeData!, options: options, error: error)
        }
        let response = DownloadResponse(request: self.request, response: self.response, temporaryURL: nil, destinationURL: nil, resumeData: self.resumeData, result: result)
        completionHandler(response)
        return self
    }
    
    @discardableResult
    public func responsePropertyList(queue: DispatchQueue? = nil,
                              options: PropertyListSerialization.ReadOptions = [],
                              completionHandler: @escaping (DownloadResponse<Any>) -> Void) -> Self
    {
        // Cheating a bit by having the mock take in a data response dependency!
        guard let propListResponse = propertyListResponse else {
            fatalError("responsePropertyList(queue:options:completionHandler:) failed; mocked response not passed in.")
        }
        
        completionHandler(propListResponse)
        return self
    }
    
    private func convertToJsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions = [], error: Error?) throws -> Any
    {
        // If no error, else block will execute.
        guard let error = error else {
            return try JSONSerialization.jsonObject(with: data, options: opt)
        }
        
        // If we are given error, throw it so that Result<Value> will be .failure instead of .success
        throw error
    }
}

public class UploadRequestMock: DataRequestMock, UploadRequestProtocol
{
    public override init(session: URLSession? = nil, task: URLSessionTask? = nil, request: URLRequest? = nil, response: HTTPURLResponse? = nil, retryCount: UInt = 1, description: String = "", debugDescription: String = "", data: Data? = nil, error: Error? = nil, propertyListResponse: DataResponse<Any>? = nil)
    {
        super.init(session: session, task: task, request: request, response: response, retryCount: retryCount, description: description, debugDescription: debugDescription, data: data, error: error, propertyListResponse: propertyListResponse)
    }
    
    @discardableResult
    public func uploadProgress(queue: DispatchQueue = DispatchQueue.main, closure: @escaping Request.ProgressHandler) -> Self
    {
        guard let progress = currentProgress else {
            fatalError("uploadProgress(queue:closure:) mocked progress not provided")
        }
        
        closure(progress)
        return self
    }
}
