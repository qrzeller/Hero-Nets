//
//  labelTools.swift
//  AST
//
//  Created by Quentin Zeller on 23.08.19.
//

import Foundation
import Interpreter

// some function / closure to use for the labels of arcs
public struct LabelTools{
    
    // replace dynamically the opération
    public static func dynamicReplace(t: [String: String], label: String, interpreter: Interpreter) -> String? {
        if label == "" { return "true"} // return true of label inexistant
        var lab = label ; var partial = false
        var searchRg:Range<String.Index> = lab.startIndex..<lab.endIndex
        while let idx = lab.range(of: "[$].*?[$]", options: .regularExpression, range: searchRg) {
            let rep = lab[lab.index(after: idx.lowerBound)..<lab.index(before: idx.upperBound)] // remove delimiter
            if let bind = t[String(rep)] {
                lab.replaceSubrange(idx, with: bind)
                searchRg = idx.lowerBound..<lab.endIndex // take again replacement in search (can provide flexible petri net)
            } // check if exist in binding
            else { print("\t📓 Partial application found.");
                partial = true
                searchRg = lab.index(after: idx.upperBound)..<lab.endIndex // skip already searched pattern
            }
            
        }
        if partial { return lab }
        do {
            let value = try interpreter.eval(string: lab)
            return value.description
        }catch{
            print("📕 The interpreter cannot parse the input label, check the correct label definition")
            return nil
        }
        
    }
    
    // Transform output of swift in boolean, return false if other object than "True"
    public static func asBool(output: String?) -> Bool{
        return output?.uppercased() == "true".uppercased()
    }
    
    // Basic function, example function if you want to personalise the labels execution
    public static let opNoCurry = { (t: [String: String], interpreter: Interpreter) -> String? in
        let code: String = "operationNoCurry(a: \(t["a"]!), b: \(t["b"]!) , op: \(t["c"]!))"
        let value = try! interpreter.eval(string: code)
        return value.description
    }
    
    // Does not guard but print output
    public static let noGuardPrint = { (a: [String: String]) -> Bool in
        print("Guarded : \(a).")
        return true
    }
    
    public static func multiLabel(labels: String, sep:Character = ";") -> [String] {
        return labels.components(separatedBy: [";"])
    }
}
