//
//  File.swift
//  
//
//  Created by dmason on 2/12/20.
//

import XCTest
import SwiftyJSON
@testable import AlamofireMock

enum FakeError: Swift.Error, Equatable
{
    case unknown
}

final class AlamofireMockTests: XCTestCase
{
    func test_requestForHTTPGetMethod_response_returnsExpectedData()
    {
        var value = 12345
        let data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        let sut = SessionManagerMock(responseStore: DefaultResponseStore(data: data))
        
        let expectation = XCTestExpectation(description: "Expecting data back when originally passed to sut.")
        sut.request("https://localhost", method: .get).response { result in
            XCTAssertEqual(result.data, data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_requestForHTTPGetMethod_responseData_returnsDataWhenNoError()
    {
        var value = 12345
        let data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        let sut = SessionManagerMock(responseStore: DefaultResponseStore(data: data))
        
        let expectation = XCTestExpectation(description: "Expecting data back when originally passed to sut.")
        sut.request("https://localhost", method: .get).responseData { result in
            XCTAssertEqual(result.value, data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_requestForHTTPGetMethod_responseData_returnsErrorWhenPassed()
    {
        let sut = SessionManagerMock(responseStore: DefaultResponseStore(error: FakeError.unknown))
        let expectation = XCTestExpectation(description: "Expecting error back when originally passed to sut.")
        sut.request("https://localhost", method: .get).responseData { result in
            XCTAssertNil(result.value)
            XCTAssertEqual(result.error as? FakeError, .unknown)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_requestForHTTPGetMethod_responseString_returnsStringWhenNoError()
    {
        let data = "Café".data(using: .utf8)
        let sut = SessionManagerMock(responseStore: DefaultResponseStore(data: data))
        
        let expectation = XCTestExpectation(description: "Expecting string representation of int back when originally passed to sut.")
        sut.request("https://localhost", method: .get).responseString { result in
            XCTAssertEqual(result.value, "Café")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_requestForHTTPGetMethod_responseJSON_returnsExpectedJSONData()
    {
        let rawJson = "{ \"group\" : \"Research and Development\", \"name\" : \"Engineering\", \"department\" : 1 }".data(using: .utf8)
        let sut = SessionManagerMock(responseStore: DefaultResponseStore(data: rawJson))
        
        let expectation = XCTestExpectation(description: "Expecting JSON back when raw JSON data originally passed to sut.")
        sut.request("https://localhost", method: .get).responseJSON { response in
            switch (response.result) {
            case .success(let data):
                let json = JSON(data)
                XCTAssertEqual(json["group"].stringValue, "Research and Development")
                XCTAssertEqual(json["name"].stringValue, "Engineering")
                XCTAssertEqual(json["department"].intValue, 1)
                expectation.fulfill()
            case .failure(let error):
                print(error)
                XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    static var allTests = [
        ("request get: response => returns expected data", test_requestForHTTPGetMethod_response_returnsExpectedData),
        ("request get: responseData => returns data when no error passed", test_requestForHTTPGetMethod_responseData_returnsDataWhenNoError),
        ("request get: responseData => returns error when error passed", test_requestForHTTPGetMethod_responseData_returnsErrorWhenPassed),
        ("request get: responseString => returns string when no error passed", test_requestForHTTPGetMethod_responseString_returnsStringWhenNoError),
        ("request get: responseJSON => returns obj when no error passed", test_requestForHTTPGetMethod_responseJSON_returnsExpectedJSONData)
    ]
}
