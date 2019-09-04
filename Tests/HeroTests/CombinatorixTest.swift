//
//  combinatorixTest.swift
//  HeroTests
//
//  Created by Quentin Zeller on 01.09.19.
//

import XCTest
import GeneralTools

class combinatorixTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test2OutOf6() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    
        let arr = ["a", "b", "c","d", "e", "f"]
        var result = [[String]]()
        let r = 2
        var data: [String] = Array<String>(repeating: "", count: r) // size ?
        
        Combinatorix.permutationNoRep(multiset: arr, rArray: &data, result: &result)
        XCTAssert(result.count == Set(result).count, "There is dupplicate")
        XCTAssert(result.count ==  30, "Result should be 30")
    }
    func test1OutOf6() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let arr = ["a", "b", "c","d", "e", "f"]
        var result = [[String]]()
        let r = 1
        
        var data: [String] = Array<String>(repeating: "", count: r) // size ?
        
        Combinatorix.permutationNoRep(multiset: arr, rArray: &data, result: &result)
        XCTAssert(result.count == Set(result).count, "There is dupplicate")
        XCTAssert(result.count ==  6, "Result should be 6")
    }
    func test3OutOf26() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let arr = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
                   "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        var result = [[String]]()
        let r = 3
        
        var data: [String] = Array<String>(repeating: "", count: r) // size ?
        
        Combinatorix.permutationNoRep(multiset: arr, rArray: &data, result: &result)
        XCTAssert(result.count == Set(result).count, "There is dupplicate")
        XCTAssert(result.count ==  15600, "Result should be 15600")
    }
    
    func testCartesianProduct(){
        let answer = Combinatorix.cardProd(array: [[["add"], ["sub"]],[["+"], ["-"]],
                                           [["1", "2"], ["1", "3"], ["2", "1"], ["2", "3"], ["3", "1"], ["3", "2"]]])
        
        XCTAssert(answer.count == 24)
        //        for i in answer {
        //            print(i)
        //        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
