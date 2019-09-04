//
//  arcIn.swift
//  Alpine-test1
//
//  Created by Quentin Zeller on 11.08.19.
//

import Foundation

// The arc that goes inside a transition
// It's different from ArcOut as arc out comport labels that we need to evaluate at some point
// Here are only bindings
public struct ArcIn<T: Equatable & Comparable>: CustomStringConvertible{
    public var description: String{
        return """
        📓 ArcIn :
                Name: \(name)
                From place : \(connectedPlace.name)
                Binding : \(bindName)
        """
    }
    // The place that is connected to the arc
    public var connectedPlace: Place<T>

    let bindName: [String]
    let name : String
    
    // label : the label of the arc (a binding here),
    public init(label: String, connectedPlace: Place<T>, name: String = "") {
        
        self.bindName = label.components(separatedBy: CharacterSet([" ", ",", "\t", "\n",])).filter { $0 != "" }
        
        self.name = name
        self.connectedPlace = connectedPlace
        
    }

    // describe how we want to get our token from the place :
    // - random : take token in a random way
    // - predictive : get first token of the datastructure
    enum How {
        case random
        case predictive
    }
    mutating func execute(how : How = .random, delete: Bool = true) -> [String: T?]{
        var binding = [String:T?]()
        
        for i in bindName{
            let param = how == .random ? self.connectedPlace.getRandomValue(delete: delete) :
                                         self.connectedPlace.getAValue(delete: delete)
            binding[i] = param
        }
        
        return binding
    }
    
    //MARK: Getter Setter
    public func getBindName() -> [String]{
        return bindName
    }
    
    // return the name of the place
    public func getName() -> String {
        return name
    }
}
