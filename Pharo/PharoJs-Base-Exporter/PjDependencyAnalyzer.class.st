Class {
	#name : #PjDependencyAnalyzer,
	#superclass : #PjSkipCodeAnalyzer,
	#instVars : [
		'classesToConvert',
		'newClasses',
		'selectorsToConvert',
		'previousSelectorsDict',
		'methodsToConvertDict',
		'newSelectors'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #analyzing }
PjDependencyAnalyzer class >> analyzeAllClasses: classes [

	^ self new
		  analyzeAllClasses: classes;
		  yourself
]

{ #category : #analyzing }
PjDependencyAnalyzer class >> analyzeClass: aClass [
	^self new
		analyzeClass: aClass;
		yourself 
]

{ #category : #'analyzing classes' }
PjDependencyAnalyzer >> addClassToConvert: aClass [

	self currentClass: aClass.
	classesToConvert add: aClass.
	self addInstanceAndClassMethodsFrom: aClass
]

{ #category : #'analyzing methods' }
PjDependencyAnalyzer >> addDependencyFrom: aLiteral [

	aLiteral isSymbol ifTrue: [ ^ self addNewSelector: aLiteral ].
	( aLiteral value isBehavior )
		ifTrue: [ ^ self addNewClassWithSuperclasses: aLiteral value ]
]

{ #category : #'analyzing methods' }
PjDependencyAnalyzer >> addInstanceAndClassMethodsFrom: aClass [

	{
		aClass.
		aClass class } do: [ :each |
		self addMethodsToConvertFrom: each  ]
]

{ #category : #'analyzing methods' }
PjDependencyAnalyzer >> addMethodsToConvertFrom: aClass [

	| previousSelectors missingSelectors |
	previousSelectors := previousSelectorsDict
		                     at: aClass
		                     ifAbsentPut: [ Set new ].
	missingSelectors := selectorsToConvert copyWithoutAll:
		                    previousSelectors.
	previousSelectors addAll: missingSelectors.
	self addMethodsToConvertFrom: aClass selectors: missingSelectors 
]

{ #category : #'analyzing methods' }
PjDependencyAnalyzer >> addMethodsToConvertFrom: aClass selectors: missingSelectors [

	| methodSelectors methodsToConvert |
	methodsToConvert := methodsToConvertDict
		                    at: aClass
		                    ifAbsentPut: [ IdentitySet new ].
	aClass withMethodSourcesDo: [ :cl |
		methodSelectors := missingSelectors intersection: cl selectors.
		missingSelectors removeAll: methodSelectors.
		self
			addTo: methodsToConvert
			methodsToConvertFrom: cl
			selectors: methodSelectors ]
]

{ #category : #'analyzing classes' }
PjDependencyAnalyzer >> addNewClass: aClass [

	| actualClass |
	actualClass := aClass classToUseForJsConversion.
	newClasses add: actualClass.
	actualClass sharedPools do: [ :pool |
		self addNewClassWithSuperclasses: pool ]
]

{ #category : #'analyzing classes' }
PjDependencyAnalyzer >> addNewClassWithSuperclasses: aClass [

	aClass isPharoOnlyClass ifTrue: [ ^ self ].
	aClass withAllSuperclassesDo: [ :each | self addNewClass: each ]
]

{ #category : #'analyzing methods' }
PjDependencyAnalyzer >> addNewSelector: aSymbol [

	(selectorsToConvert includes: aSymbol) ifTrue: [ ^ self ].
	newSelectors add: aSymbol.
	selectorsToConvert add: aSymbol
]

{ #category : #initialization }
PjDependencyAnalyzer >> addSelectorsToConvert: selectors [
	selectorsToConvert addAll: selectors
]

{ #category : #'analyzing methods' }
PjDependencyAnalyzer >> addTo: methodsToConvert methodToConvert: aCompiledMethod [

	(self shouldSkipMethod: aCompiledMethod) ifTrue: [ ^ self ].
	methodsToConvert add: aCompiledMethod.
	aCompiledMethod literalsDo: [ :each | self addDependencyFrom: each]

]

{ #category : #'analyzing methods' }
PjDependencyAnalyzer >> addTo: methodsToConvert methodsToConvertFrom: aClass selectors: selectors [

	| methods |
	methods := selectors collect: [ :each |
		           aClass compiledMethodAt: each ].
	methods do: [ : each | self addTo: methodsToConvert methodToConvert: each ]
]

{ #category : #analyzing }
PjDependencyAnalyzer >> analyzeAllClasses: classes [

	classes do: [ :each | self addNewClassWithSuperclasses: each ].
	[ newClasses isEmpty ] whileFalse: [ self findNewClasses ]
]

{ #category : #analyzing }
PjDependencyAnalyzer >> analyzeClass: aClass [

	self analyzeAllClasses: { aClass }
]

{ #category : #accessing }
PjDependencyAnalyzer >> classesToConvert [

	^ classesToConvert
]

{ #category : #'analyzing classes' }
PjDependencyAnalyzer >> findNewClasses [

	| startClasses |
	startClasses := newClasses.
	self resetNewClasses.
	self resetNewSelectors.
	startClasses do: [ :each | self addClassToConvert: each ].
	newSelectors ifNotEmpty: [ 
		newClasses addAll: classesToConvert.
		self resetNewSelectors  ]
]

{ #category : #initialization }
PjDependencyAnalyzer >> initialize [

	super initialize.
	classesToConvert := IdentitySet new.
	self resetNewClasses.
	selectorsToConvert := IdentitySet withAll: self rootSelectors.
	previousSelectorsDict := IdentityDictionary new.
	methodsToConvertDict := IdentityDictionary new
]

{ #category : #accessing }
PjDependencyAnalyzer >> methodsToConvertDict [
	^methodsToConvertDict 
]

{ #category : #accessing }
PjDependencyAnalyzer >> methodsToConvertFor: aClass [

	^ self methodsToConvertDict at: aClass
]

{ #category : #initialization }
PjDependencyAnalyzer >> resetNewClasses [

	newClasses := IdentitySet new
]

{ #category : #initialization }
PjDependencyAnalyzer >> resetNewSelectors [

	newSelectors := Set new
]

{ #category : #initialization }
PjDependencyAnalyzer >> rootSelectors [

	^ #( initialize start )
]
