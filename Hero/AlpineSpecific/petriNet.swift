//
//  petriNet.swift
//  Alpine-test1
//
//  Created by Quentin Zeller on 08.08.19.
//

import Foundation
import Interpreter


class PetriNet{
    enum netType{
        case hero
    }
    
    let type : netType
    let commonName: String
    var places = [String: Place<String>]()
    var transitions = [String: Transition<String, String>]()

    init(places: [Place<String>] = [Place<String>](),transitions: [Transition<String, String>] = [Transition<String, String>]() , commonName: String = "" ,type: netType = .hero) {
        self.type = type
        self.commonName = commonName
        
        // Init places and transition object.§
        for p in places{
            assert(self.places[p.name] == nil, "📕 The places name must be unique !")
            self.places[p.name] = p
        }
        for t in transitions{
            assert(self.transitions[t.name] == nil, "📕 The transition name must be unique !")
            self.transitions[t.name] = t
        }
        
    }
    
    
    // load the json file: Definition of our network
    public func loadDefinitionFile(path: String, labelExecution:@escaping ([String : String], String) -> String?){
        let defFile = PetriNet.readFile(fileName: path)
        let data = Data(defFile.utf8)
        print("_____________________________")
        do {
            // make sure this JSON is in the format we expect
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // read places
                
                if let jPlaces = json["places"] as? [String: [String:Any]]{
                    for p in jPlaces{
                        self.places[p.key] = Place(json: p.value)
                    }
                }else{
                    print("📕 No places found")
                }
                
                if let jTrans = json["transitions"] as? [String: [String: [String: Any]]]{
                    for p in jTrans {
                        self.transitions[p.key] = Transition(json: p.value, places: self.places, labelExecution: labelExecution)
                    }
                }else{
                    print("📕 No transitions found")
                }
                
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
    }
    
    public static func readFile(fileName: String) -> String{
        do {
            let contents = try NSString(contentsOfFile: fileName, encoding: 4)
            return contents as String
        } catch {
            // contents could not be loaded
            print("Error info: \(error)")
            return "not loaded"
        }
    }
    
    
    // To delete on prod & in test functions
    func definitionTest(labelExecution: @escaping ([String : String], String) -> String?){
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
        
        for p in places{
            assert(self.places[p.name] == nil, "📕 The places name must be unique !")
            self.places[p.name] = p
        }
        for t in transitions{
            assert(self.transitions[t.name] == nil, "📕 The transition name must be unique !")
            self.transitions[t.name] = t
        }
        
    }
    
    func randomRun(count: Int = 1) -> Bool{
        for _ in 0..<count{
            var t = transitions.values.randomElement()
            if let res = t?.fire(){ if !res {return false}
            }else {print("!!No transition to run!!");return false}
            
        }
        return true
    }
    func manualRun(transitionName : String, binding: [String:String]){
        _ = transitions[transitionName]?.fire(manualToken: binding)
    }
    
    func startDefinitionTest(){
        print("----------- Test run -----------")
        for var t in transitions{
            print("Run transition : \(t.value.name) ➡")
            _ = t.value.fire(manualToken: [
                "a":"2",
                "b":"3",
                "c":"sub"
                ])
        }
        print("Random fire : ➡")
        _ = transitions["t1"]?.fire()
        print(places["p1"]!)
        print(places["p2"]!)
        print(places["p3"] ?? "Place p3 does not exist")
    }
    
    func marking() -> Set<[String : [String]]>{
        print("-- Marking mode : ")
        
        // store markings
        var markings: Set = [getMarking()]
        var previousMarking = markings // for do while loop (break condition)
        
        let currentMarking = getMarking()
        
        
        repeat{ previousMarking = markings // for the break of do while loop. (if state don't change -> fixed point)
            
            for m in markings{ // iterate over all marking
                setMarking(marking: m) // change state of petri net to this marking
                for var t in transitions{
                    
                    var tokensByArcs = [[[String]]]()
                    var bindingsByArcs = [[String]]()
                    for a in t.value.arcsIn {
                        let tokens = a.connectedPlace.tokens.getAsArray()
                        let bindings = a.bindName
                        var rWorking = Array(Array<String>(repeating: "", count: bindings.count))
                        var resultArc   = [[String]]()
                        Combinatorix.permutationNoRep(multiset: tokens, rArray: &rWorking, result: &resultArc)
                        tokensByArcs.append(resultArc) // all combination of bindings for a certain place
                        bindingsByArcs.append(bindings)
                    }

                    let comb = Combinatorix.cardProd(array: tokensByArcs)
                    
                    func makeDict(tokens:[String]) -> [String: String]{
                        var res = [String:String]()
                        let bind:[String] = Array(bindingsByArcs.joined())
                        for b in 0..<bind.count{
                            res[bind[b]] = tokens[b]
                        }
                        return res
                    }
                    
                    //Evaluate
                    func evaluate(select: [String: String]){
                        if (t.value.fire(manualToken: select)){
                            markings.insert(getMarking())
                            t.value.resetState()}
                    }
                    
                    for c in comb{
                        let binding = makeDict(tokens: c)
                        evaluate(select: binding)
                    }
                
                }
            }
        }while(markings != previousMarking) // if same, it's a fix point
        
        return markings
    }
    
    // get current marking
    private func getMarking() -> [String: [String]]{
        var dict = [String: [String]]()
        
        for p in places {
            dict[p.value.name] = p.value.tokens.getAsArray()
        }
        return dict
    }
    
    // change the marking of our petri net
    private func setMarking(marking: [String: [String]]){
        for m in marking{
            places[m.key]?.tokens.setAlltokens(t: m.value)
        }
    }
    
}
