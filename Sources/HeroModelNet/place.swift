//
//  place.swift
//  Alpine-test1
//
//  Created by Quentin Zeller on 08.08.19.
//

import Foundation

// Places have a type of token T. That must be Comparable and Equatable
public struct Place<T: Equatable & Comparable>: CustomStringConvertible {
    public var description: String {
        return """
        📓 Place :
                Tokens : \(tokens)
                Domain : \(domain)
                Name   : \(name)
        """
    }
    
    // Container for markings, of type T
    public let tokens: Tokens<T>
    // Just for information purpose or display.
    var name: String
    // The domain of the tokens (marking)
    let domain: Domain
    
    // Each place have a domain and tokens of type T inside (see class Tokens)
    public init<I : Sequence>(tokens : I, domain: Domain, name: String) where I.Iterator.Element == T {
        self.tokens = Tokens(tokens: tokens)
        self.name = name
        self.domain = domain
    }
    // For JSON serialisation
    public init?(json: [String: Any]){
        let name: String
        let tokens: [T]
        let domain: Domain
        
        if let n = json["name"] as? String{
            name = n
        }else{
            print("Cannot initialise name.")
            return nil
        }
        
        if let t = json["tokens"] as? [T]{
            tokens = t
        }else{print("Could not load tokens."); return nil}
        
        if let d = json["domain"] as? [String: Any]{
            domain = Domain(domainCardinality: d["domainCardinality"] as! Int, domainSet: d["domainSet"] as! String,
                            codomainCardinality: d["codomainCardinality"] as! Int, codomainSet: d["codomainSet"] as! String)
        } else {print("Domain not well defined"); return nil}
        
        self.init(tokens: tokens, domain: domain, name: name)
    }
    // get the first marking
    public func getAValue(delete: Bool = true) -> T?{
        let m = tokens[0]
        if delete {_ = tokens.del(index: 0)}
        return m
    }
    
    // get a random value in the tokens of self
    public func getRandomValue(delete:Bool = true) -> T?{
        let card = tokens.getCardinality()
        if card < 1 {return nil}
        let r = Int.random(in: 0..<card)
        let m = tokens[r]
        if delete{_ = tokens.del(index: r)}
        return m
    }
    
    // Add a token to the place
    mutating func add(token: T){
        tokens.add(expr: token)
    }
    
    
    // ||||||||| Getter & Setter |||||||||||||
    public func getDomain() -> Domain {
        return self.domain
    }
    
    // return the name of the place
    public func getName() -> String {
        return name
    }
    
    // Modify the comments
    mutating func setComment(comment: String){
        self.name = comment
    }

}
