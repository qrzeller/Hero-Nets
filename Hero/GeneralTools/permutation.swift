//
//  File.swift
//  Hero
//
//  Created by Quentin Zeller on 31.08.19.
//

import Foundation

class Combinatorix {

    static func permutationNoRep(multiset: [String], rArray: inout [String], index: Int = 0, result: inout [[String]]){
        if (index == rArray.count){result.append(rArray); return}
        
        for i in 0..<multiset.count{ // (data.count)
            var listCp = multiset
            rArray[index] = listCp.remove(at: i)
            permutationNoRep(multiset: listCp, rArray: &rArray, index: index+1, result: &result)
        }
    }
    
    static func cardProd(array: [[[String]]]) -> [[String]]{
        
        var temporaraResult = [[String]]();
        
        var previous: [[String]] = array[0] // reference at each step (if |vectors|>2
        for a in 1..<array.count { // indice to cross product
            let second: [[String]] = array[a]
            
            for b in previous {
                for s in second {
                    temporaraResult.append(b+s)
                }
            }
            previous = temporaraResult // next iteration of more than 2 vectors
            temporaraResult.removeAll()
        }
        
        return previous
        
    }
    

}
