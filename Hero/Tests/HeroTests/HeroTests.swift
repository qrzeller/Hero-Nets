import XCTest
import Interpreter // Alpine lang
import HeroModelNet
import AlpineSpecific

final class HeroTests: XCTestCase {
    var interpreter = Interpreter()
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

    }

    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        let path = "/tmp/hero/curry.alpine"
//        let module = PetriNet.readFile(fileName: path)
        
        try! interpreter.loadModule(fromString: module)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // look at the function `definitionTest`for definition
    func testAlpineCalcSwiftDefined(){
        
        let labelExecution = {d, l in LabelTools.dynamicReplace(t: d, label: l, interpreter: self.interpreter)}
        let pn = definitionTest(labelExecution: labelExecution)
        XCTAssertEqual(true, pn.randomRun())
    }
    
    func testAlpineCalcSwiftDefinedManualRun(){
        
        let labelExecution = {d, l in LabelTools.dynamicReplace(t: d, label: l, interpreter: self.interpreter)}
        let pn = definitionTest(labelExecution: labelExecution)
        XCTAssertEqual(true, pn.manualRun(transitionName: "t1", binding: ["a":"2", "b":"1", "c":"sub"]))
        XCTAssertEqual(false, pn.manualRun(transitionName: "t1", binding: ["a":"2", "c":"sub"]))
    }
    
    
    func testJsonParseAndRun(){
        // Commented because asset not possible in command line swift package manager : , Uncomment if you have assets
//        let fileDef  = "/tmp/hero/hnet.json"
//        let defFile = IOTools.readFile(fileName: path)
        
        let p = PetriNet()
        let labelExecution = {d, l in LabelTools.dynamicReplace(t: d, label: l, interpreter: self.interpreter)}
        XCTAssert(p.loadDefinitionFile(JSON: hnet, labelExecution: labelExecution))
        XCTAssertEqual(true, p.transitions["t1"]?.fire())
    }
    
    //
    func testLabelFunctionReturnNotEvaluated(){
        // for exemple, to prevent evaluation : label : "\"$c$\"". in this case the token come back or forth not evaluated
        let p = PetriNet()
        let labelExecution = {d, l in LabelTools.dynamicReplace(t: d, label: l, interpreter: self.interpreter)}
        XCTAssert(p.loadDefinitionFile(JSON: hnetMarking, labelExecution: labelExecution))
        XCTAssert(p.transitions["t1"]!.fire())
        
        for i in p.places["p2"]!.tokens.getAsArray(){
            XCTAssert(!i.contains("("))
        }
        
    }
    
    func testSimpleMarking(){
        let p = PetriNet()
        let labelExecution = {d, l in LabelTools.dynamicReplace(t: d, label: l, interpreter: self.interpreter)}
        let loaded =  p.loadDefinitionFile(JSON: hnetMarking, labelExecution: labelExecution)
        XCTAssert(loaded, "JSON Not loaded")
        let allMarking = p.marking()
        XCTAssertEqual(5, allMarking.count)
    }
    
    
    
    // not multiple transition here (manually checked)
    func testMarkingCalc(){
        let p = PetriNet()
        let labelExecution = {d, l in LabelTools.dynamicReplace(t: d, label: l, interpreter: self.interpreter)}
        let loaded =  p.loadDefinitionFile(JSON: hnet, labelExecution: labelExecution)
        XCTAssert(loaded, "JSON Not loaded")
        let allMarking = p.marking()
        XCTAssertEqual(13, allMarking.count)
    }
    
    private func definitionTest(labelExecution: @escaping ([String : String], String) -> String?) -> PetriNet{
        let dr = labelExecution
        
        let int = Domain(domainCardinality: 1, domainSet: "Int", codomainCardinality: 0, codomainSet: "")
        let f   = Domain(domainCardinality: 1, domainSet: "Int", codomainCardinality: 1, codomainSet: "Int")
        
        let p1 = Place(tokens: ["1", "2", "3", "4"], domain: int, name: "p1")
        let p2 = Place(tokens: ["add","sub"], domain: f, name: "p2")
        let p3 = Place(tokens: ["10"], domain: int, name: "p3")
        let places = [p1,p2,p3]
        
        let a1 = ArcIn(label: "a, b", connectedPlace: p1, name: "a1"); print(a1)
        let r1 = ArcOut(label: [{ $0["a"] }, { $0["b"] }], connectedPlace: p1, name: "r4")
        
        let a2 = ArcIn(label: "c", connectedPlace: p2, name: "a2")
        let r2 = ArcOut(label: [{ $0["c"] }], connectedPlace: p2, name: "r2")
        
        let lab3 = "operationNoCurry(a: $a$, b: $b$ , op: $c$)"
        let a3 = ArcOut(label: [{d in dr(d,lab3)}], connectedPlace: p3, name: "a2"); print(a3)
        
        let t1 = Transition(transitionGuard: [LabelTools.noGuardPrint], arcsIn: [a1,a2], arcsOut: [a3, r1, r2], name: "t1")
        let transitions = [t1]
        
        var dplaces = [String:Place<String>]()
        var dtransitions = [String:Transition<String,String>]()
        
        for p in places{
            XCTAssert(dplaces[p.getName()] == nil, "📕 The places name must be unique !")
            dplaces[p.getName()] = p
        }
        for t in transitions{
            XCTAssert(dtransitions[t.getName()] == nil, "📕 The transition name must be unique !")
            dtransitions[t.getName()] = t
        }
        
        return PetriNet(places: places, transitions: transitions, commonName: "testHero", type: PetriNet.netType.hero)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

let module = """
func add(_ x: Int, _ y: Int) -> Int ::
x + y

func sub(_ x: Int, _ y: Int) -> Int ::
x - y

func div(_ x: Int, _ y: Int) -> Int ::
x / y

func mul(_ x: Int, _ y: Int) -> Int ::
x * y

// Example: operationNoCurry(9, 5 , op: add)
func operationNoCurry( a: Int, b: Int , op: (Int, Int) -> Int) -> Int ::
op(a,b)

// Example: operationCurry(9, op: add)(5)
func operationCurry(_ x: Int, op: (Int, Int) -> Int) -> (Int) -> Int ::
func partialApply(_ y: Int) -> Int ::
op(x,y);

func guardTwo(_ x: Int) -> Bool ::
match x
with 2 :: true
with let n :: false

"""

// Petri net example of calculatrix with partial application
// See README.md for scheme
let hnet =
"""
{
"metadata": {
"version"   : "0.0.1",
"type"      : "HERO",
"complexity": 1,
"date"      : "01-01-2010"
},
"transitions": {
"t1": {
"arcs" : {
"in": {
"a1": {"name": "a1", "connectedPlace": "p1", "label":"a"},
"a2": {"name": "a2", "connectedPlace": "p2", "label":"c"}

},
"out":{
"a3": {
"name": "a3",
"connectedPlace": "p3",
"label"  : "operationNoCurry(a: $a$, b: $b$ , op: $c$)",
"labelBack"  : "operationNoCurry(a: $a$, b: $b$ , op: $c$);operationNoCurry(a: $b$, b: $a$ , op: $c$)"
}
}

},
"guards": {
"codeSaved":"guardTwo($a$);",
"code": "guardTwo(2);",
"enabled": true
},
"meta": {
"name": "t1"
}
},
"t2": {
"arcs" : {
"in": {
"a4": {"name": "a4", "connectedPlace": "p3", "label":"x"},
"a5": {"name": "a5", "connectedPlace": "p1", "label":"b"},

},
"out":{
"a6": {
"name": "a6",
"connectedPlace": "p1",
"label"  : "$x$",
"labelBack"  : "$x$;$b$+2"
}
}

},
"guards": {
"code": "",
"enabled": true
},
"meta": {
"name": "t2"
}
}

},
"places": {
"p1": {
"domain": {
"domainCardinality":    1,
"codomainCardinality":  0,
"domainSet":            "Int",
"codomainSet":          ""
},
"name": "p1",
"tokens":   ["1", "2"]
},
"p2": {
"domain": {
"domainCardinality":    1,
"codomainCardinality":  1,
"domainSet":            "Int",
"codomainSet":          "Int"
},
"name": "p2",
"tokens":   ["add", "sub"]
},
"p3": {
"domain": {
"domainCardinality":    1,
"codomainCardinality":  0,
"domainSet":            "Int",
"codomainSet":          ""
},
"name": "p3",
"tokens":   []
}}
,
"env":{
"lang": "Alpine",
"version": "x.x.x",
"context": "curry.alpine"
}

}


"""

// Simpler net to test marking
let hnetMarking =
"""
{
    "transitions": {
        "t1": {
            "arcs" : {
                "in": {
                    "a1": {"name": "a1", "connectedPlace": "p1", "label":"a, b"},
                    "a2": {"name": "a2", "connectedPlace": "p2", "label":"c"}
                    
                },
                "out":{
                    "a1": {"name": "a1", "connectedPlace": "p1", "label":"$a$"},
                    "a2": {"name": "a2", "connectedPlace": "p2", "label":"\\"$c$\\""},
                    "a3": {
                        "name": "a3",
                        "connectedPlace": "p3",
                        "label"  : "operationNoCurry(a: $a$, b: $b$ , op: $c$)",
                        "labelBack"  : "operationNoCurry(a: $a$, b: $b$ , op: $c$);operationNoCurry(a: $b$, b: $a$ , op: $c$)"
                    }
                }
                
            },
            "guards": {
                "codeSaved":"guardTwo($a$);",
                "code": "guardTwo(2);",
                "enabled": true
            },
            "meta": {
                "name": "t1"
            }
        }
        
    },
    "places": {
        "p1": {
            "domain": {
                "domainCardinality":    1,
                "codomainCardinality":  0,
                "domainSet":            "Int",
                "codomainSet":          ""
            },
            "name": "p1",
            "tokens":   ["1", "2"]
        },
        "p2": {
            "domain": {
                "domainCardinality":    1,
                "codomainCardinality":  1,
                "domainSet":            "Int",
                "codomainSet":          "Int"
            },
            "name": "p2",
            "tokens":   ["add", "sub"]
        },
        "p3": {
            "domain": {
                "domainCardinality":    1,
                "codomainCardinality":  0,
                "domainSet":            "Int",
                "codomainSet":          ""
            },
            "name": "p3",
            "tokens":   []
        }

    }
}
"""
