//
//  File.swift
//  
//
//  Created by dmason on 2/12/20.
//

import Foundation
import Alamofire
import AlamofireExtended

// Should be in tests target but being used for demo purposes so server responses can be mocked
// when demo app is run!
public class SessionManagerMock: SessionManagerProtocol
{
    public var delegate: SessionDelegate
    
    public var runningSession: URLSession?
    
    public var startRequestsImmediately: Bool
    
    public var adapter: RequestAdapter?
    
    public var retrier: RequestRetrier?
    
    public var backgroundCompletionHandler: (() -> Void)?
    
    let responseStore: ResponseStore
    let multipartFormDataMock: MultipartFormData?
    let multipartFormDataResultMock: MultipartFormDataResult?
    
    public init(responseStore: ResponseStore = DefaultResponseStore(), multipartFormDataMock: MultipartFormData? = nil, multipartFormDataResultMock: MultipartFormDataResult? = nil)
    {
        self.delegate = SessionDelegate()
        self.runningSession = nil
        self.startRequestsImmediately = true
        self.adapter = nil
        self.retrier = nil
        self.backgroundCompletionHandler = nil
        
        self.responseStore = responseStore
        self.multipartFormDataMock = multipartFormDataMock
        self.multipartFormDataResultMock = multipartFormDataResultMock
    }
    
