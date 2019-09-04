//
//  domain.swift
//  Alpine-test1
//
//  Created by Quentin Zeller on 09.08.19.
//

import Foundation

struct Domain{
    private let domainCardinality : Int
    private let domainSet: String
    
    private let codomainCardinality: Int
    private let codomainSet: String
    
    init(domainCardinality: Int, domainSet: String, codomainCardinality: Int, codomainSet: String) {
        self.domainCardinality = domainCardinality
        self.domainSet = domainSet
        self.codomainCardinality = codomainCardinality
        self.codomainSet = codomainSet
    }
    
    // Getter
    public func getDomainSet() -> String        { return domainSet }
    public func getDomainCardinality() -> Int   { return domainCardinality }
    
    public func getCodomainSet() -> String      { return codomainSet }
    public func getCodomainCardinality() -> Int { return codomainCardinality }

}
