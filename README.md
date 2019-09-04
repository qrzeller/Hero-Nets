# HeroNetSimulation
This repository aim to model a HeroNet in the Swift language from a definition file.

## Informations
The language used is *Swift 5.2* and compiled using Xcode IDE.
It use librairies from [AlpineLang](https://github.com/kyouko-taiga/AlpineLang) and the exemple interpreter of the expression is Alpine.
The build command take care of the import.

## How to build ?
You can build with the terminal using : `swift build`  
Then you can generate an XCode package : `swift package generate-xcodeproj`  
You can test in XCode or by terminal : `swift test`  

## How to use ?

Here is an example : 
[Swift example](./main.swift)
This example is not part of the project as it's a library.
You can find other example of use in the tests of course.

### To load a file Hero-Net
1. First you need to define a closure able to understand the labels of your Hero net : (An example in the language alpine is implemented on line 20 of the main)
This closure is of the form : `([String : String], String) -> String?)`
1. The first parameter is a dictionnary key value. The key is the name of the binding, the value is the actual value binded.
2. The second parameter is the label of some arc.
2. You can the call :  
`let p = PetriNet()` 
`p.loadDefinitionFile(path: fileDef, labelExecution: labelExecution)`  
We create the Petri Net class (Which accept only String expression)
And the we load the definition file, with the path : fileDef  
3. An exemple of definition file : [example](./HeroSim/Sources/Hero/hnet.json)

## Explanation of the definition file
See the [example](./Tests/Data/hnet.json).
- It's in json format
- It's a dictionnary that require an object transitions containing all our transitions and an object places containing all our places.
- The transition contain arcs object and guard object,
- - Arcs contain `in` and `out` object, thoses list and define the arcs between transition and places, thus containing the places it point to. They contain as well the labels / expression of the arcs
- - Guards are as well expression that must return the string "true" for it to be open.
- Our places are also object
- - They contain the domain of definition of our expression. (codomain are set to 0 if we speak about value and not function)
- - They contain a list of tokens, our expressions.

### Some more info
Our label (arcs and guard) are multiset of expression. The separator is `;`.
Bindings are delimited by `$` keyword on our out arcs. It's how we determine how to integrate the tokens in the expression. Ex : "substract(firstOperand: $a$, secondOperand: $b$)"
The bindings of the in arcs are simply separated by a comma `,`. ex : "a, b". We want to take two value in our places and bind them to respectively `a` and `b`.
If a binding does not exist, the proposed closure expression interpreter assume it's a partial application.
To prevent the evaluation of a label (because we want to but back a token that is a function into his respective place. Just define it as a String. If you use our interpreter example and Alpine just do "\\"$fun$\\"".
