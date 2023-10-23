Class {
	#name : #PjDependencyTranspiler,
	#superclass : #PjTranspiler,
	#instVars : [
		'analyzer'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #initialization }
PjDependencyTranspiler >> addSelectorsToConvert: selectors [
	analyzer addSelectorsToConvert: selectors 
]

{ #category : #initialization }
PjDependencyTranspiler >> analyzerClass [
	^PjDependencyAnalyzer
]

{ #category : #'transpiling classes' }
PjDependencyTranspiler >> convertAllClasses: classes [

	analyzer analyzeAllClasses: classes.
	super convertAllClasses: analyzer classesToConvert
]

{ #category : #'transpiling classes' }
PjDependencyTranspiler >> convertClass: aClass [

^self convertAllClasses: { aClass }
]

{ #category : #initialization }
PjDependencyTranspiler >> initialize [ 
	super initialize.
	analyzer := self analyzerClass new
]

{ #category : #'transpiling methods' }
PjDependencyTranspiler >> withMethodsOf: aClass do: aBlock [

	(analyzer methodsToConvertFor: aClass) do: aBlock
]
