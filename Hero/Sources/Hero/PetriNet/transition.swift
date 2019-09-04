//
//  transition.swift
//  Alpine-test1
//
//  Created by Quentin Zeller on 08.08.19.
//

import Foundation

struct Transition<In: Equatable & Comparable, Out: Equatable & Comparable>{

    let transitionGuard: [([String: In]) -> Bool]//([In]) -> Bool
    
    var arcsIn  :[ArcIn<In>] // TODO only binding
    var arcsOut :[ArcOut<In, Out>]
    
    var enabled = true
    let existingBindings: [String]
    
    let name: String
    
    var lastExecutedTokenIn  : [String: In] = [String: In]()
    var lastExecutedTokenOut : [String: [Out]] = [String: [Out]]()
    
    init(transitionGuard: [([String: In]) -> Bool], arcsIn: [ArcIn<In>], arcsOut: [ArcOut<In, Out>], name:String) {
        self.transitionGuard    = transitionGuard
        self.arcsIn             = arcsIn
        self.arcsOut            = arcsOut
        self.name               = name
        
        // store existing bindings (used for manual fire: public mutating func fire(executedToken : [String:In]) -> Bool)
        self.existingBindings = Transition<In, Out>.computebinding(arcsIn: arcsIn)
    }

    // For json serialisation, work only with String type. Thus we assume In==Out==String
    init?(json: [String: [String: Any]], places : [String: Place<In>], labelExecution:@escaping ([String : In], String) -> (Out?) ){
        assert(In.self == String.self && String.self == Out.self, "This initialiser assume types are String")
        
        arcsIn = [ArcIn<In>]()
        arcsOut = [ArcOut<In,Out>]()
        
        if let arcs = json["arcs"]{
            if let ais = arcs["in"] as? [String: [String: Any]]{
                for ai in ais{ // load arcs in from file
                    arcsIn.append(ArcIn(label: ai.value["label"] as! String, connectedPlace: places[ai.value["connectedPlace"] as! String]! , name: ai.value["name"] as! String))
                }
            } else {print("📕 No arcIn found."); return nil}
            
            if let aos = arcs["out"] as? [String: [String: Any]]{
                for ao in aos{ // load arc out from file
                    var labels = [([String : In]) -> (Out?)]() // executed labels
                    var debugLabels = [String]() // for debig only
                    for l in LabelTools.multiLabel(labels: ao.value["label"] as! String){
                        labels.append({d in labelExecution(d, l)})
                        debugLabels.append(l)
                    }
                    arcsOut.append(ArcOut(label:labels, debugLabel: debugLabels,
                                          connectedPlace: places[ao.value["connectedPlace"] as! String] as! Place<Out> ,
                                          name: ao.value["name"] as! String))
                }
            } else {print("📕 No arcOut found."); return nil}
            
        }else{print("📕 No arcs found"); return nil}
        
        if let codeGuard = json["guards"]?["code"] as? String{
            var guards = [([String: In]) -> Bool]()
            for c in LabelTools.multiLabel(labels: codeGuard){
                guards.append({(d: [String: In]) -> Bool in LabelTools.asBool(output: labelExecution(d, c) as! String?)})
            }
            transitionGuard = guards
        } else {
            print("📙 No proper guard found, assume no guard")
            transitionGuard = [{d in return true}]
        }
        self.existingBindings = Transition<In, Out>.computebinding(arcsIn: arcsIn)
        if let name = json["meta"]?["name"] as? String {
            self.name = name
        }else{
            print("📕 The name is not defined, and required in the class petriNet")
            return nil
        }
        
    }
    
