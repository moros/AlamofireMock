# AlamofireMock

Allows for easy mocking without having to resort to using a custom URLProtocol. Using a custom URLProtocol subclass is easier but also involves async operations when testing.

## Example of usage

```
import XCTest
import AlamofireMock

class MyTest: XCTestCase
{
    func testThingReturnsData()
    {
        let rawJson = "[{ \"group\":\"Research and Development\", \"name\":\"Engineering\" }]".data(using: .utf8)
        let manager = SessionManagerMock(responseStore: DefaultResponseStore(data: rawJson))
        let sut = SomeAPI(manager: manager)
        
        let expection = XCTestExpectation(description: "Expecting items to be retrieved.")
        sut.fetchDepartments { items in
            XCTAssertEqual(items, 1)
            XCTAssertEqual(items[0].group, "Research and Development")
            XCTAssertEqual(items[0].name, "Engineering")
            expection.fulfill()
        }
        
        // don't really need since all of our defined closure's are synchronous.
        wait(for: [expection], timeout: 1)
    }
}
```
