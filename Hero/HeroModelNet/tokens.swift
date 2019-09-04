//
//  tokens.swift
//  Alpine-test1
//
//  Created by Quentin Zeller on 08.08.19.
//

import Foundation

class Tokens<T: Equatable & Comparable>: CustomStringConvertible{
    var description: String { return tokens.sorted().description }
    // todo MARKING
    
    
    // The token set as an Array (can be changed as accessed by subscript)
    private var tokens = [T]()
    
    init<I : Sequence>(tokens : I) where I.Iterator.Element == T {
        for i in tokens{
            self.tokens.append(i)
        }
    }
    
    // Return nil if does not exist
    subscript(index: Int) -> T?{
        get{
            //assert (tokens.count > index && index >= 0, "Token index does not exist : \(index)")
            return (tokens.count > index && index >= 0) ? tokens[index] : nil
        }
//        set(value){
//            markings[index] = markings.contains(index) ? value : nil
//        }
    }
    
    // Add an element to the token set, Don't chek if already exist
    func add(expr: T){
        //if !markings.contains(expr){
            tokens.append(expr)
        //}
    }
    
    // Delete an element, return nil if range is not ok.
    func del(index: Int) -> T?{
        
        let deleted = self[index] // used to check if exist and return value
        if deleted != nil{
            tokens.remove(at: index)
        }
        return deleted
    }
    func del(value: T) -> T?{
        let index = self.tokens.firstIndex(of: value)
        if index == nil { return nil }
        return del(index: index!)
    }
    

    // ||||||||| Getter & Setter |||||||||||||
    public func getCardinality() -> Int {
        return tokens.count
    }
    
    // sorted is usefull for marking comparison (as those are not sets but multi-set)
    public func getAsArray() -> [T]{
        return tokens.sorted()
    }
    
    // replace completely the tokens by input t
    public func setAlltokens(t :[T]){
        self.tokens = t
    }
}
