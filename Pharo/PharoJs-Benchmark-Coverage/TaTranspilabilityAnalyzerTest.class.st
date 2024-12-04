Class {
	#name : 'TaTranspilabilityAnalyzerTest',
	#superclass : 'TestCase',
	#instVars : [
		'analyzer'
	],
	#category : 'PharoJs-Benchmark-Coverage-Analyzer',
	#package : 'PharoJs-Benchmark-Coverage',
	#tag : 'Analyzer'
}

{ #category : 'running' }
TaTranspilabilityAnalyzerTest >> setUp [
	super setUp.
	analyzer := TaTranspilabilityAnalyzer new.
]

{ #category : 'running' }
TaTranspilabilityAnalyzerTest >> testAllPragmaSelectors [
	| selectorsCount |
	selectorsCount := analyzer allPragmaSelectors size.
	self assert: selectorsCount < 120.
	self assert: selectorsCount > 80
]

{ #category : 'running' }
TaTranspilabilityAnalyzerTest >> testAllPragmas [
	self assert: analyzer allPragmas size > 8000.
]

{ #category : 'running' }
TaTranspilabilityAnalyzerTest >> testPragmasAffectingCompilation [

	| pragmas pragmassCount | 
	pragmas := analyzer pragmasAffectingCompilation.
	pragmassCount := pragmas size.
	self assert: pragmassCount < 1000.
	self assert:
		pragmassCount > analyzer selectorsOfPragmasAffectingCompilation size
]

{ #category : 'running' }
TaTranspilabilityAnalyzerTest >> testSelectorsOfPragmasAffectingCompilation [
	| selectors primitiveSelectors selectorsCount |
	selectors := analyzer selectorsOfPragmasAffectingCompilation.
	primitiveSelectors := #(#primitive: #primitive:module: #primitive:error: #primitive:module:error: #primitive:error:module:).
	self assertCollection: selectors includesAll: primitiveSelectors.
	selectorsCount := selectors size.
	self assert: selectorsCount < 20.
	self assert: selectorsCount > primitiveSelectors size
]
