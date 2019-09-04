//
//  arcs.swift
//  Alpine-test1
//
//  Created by Quentin Zeller on 11.08.19.
//

import Foundation

struct ArcOut<PlaceIn: Equatable & Comparable, PlaceOut: Equatable & Comparable>: CustomStringConvertible{

    var description: String{
        return """
        📓 ArcOut:
                Name: \(name)
                To place : \(connectedPlace.name)
                label : \(String(describing: label))
        """
    }
    
    var connectedPlace: Place<PlaceOut>
    
    let label: [([String: PlaceIn]) -> PlaceOut?]
    let debugLabel: [String]
    let name : String
    
    init(label: [([String: PlaceIn]) -> PlaceOut?], debugLabel:[String] = [String](), connectedPlace:  Place<PlaceOut>, name: String = "") {
        self.label          = label
        self.name           = name
        self.connectedPlace = connectedPlace
        self.debugLabel     = debugLabel

    }
     // params for out arcs only    
    // return type can be any because (T or closure/function)
    mutating func execute(transitionParams: [String: PlaceIn]) -> [PlaceOut]{
        
        // let inCard = connectedPlace.getDomain().getDomainCardinality()
        var newMarks = [PlaceOut]()
        for l in label{
            if let newMark = l(transitionParams){
                newMarks.append(newMark)
                connectedPlace.add(token: newMark)
            } else { print("📕 The function \(String(describing: l)) with parameters \(transitionParams) returned nil")}
        }
        return newMarks
        
    }
}
