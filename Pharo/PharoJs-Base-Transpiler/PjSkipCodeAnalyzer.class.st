Class {
	#name : #PjSkipCodeAnalyzer,
	#superclass : #Object,
	#instVars : [
		'currentClass'
	],
	#category : #'PharoJs-Base-Transpiler-Kernel'
}

{ #category : #accessing }
PjSkipCodeAnalyzer >> currentClass [

	^ currentClass
]

{ #category : #accessing }
PjSkipCodeAnalyzer >> currentClass: anObject [

	currentClass := anObject
]

{ #category : #accessing }
PjSkipCodeAnalyzer >> methodsToConvertFor: aClass [

	| methods |
	methods := aClass selectorsWithExplicitOrigin collect: [ :sel |
		aClass compiledMethodAt: sel ].
	^ methods reject: [ :each | self shouldSkipMethod: each ]
]

{ #category : #'analyzing methods' }
PjSkipCodeAnalyzer >> shouldSkipMethod: aCompiledMethod [

	^ aCompiledMethod isPharoOnly or: [
		  currentClass methodsToSkip includes: aCompiledMethod ]
]
