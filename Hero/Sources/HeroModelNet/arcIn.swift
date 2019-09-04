//
//  arcIn.swift
//  Alpine-test1
//
//  Created by Quentin Zeller on 11.08.19.
//

import Foundation

public struct ArcIn<T: Equatable & Comparable>: CustomStringConvertible{
    public var description: String{
        return """
        📓 ArcIn :
                Name: \(name)
                From place : \(connectedPlace.name)
                Binding : \(bindName)
        """
    }
    
    public var connectedPlace: Place<T>

    let bindName: [String]
    let name : String
    
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