    // compute all bindings entry, used only in *init()*
    private static func computebinding(arcsIn: [ArcIn<In>]) -> [String]{
        var bindings = [String]()
        for a in arcsIn {
            bindings.append(contentsOf: a.bindName)
        }
        return bindings
    }
    
    
    public mutating func fire() -> Bool{
        if !enabled{ return false }
        
        // marking from place, executed by the labels
        var executedToken         = [String: In]()
        var reset = false
        for var i in arcsIn{
            let inMarks = i.execute()
            for inMark in inMarks{
                if inMark.value != nil{
                    executedToken[inMark.key] = inMark.value
                } else { // probably mean that we have not enough token in our place
                    print("📙 One binding could not be performed, Arc:\(i.name), \(inMark), probably no more token")
                    reset = true // because we need to fill all variable in order to reset them
                }
            }
            
            if reset { // some arc failed, reset state
                resetState(tokens: executedToken)
                return false
            }
        }
        
        // ---------------- Check guards -------------------------------
        // If guard did not validate, return token to state.
        if !computeGuard(executedToken: executedToken){ return false }
        
        // _______________ Execute out arcs _____________________________
        
        execOutArcs(executedToken: executedToken)
        return true
    }
    
    // Fire with pre defined tokens (manual fire)
    public mutating func fire(manualToken : [String: In]) -> Bool{
        if !enabled{ return false }
        if manualToken.count != existingBindings.count {
            print("📕 The size of the dictionnary must match the count of the bindings.")
            return false
        }
        // Check if tokens exists
        var executedToken         = [String: In]()
        for token in manualToken{
            // check is biniding exist, (overkill since next section is sufficient but usefull for debug)
            if(!existingBindings.contains(token.key)){
                print("📕 The binding \"\(token.key)\" does not exist.")
                print("\t\tAvailable binding : \(existingBindings)")
                return false
            }
            // check if value is in places
            for a in arcsIn{
                if a.bindName.contains(token.key) {
                    if let deleted = a.connectedPlace.tokens.del(value: token.value){
                        executedToken[token.key] = deleted // same as = token.value
                        break // does not need to search further...
                    }else{
                        print("📕 Token \(token) does not exist")
                        self.resetState(tokens: executedToken)
                        return false
                    }
                }
            }
        }
        // ---------------- Check guards -------------------------------
        // If guard did not validate, return token to state.
        if !computeGuard(executedToken: executedToken){
            return false
        }
        // _______________ Execute out arcs _____________________________
        execOutArcs(executedToken: executedToken)
        return true
    }
    
    // checck if guard holds, otherwise refill the places with the tokens
    private mutating func computeGuard(executedToken: [String: In]) -> Bool{
        self.lastExecutedTokenIn.removeAll()// for trace and reset (marking)
        self.lastExecutedTokenOut.removeAll()// for trace and reset (marking)

        for f in transitionGuard{
            if !f(executedToken) {
                print("📙 The guard failed")
                self.resetState(tokens: executedToken)
                return false
            }
        }
        return true
    }
    
    private mutating func execOutArcs(executedToken: [String: In]){
        for var i in arcsOut{
            let outMark = i.execute(transitionParams: executedToken)
            print("""
                📗 The execution \(i.name),
                    bindings: \(executedToken),
                    with the label \(i.debugLabel)
                    returned: \(outMark)
                """)
            self.lastExecutedTokenOut[i.name] = outMark // for trace and reset (marking)
        }
        
        self.lastExecutedTokenIn  = executedToken // for trace and reset (marking)
    }
    
    public mutating func disable(){
        self.enabled = false
    }
    
    public mutating func enable(){
        self.enabled = true
    }
    
    
    // used to calculate all the marking efficiently
    public mutating func resetState(){
        print("🔷 Reset state and removing evaluated expression : ", lastExecutedTokenOut)
        self.resetState(tokens: lastExecutedTokenIn)
        
        for a in arcsOut {
            let arcName = a.name
            if let toRemove = self.lastExecutedTokenOut[arcName]{
                for r in toRemove{
                    _ = a.connectedPlace.tokens.del(value: r)
                }
            } else {print("empty list to remove ..reset state..")}
        }
    }
    
    // Put back token in the places
    private mutating func resetState(tokens: [String: In]) -> Void{
        print("📙 Refill values: \(tokens)")
        
        for i in tokens{
            for var arc in arcsIn{
                if( arc.bindName.contains(where: {$0 == i.key})){ // if the mapping belong to this arc
                    arc.connectedPlace.add(token: i.value) // add the token to the connected place
                    print("\t\tToken \(i.value) put back to arc \(arc.name)")
                }
            }
        }
    }
}
