//
//  Others.swift
//  AlpineSpecific
//
//  Created by Quentin Zeller on 04.09.19.
//

import Foundation

public struct IOTools{
    
    // read a file and transform it to String
    public static func readFile(fileName: String) -> String{
        do {
            let contents = try NSString(contentsOfFile: fileName, encoding: 4)
            return contents as String
        } catch {
            // contents could not be loaded
            print("Error info: \(error)")
            return "not loaded"
        }
    }
    
    
}
