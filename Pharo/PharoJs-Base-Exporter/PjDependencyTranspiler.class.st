Class {
	#name : #PjDependencyTranspiler,
	#superclass : #PjTranspiler,
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #initialization }
PjDependencyTranspiler >> addClassesToConvert: classes [

	analyzer addClassesToConvert: classes
]

{ #category : #initialization }
PjDependencyTranspiler >> addSelectorsToConvert: selectors [
	analyzer addSelectorsToConvert: selectors 
]

{ #category : #initialization }
PjDependencyTranspiler >> analyzerClass [
	^PjDependencyAnalyzer
]

{ #category : #'transpiling classes' }
PjDependencyTranspiler >> convertAll [
	super convertAllClasses: analyzer classesToConvert
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

{ #category : #'transpiling methods' }
PjDependencyTranspiler >> withMethodsOf: aClass do: aBlock [

	(analyzer methodsToConvertFor: aClass) do: aBlock
]
