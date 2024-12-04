Class {
	#name : 'TaAnalysis',
	#superclass : 'Object',
	#instVars : [
		'analyzer'
	],
	#category : 'PharoJs-Benchmark-Coverage-Analyzer',
	#package : 'PharoJs-Benchmark-Coverage',
	#tag : 'Analyzer'
}

{ #category : 'analyzing' }
TaAnalysis >> dictionaryWithLowLevelMethods [

	| dictionary methodSet |
	dictionary := Dictionary new.
	analyzer pragmasAffectingCompilation do: [ : pragma |
		methodSet := dictionary at: pragma selector ifAbsentPut: [ Set new ]. 
		methodSet add: pragma method ].
	^dictionary
]

{ #category : 'analyzing' }
TaAnalysis >> dictionaryWithSelectorsOfPragmasAffectingCompilation [

	| methods selectors dictionary methodSet |
	methods := analyzer compilerMethodsSendingPragmaSelectors.
	selectors := analyzer selectorsOfPragmasAffectingCompilation.
	dictionary := Dictionary new.
	methods do: [ : aMethod | 
		selectors do: [ : aSelector | 
					methodSet := dictionary at: aSelector ifAbsentPut: [ Set new ].
					(analyzer isMethod: aMethod senderOf: aSelector) ifTrue: [ methodSet add: aMethod ]
			] ].
	^dictionary
]

{ #category : 'analyzing' }
TaAnalysis >> initialize [ 
	super initialize.
	analyzer := TaTranspilabilityAnalyzer new
]
