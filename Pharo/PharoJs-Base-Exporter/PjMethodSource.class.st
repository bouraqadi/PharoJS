Class {
	#name : #PjMethodSource,
	#superclass : #Object,
	#instVars : [
		'methodsDict'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #accessing }
PjMethodSource >> >> selector [

	^ self compiledMethodAt: selector 
]

{ #category : #accessing }
PjMethodSource >> at: selector put: aCompiledMethod [
	methodsDict at: selector put: aCompiledMethod 
]

{ #category : #accessing }
PjMethodSource >> compiledMethodAt: selector [

	^ methodsDict at: selector 
]

{ #category : #accessing }
PjMethodSource >> compiledMethodAt: selector ifAbsent: aBlock [

	^ methodsDict at: selector  
		                   ifAbsent: aBlock
]

{ #category : #initialization }
PjMethodSource >> initialize [ 
	super initialize.
	methodsDict := Dictionary new
]

{ #category : #accessing }
PjMethodSource >> selectors [
	^methodsDict keys
]
