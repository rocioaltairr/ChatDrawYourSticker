//
//  ChatFileTests.swift
//  ChatFileTests
//
//  Created by 白白 on 2021/10/27.
//

@testable import ChatFile

import XCTest

class ChatFileTests: XCTestCase {

    var validation :ValidationService!
    
    override func setUp() {
        super.setUp()
        validation = ValidationService()
        
    }
    
    override func tearDown() {
        validation = nil
        super.tearDown()
    }
    
    func test_is_valid_username() throws {
        XCTAssertNoThrow(try validation.validateEamil("rocio@gmail.com"))
    }

}
