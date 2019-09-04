
//
//  File.swift
//
//  Created by Quentin Zeller on 06.08.19.
//

import Foundation
import Interpreter

!!! Does not compile !!!

// Define a function that will be executed by our arcs going out.
// Htis function must take in parameter a dictionnary of bindings (key = binding name, value = binding type) the function then integrate the value in the label and execute it. In this case it execute in Alpine
var interpreter = Interpreter()
let module = IOTools.readFile(fileName: filePath)
try! interpreter.loadModule(fromString: module)
let labelExecution = {d, l in LabelTools.dynamicReplace(t: d, label: l, interpreter: interpreter)}


// Create a conater for our Petri Net
let p = PetriNet()
// Load the definition file present in JSON
p.loadDefinitionFile(JSON: fileDef, labelExecution: labelExecution)

// run the transition t1 manually with the binding a=2 and c=sub
p.manualRun(transitionName: "t1", binding: ["a":"2","c":"sub"])

// run a transition randomly
p.randomRun()
// run the transition "t2"
p.transitions["t2"]?.fire()

// List all marking states possible
let allMarking = p.marking()


// ______________ Other example of Swift definition of Petri Nets _________________

let dr = labelExecution

let int = Domain(domainCardinality: 1, domainSet: "Int", codomainCardinality: 0, codomainSet: "")
let f   = Domain(domainCardinality: 1, domainSet: "Int", codomainCardinality: 1, codomainSet: "Int")

let p1 = Place(tokens: ["1", "2", "3", "4"], domain: int, name: "p1")
let p2 = Place(tokens: ["add","sub"], domain: f, name: "p2")
let p3 = Place(tokens: ["10"], domain: int, name: "p3")
let places = [p1,p2,p3]

let a1 = ArcIn(label: "a, b", connectedPlace: p1, name: "a1"); print(a1)
let r1 = ArcOut(label: [{ $0["a"] }, { $0["b"] }], connectedPlace: p1, name: "r4")

let a2 = ArcIn(label: "c", connectedPlace: p2, name: "a2")
let r2 = ArcOut(label: [{ $0["c"] }], connectedPlace: p2, name: "r2")

let lab3 = "operationNoCurry(a: $a$, b: $b$ , op: $c$)"
let a3 = ArcOut(label: [{d in dr(d,lab3)}], connectedPlace: p3, name: "a2"); print(a3)

let t1 = Transition(transitionGuard: [LabelTools.noGuardPrint], arcsIn: [a1,a2], arcsOut: [a3, r1, r2], name: "t1")

let p2 =PetriNet(places: places, transitions: transitions, commonName: "testHero", type: PetriNet.netType.hero)
