Class {
	#name : #PjDependencyTranspiler,
	#superclass : #PjTranspiler,
	#instVars : [
		'analyzer'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #'transpiling classes' }
PjDependencyTranspiler >> convertAllClasses: classes [

	analyzer := PjDependencyAnalyzer analyzeAllClasses: classes.
	super convertAllClasses: analyzer classesToConvert
]

{ #category : #'transpiling classes' }
PjDependencyTranspiler >> convertClass: aClass [

^self convertAllClasses: { aClass }
]

{ #category : #'transpiling methods' }
PjDependencyTranspiler >> withMethodsOf: aClass do: aBlock [

	(analyzer methodsToConvertFor: aClass) do: aBlock
]
