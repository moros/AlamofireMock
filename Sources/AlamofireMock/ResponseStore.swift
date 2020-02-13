//
//  File.swift
//  
//
//  Created by dmason on 2/12/20.
//

import Foundation
import Alamofire

public protocol ResponseStore
{
    var error: Error? { get }
    var request: URLRequest? { get }
    var response: HTTPURLResponse? { get }
    
    var currentProgress: Progress? { get }
    var propertyListResponse: DataResponse<Any>? { get }
    var downloadPropertyListResponse: DownloadResponse<Any>? { get }
    
    func data(for: URLRequest) -> Data
    func data(for: URL) -> Data
    func data(for: URL, withParameters params: Parameters?) -> Data
}