    @discardableResult
    public func request(
        _ urlConvertable: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil) -> DataRequestProtocol
    {
        let url = try! urlConvertable.asURL()
        let data = responseStore.data(for: url, withParameters: parameters)
        
        return DataRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from request(_url:method:parameters:encoding:headers:)",
            debugDescription: "",
            data: data,
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.propertyListResponse
        )
    }
    
    public func request(_ urlRequest: URLRequestConvertible) -> DataRequestProtocol
    {
        let request = try! urlRequest.asURLRequest()
        let data = responseStore.data(for: request)
        
        return DataRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from request(_urlRequest:)",
            debugDescription: "",
            data: data,
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.propertyListResponse
        )
    }
    
    @discardableResult
    public func download(_ url: URLConvertible,
                  method: HTTPMethod = .get,
                  parameters: Parameters? = nil,
                  encoding: ParameterEncoding = URLEncoding.default,
                  headers: HTTPHeaders? = nil,
                  to destination: DownloadRequest.DownloadFileDestination? = nil) -> DownloadRequestProtocol
    {
        let url = try! url.asURL()
        let data = responseStore.data(for: url, withParameters: parameters)
        
        return DownloadRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from download(_url:method:parameters:encoding:headers:to:)",
            debugDescription: "",
            data: data,
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.downloadPropertyListResponse
        )
    }
    
    @discardableResult
    public func download(_ urlRequest: URLRequestConvertible,
                  to destination: DownloadRequest.DownloadFileDestination? = nil) -> DownloadRequestProtocol
    {
        let request = try! urlRequest.asURLRequest()
        let data = responseStore.data(for: request)
        
        return DownloadRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from download(_urlRequest:to:)",
            debugDescription: "",
            data: data,
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.downloadPropertyListResponse
        )
    }
    
    @discardableResult
    public func download(resumingWith resumeData: Data,
                  to destination: DownloadRequest.DownloadFileDestination? = nil) -> DownloadRequestProtocol
    {
        return DownloadRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from download(resumingWith:to:)",
            debugDescription: "",
            data: resumeData,
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.downloadPropertyListResponse
        )
    }
    
    @discardableResult
    public func upload(_ fileURL: URL, to url: URLConvertible, method: HTTPMethod = .post, headers: HTTPHeaders? = nil) -> UploadRequestProtocol
    {
        let data = responseStore.data(for: fileURL)
        
        return UploadRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from upload(_fileURL:to:method:headers:)",
            debugDescription: "",
            data: data,
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.propertyListResponse
        )
    }
    
    @discardableResult
    public func upload(_ fileURL: URL, with urlRequest: URLRequestConvertible) -> UploadRequestProtocol
    {
        let request = try! urlRequest.asURLRequest()
        let data = responseStore.data(for: request)
        
        return UploadRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from upload(_fileURL:with:)",
            debugDescription: "",
            data: data,
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.propertyListResponse
        )
    }
    
    @discardableResult
    public func upload(_ data: Data, to url: URLConvertible, method: HTTPMethod = .post, headers: HTTPHeaders? = nil) -> UploadRequestProtocol
    {
        let convertedURL = try! url.asURL()
        
        return UploadRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from upload(_data:to:method:headers:)",
            debugDescription: "",
            data: responseStore.data(for: convertedURL),
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.propertyListResponse
        )
    }
    
    @discardableResult
    public func upload(_ data: Data, with urlRequest: URLRequestConvertible) -> UploadRequestProtocol
    {
        let request = try! urlRequest.asURLRequest()
        
        return UploadRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from upload(_data:with:)",
            debugDescription: "",
            data: responseStore.data(for: request),
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.propertyListResponse
        )
    }
    
    @discardableResult
    public func upload(_ stream: InputStream, to url: URLConvertible, method: HTTPMethod = .post, headers: HTTPHeaders? = nil) -> UploadRequestProtocol
    {
        let convertedURL = try! url.asURL()
        
        return UploadRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from upload(_stream:to:method:headers:)",
            debugDescription: "",
            data: responseStore.data(for: convertedURL),
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.propertyListResponse
        )
    }
    
    @discardableResult
    public func upload(_ stream: InputStream, with urlRequest: URLRequestConvertible) -> UploadRequestProtocol
    {
        let request = try! urlRequest.asURLRequest()
        
        return UploadRequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from upload(_stream:to:method:headers:)",
            debugDescription: "",
            data: responseStore.data(for: request),
            error: self.responseStore.error,
            propertyListResponse: self.responseStore.propertyListResponse
        )
    }
    
    public func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        queue: DispatchQueue? = nil,
        encodingCompletion: ((MultipartFormDataResult) -> Void)?)
    {
        // since the multipartFormData closure is required makes sense to error when
        // the SessionManagerMock instance wasn't provided form data to return.
        guard let formDataMock = self.multipartFormDataMock else {
            fatalError("MultipartFormData mock not provided.")
        }
        multipartFormData(formDataMock)
        
        // Since encodingCompletion closure is optional, no reason to error.
        guard let completion = encodingCompletion else {
            return
        }
        
        // If given a closure but no mock then probably makes sense to error.
        guard let result = self.multipartFormDataResultMock else {
            fatalError("MultipartFormDataResult mock not provided.")
        }
        
        completion(result)
    }
    
    public func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold,
        with urlRequest: URLRequestConvertible,
        queue: DispatchQueue? = nil,
        encodingCompletion: ((MultipartFormDataResult) -> Void)?)
    {
        // since the multipartFormData closure is required makes sense to error when
        // the SessionManagerMock instance wasn't provided form data to return.
        guard let formDataMock = self.multipartFormDataMock else {
            fatalError("MultipartFormData mock not provided.")
        }
        multipartFormData(formDataMock)
        
        // Since encodingCompletion closure is optional, no reason to error.
        guard let completion = encodingCompletion else {
            return
        }
        
        // If given a closure but no mock then probably makes sense to error.
        guard let result = self.multipartFormDataResultMock else {
            fatalError("MultipartFormDataResult mock not provided.")
        }
        
        completion(result)
    }
    
    #if !os(watchOS)
    
    public func stream(withHostName hostName: String, port: Int) -> RequestProtocol
    {
        return RequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from stream(withHostName:port:)",
            debugDescription: ""
        )
    }
    
    public func stream(with netService: NetService) -> RequestProtocol
    {
        return RequestMock(
            session: self.runningSession,
            task: nil,
            request: self.responseStore.request,
            response: self.responseStore.response,
            retryCount: 1,
            description: "called from stream(with:)",
            debugDescription: ""
        )
    }
    
    #endif
}
