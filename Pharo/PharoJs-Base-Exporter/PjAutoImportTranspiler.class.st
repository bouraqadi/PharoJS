Class {
	#name : #PjAutoImportTranspiler,
	#superclass : #PjTranspiler,
	#instVars : [
		'classesToConvert',
		'newClasses',
		'selectorsToConvert',
		'previousSelectorsDict',
		'methodsToConvertDict'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #'transpiling classes' }
PjAutoImportTranspiler >> addClassToConvert: aClass [

	classesToConvert add: aClass.
	self addInstanceAndClassMethodsFrom: aClass
]

{ #category : #'transpiling methods' }
PjAutoImportTranspiler >> addInstanceAndClassMethodsFrom: aClass [

	{
		aClass.
		aClass class } do: [ :each |
		self addMethodsToConvertFrom: each  ]
]

{ #category : #'transpiling methods' }
PjAutoImportTranspiler >> addMethodsToConvertFrom: aClass [

	| previousSelectors missingSelectors |
	previousSelectors := previousSelectorsDict
		                     at: aClass
		                     ifAbsentPut: [ Set new ].
	missingSelectors := selectorsToConvert copyWithoutAll:
		                    previousSelectors.
	previousSelectors addAll: missingSelectors.
	self addMethodsToConvertFrom: aClass selectors: missingSelectors 
]

{ #category : #'transpiling methods' }
PjAutoImportTranspiler >> addMethodsToConvertFrom: aClass selectors: missingSelectors [

	| methodSelectors methodsToConvert |
	methodSelectors := missingSelectors intersection: aClass selectors.
	methodsToConvert := methodsToConvertDict
		                    at: aClass
		                    ifAbsentPut: [ IdentitySet new ].
	self 
		                  addTo: methodsToConvert 
		methodsToConvertFrom: aClass
		                  selectors: methodSelectors.

]

{ #category : #'transpiling classes' }
PjAutoImportTranspiler >> addNewClass: aClass [

	newClasses add: aClass classToUseForJsConversion.

]

{ #category : #'transpiling classes' }
PjAutoImportTranspiler >> addNewClassWithSuperclasses: aClass [

	aClass withAllSuperclassesDo: [ :each | self addNewClass: each ]
]

{ #category : #'transpiling methods' }
PjAutoImportTranspiler >> addTo: methodsToConvert methodToConvert: aCompiledMethod [
	"self shouldSkipMethodNode: aCompiledMethod"

	self flag: #'add support for skip pragma'.
	methodsToConvert add: aCompiledMethod
]

{ #category : #'transpiling methods' }
PjAutoImportTranspiler >> addTo: methodsToConvert methodsToConvertFrom: aClass selectors: selectors [

	| methods |
	methods := selectors collect: [ :each |
		           aClass compiledMethodAt: each ].
	methods do: [ : each | self addTo: methodsToConvert methodToConvert: each ]
]

{ #category : #accessing }
PjAutoImportTranspiler >> classesToConvert [

	^ classesToConvert
]

{ #category : #transpiling }
PjAutoImportTranspiler >> convertAllClasses: classes [

	classes do: [ :each | self addNewClassWithSuperclasses: each ].
	[ newClasses isEmpty ] whileFalse: [ self findNewClasses ].
	super convertAllClasses: classesToConvert
]

{ #category : #transpiling }
PjAutoImportTranspiler >> convertClass: aClass [

	self convertAllClasses: { aClass } writeDnu: self shouldWriteDnu
]

{ #category : #'transpiling classes' }
PjAutoImportTranspiler >> findNewClasses [

	| startClasses |
	startClasses := newClasses.
	self resetNewClasses.
	startClasses do: [  :each | self addClassToConvert: each ]
]

{ #category : #initialization }
PjAutoImportTranspiler >> initialize [

	super initialize.
	classesToConvert := IdentitySet new.
	self resetNewClasses.
	selectorsToConvert := Set withAll: #( initialize start ).
	previousSelectorsDict := IdentityDictionary new.
	methodsToConvertDict := IdentityDictionary new.
]

{ #category : #accessing }
PjAutoImportTranspiler >> methodsToConvertDict [
	^methodsToConvertDict 
]

{ #category : #initialization }
PjAutoImportTranspiler >> resetNewClasses [

	newClasses := IdentitySet new
]
