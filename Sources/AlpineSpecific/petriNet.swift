//
//  petriNet.swift
//
//  Created by Quentin Zeller on 08.08.19.
//

import Foundation

import HeroModelNet
import GeneralTools

// This class intend to factorise our petriNet (transition and places)
// It's only for String types
// It does also calculate the markings
public class PetriNet{
    
    // hero type
    public enum netType{
        case hero
        // case future High order net
    }
    
    let type : netType
    public let commonName: String
    public var places = [String: Place<String>]()
    public var transitions = [String: Transition<String, String>]()

    // You may cal without arguments. Thoses are public structures.
    // Especially if you use the loadDefinitionFile function that construct them for you.
    public init(places: [Place<String>] = [Place<String>](),transitions: [Transition<String, String>] = [Transition<String, String>]() , commonName: String = "" ,type: netType = .hero) {
        self.type = type
        self.commonName = commonName
        
        // Init places and transition object.§
        for p in places{
            assert(self.places[p.getName()] == nil, "📕 The places name must be unique !")
            self.places[p.getName()] = p
        }
        for t in transitions{
            assert(self.transitions[t.getName()] == nil, "📕 The transition name must be unique !")
            self.transitions[t.getName()] = t
        }
        
    }
    
    
    // load the json file: Definition of our network
    public func loadDefinitionFile(JSON: String, labelExecution:@escaping ([String : String], String) -> String?) -> Bool{

        guard let data = JSON.data(using: .utf8) else {
            print("📕 Data cannot be utf8)");
            return false
        }
    
        do {
            // make sure this JSON is in the format we expect
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // read places
                
                if let jPlaces = json["places"] as? [String: [String:Any]]{
                    for p in jPlaces{
                        print("------------------",p.key)
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
            print("""
                📕 Failed to load: \(error.localizedDescription)
                    Verify if JSON is correct RFC 4627
                    If you need to define string in string, escape the " correctly. You may need to use \\\\ instead of \\ if it's definied inside a swift file"
                """)
            return false
        }
        return true
    }
    
    
    // Run at random the transition.
    // Return false if fire could not be performed
    public func randomRun(count: Int = 1) -> Bool{
        for _ in 0..<count{
            var t = transitions.values.randomElement()
            if let res = t?.fire(){ if !res {return false}
            }else {print("!!No transition to run!!");return false}
            
        }
        return true
    }
    // run with manual binding. Key are name of binding variable, value are the tokens value.
    // return true if fire succeed. return nil if transition does not exist
    public func manualRun(transitionName : String, binding: [String:String]) -> Bool?{
        return transitions[transitionName]?.fire(manualToken: binding)
    }
    
    // Calculate the Markings (not the binding)
    // In other words, how much state are possible in our Petri Net.
    public func marking() -> Set<[String : [String]]>{
        
        // store markings
        var markings: Set = [getMarking()]
        var previousMarking = markings // for do while loop (break condition)
        
        repeat{ previousMarking = markings // for the break of do while loop. (if state don't change -> fixed point)
            
            for m in markings{ // iterate over all marking
                setMarking(marking: m) // change state of petri net to this marking
                for var t in transitions{
                    
                    var tokensByArcs = [[[String]]]()
                    var bindingsByArcs = [[String]]()
                    for a in t.value.arcsIn {
                        let tokens = a.connectedPlace.tokens.getAsArray()
                        let bindings = a.getBindName()
                        var rWorking = Array(Array<String>(repeating: "", count: bindings.count))
                        var resultArc   = [[String]]()
                        Combinatorix.permutationNoRep(multiset: tokens, rArray: &rWorking, result: &resultArc)
                        tokensByArcs.append(resultArc) // all combination of bindings for a certain place
                        bindingsByArcs.append(bindings)
                    }

                    // caluclate the cartesian product between all the bindings by arcs.
                    let comb = Combinatorix.cardProd(array: tokensByArcs)
                    
                    // Create a dictionnary (before we supposed an order of binding)
                    func makeDict(tokens:[String]) -> [String: String]{
                        var res = [String:String]()
                        let bind:[String] = Array(bindingsByArcs.joined())
                        for b in 0..<bind.count{
                            res[bind[b]] = tokens[b]
                        }
                        return res
                    }
                    
                    //Evaluate function
                    func evaluate(select: [String: String]){
                        if (t.value.fire(manualToken: select)){
                            markings.insert(getMarking())
                            t.value.resetState()}
                    }
                    
                    // Evaluate all the combinatoire
                    for c in comb{
                        let binding = makeDict(tokens: c)
                        evaluate(select: binding)
                    }
                
                }
            }
        }while(markings != previousMarking) // if same, it's a fix point
        print(markings)
        return markings
    }
    
    // get current marking
    private func getMarking() -> [String: [String]]{
        var dict = [String: [String]]()
        
        for p in places {
            dict[p.value.getName()] = p.value.tokens.getAsArray()
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
