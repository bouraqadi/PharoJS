Class {
	#name : 'TaPragmaAnalysis',
	#superclass : 'Object',
	#instVars : [
		'pragmas',
		'compilationMethods'
	],
	#category : 'PharoJs-Benchmark-Coverage-Analyzer',
	#package : 'PharoJs-Benchmark-Coverage',
	#tag : 'Analyzer'
}

{ #category : 'accessing' }
TaPragmaAnalysis >> compilationMethods [

	^ compilationMethods
]

{ #category : 'accessing' }
TaPragmaAnalysis >> compilationMethods: anObject [

	compilationMethods := anObject
]

{ #category : 'accessing' }
TaPragmaAnalysis >> pragmas [

	^ pragmas
]

{ #category : 'accessing' }
TaPragmaAnalysis >> pragmas: anObject [

	pragmas := anObject
]
