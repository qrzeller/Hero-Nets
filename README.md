# HeroNetSimulation
This repository aim to model a HeroNet in the Swift language from a definition file.

## Informations
The language used is *Swift 5.2* and compiled using Xcode IDE.
All files for the xcode project are present and useful if you want to use the unitTests.
This xcode project is a terminal one, thus some definition files are moved in /tmp/hero/ for convenience, check to allow access.
It use librairies from [AlpineLang](https://github.com/kyouko-taiga/AlpineLang) and the exemple interpreter of the expression is Alpine.

## How to build ?
This installation come with a Xcode project.
The dependencies are located in this [path](./HeroSim/.build/checkouts) path.
To load them, enable git submodules with the commande : `git submodule init`
To download them: `git submodule update`
You should be ready to go.
Be sure the IDE have enought access to load file in `/tmp/hero` but this should not be a problem as it's tempory ramdisk.


## How to use ?

Here is an example : 
```
import Foundation
import Interpreter

// the path to the definition file in Alpine
let filePath = "/tmp/hero/curry.alpine"
// the path to the definition of the Hero net
let fileDef  = "/tmp/hero/hnet.json"

// the alpine interpreter
var interpreter = Interpreter()
let module = PetriNet.readFile(fileName: filePath)
try! interpreter.loadModule(fromString: module)

// A function that is called each time we want to evaluate a label.
//The parameters are a dictionnary of bindings ("variable": token)
let labelExecution = {d, l in LabelTools.dynamicReplace(t: d, label: l, interpreter: interpreter)}

// The petri net (All data are string), if you want to use something else, see the module `HeroModelNet`
let p = PetriNet()
// Load the JSON file definition
p.loadDefinitionFile(path: fileDef, labelExecution: labelExecution)

// Run the transition
p.manualRun(transitionName: "t1", binding: ["a":"2","c":"sub"])
p.randomRun()
p.transitions["t2"]?.fire()

// Calculate the marking possible (not bindings)
let allMarking = p.marking()

```

### To load a file Hero-Net
1. First you need to define a closure able to understand the labels of your Hero net : (An example in the language alpine is implemented on line 20 of the main)
This closure is of the form : `([String : String], String) -> String?)`
1. The first parameter is a dictionnary key value. The key is the name of the binding, the value is the actual value binded.
2. The second parameter is the label of some arc.
2. You can the call :
`let p = PetriNet()
p.loadDefinitionFile(path: fileDef, labelExecution: labelExecution)`
We create the Petri Net class (Which accept only String expression)
And the we load the definition file, with the path : fileDef
3. An exemple of definition file : [example](./HeroSim/Sources/Hero/hnet.json)

## Explanation of the definition file
See the [example](./HeroSim/Sources/Hero/hnet.json).
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
The bindings ofr the in arcs are simply separated by a comma `,`. ex : "a, b". We want to take two value in our places and bind them to respectively `a` and `b`.
If a binding does not exist, the proposed closure expression interpreter assume it's a partial application.
