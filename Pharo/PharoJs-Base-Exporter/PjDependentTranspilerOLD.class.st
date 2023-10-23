"
I am a PjTranspiler where convertAllClasses: automatically includes any classes required by the given classes
"
Class {
	#name : #PjDependentTranspilerOLD,
	#superclass : #PjTranspiler,
	#instVars : [
		'convertedMethods',
		'classesToConvert',
		'convertedClasses',
		'alreadyDefinedClasses',
		'alreadyInitializedClasses',
		'alreadyVariablesDeclaredClasses'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #accessing }
PjDependentTranspilerOLD class >> lineEnding [
	^Character lf
]

{ #category : #accessing }
PjDependentTranspilerOLD >> addAlreadyDefinedClasses: classes [

	alreadyDefinedClasses addAll: classes
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> addClassToConvert: aClass [

	| addClass |
	addClass := aClass classToUseForJsConversion.
	(classesToConvert includes: addClass) ifFalse: [ " redundant test allows setting breakpoint for adding classes "
		addClass == PjTranspiler ifTrue: [ self halt ].
		addClass == Random ifTrue: [ self halt ].
		classesToConvert add: addClass ]
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> addClassesToConvert: classes [

	classes do: [ :aClass | self addClassToConvert: aClass ]
]

{ #category : #loading }
PjDependentTranspilerOLD >> alreadyConvertedClasses: classes [

	convertedClasses addAll: classes
]

{ #category : #accessing }
PjDependentTranspilerOLD >> beforeCodeOutputHook: aBlock [

	super beforeCodeOutputHook: [ aBlock value: globalPools ]
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> convertAllClasses: classes [

	| newClasses |
	newClasses := OrderedCollection new.
	[ classesToConvert isEmpty ] whileFalse: [
		| theseClasses |
		theseClasses := classesToConvert.
		classesToConvert := Set new.
		theseClasses do: [ :aClass |
			self convertMethodAsts: aClass instanceSide newClasses: newClasses ] ].
	super convertAllClasses: newClasses
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> convertAndWriteClosedBlock: valuedBlock [

	self convertAndWriteClosedBlock: valuedBlock with: [
		self convertAllClasses: #() writeDnu: self shouldWriteDnu
	]
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> convertClass: aClass [

	self convertAllClasses: { aClass } writeDnu: self shouldWriteDnu
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> convertMethodAst: aMethod [
	(self shouldSkipMethod: aMethod) ifTrue: [ ^self ].
	^convertedMethods at: aMethod ifAbsentPut: [
		converter
			classForConversion: aMethod methodClass classToUseForJsConversion;
			convertAst: aMethod ast withPrimitive: aMethod primitive]
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> convertMethodAsts: aClass newClasses: newClasses [

	(convertedClasses includes: aClass)
		ifFalse: [ aClass superclass
				ifNotNil: [ self addClassToConvert: aClass superclass ].
			self
				addClassesToConvert: (aClass instanceSide sharedPools reject: #isPharoOnlyClass).
			convertedClasses add: aClass.
			newClasses add: aClass ].
	self
		withMethodsOf: aClass
		do: [ :aMethod | self convertMethodAst: aMethod ].
	self
		withMethodsOf: aClass class
		do: [ :aMethod | self convertMethodAst: aMethod ]
]

{ #category : #loading }
PjDependentTranspilerOLD >> discoveredGlobalsPool: aClass [

	globalPools add: aClass
]

{ #category : #loading }
PjDependentTranspilerOLD >> discoveredReferenceToClass: aClass [

	^ self addClassToConvert: aClass
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> generateCodeStringFrom: jsAst [

	self convertAllClasses: classesToConvert.
	super generateCodeStringFrom: jsAst
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> importMethodsAll: aCollection forClass: aClass [
	| importMethods |
	importMethods := Dictionary new.
	aCollection
		do: [ :aSymbol | 
			(aClass instanceSide hasClassMethod: aSymbol)
				ifTrue: [ (aClass instanceSide perform: aSymbol)
						associationsDo: [ :assoc | 
							importMethods
								at: assoc key
								ifPresent: [ :im | im value addAll: assoc value ]
								ifAbsent: [ importMethods at: assoc key put: assoc value asSet ] ] ] ].
	^ importMethods
]

{ #category : #initialization }
PjDependentTranspilerOLD >> initialize [

	super initialize.
	convertedMethods := IdentityDictionary new.
	classesToConvert := Set new.
	convertedClasses := Set new.
	alreadyDefinedClasses := Set new.
	alreadyInitializedClasses := Set new.
	alreadyVariablesDeclaredClasses := Set new.

]

{ #category : #invalidating }
PjDependentTranspilerOLD >> invalidateClass: aClass [

	convertedClasses remove: aClass ifAbsent: [  ].
	alreadyDefinedClasses remove: aClass ifAbsent: [  ].
	self invalidateMethods:
		aClass classToUseForJsConversion instanceSide methods.
	self invalidateMethods:
		aClass classToUseForJsConversion classSide methods
]

{ #category : #invalidating }
PjDependentTranspilerOLD >> invalidateMethod: aMethod [

	convertedMethods removeKey: aMethod ifAbsent: [].
]

{ #category : #invalidating }
PjDependentTranspilerOLD >> invalidateMethods: aCollection [

	aCollection do: [ : method | self invalidateMethod: method ]
]

{ #category : #statistics }
PjDependentTranspilerOLD >> numberOfClasses [

	^ convertedClasses size
]

{ #category : #statistics }
PjDependentTranspilerOLD >> numberOfMethods [

	^ convertedMethods size
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> transpileMethod: aMethod [

	| jsAst |
	jsAst := self convertMethodAst: aMethod.
	generator asString: jsAst on: self jsStream
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> withMethodsOf: aClass do: aBlock [

	| nonOverriddenSelectors importMethods methodsToOutput |
	methodsToOutput := OrderedCollection new.
	super withMethodsOf: aClass do: [: method | methodsToOutput add: method].
	importMethods := self
		importMethodsAll: #(jsTranspilationImportMethods jsTranspilationImportMethodsNonstandard)
		forClass: aClass.
	importMethods keysAndValuesDo: [ : class : selectors |
		class isMeta = aClass isMeta ifTrue: [
			nonOverriddenSelectors := selectors copyWithoutAll: aClass selectors.
			nonOverriddenSelectors do: [ : aSymbol |
				methodsToOutput add: (class compiledMethodAt: aSymbol) ]]].
	methodsToOutput sort: [: l : r | l selector < r selector ].
	methodsToOutput do: aBlock.
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> writeClassDefinitionOf: aClass [

	alreadyDefinedClasses addIfNotPresent: aClass ifPresentDo: [ ^ self ].
	super writeClassDefinitionOf: aClass
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> writeClassInitializeOf: aClass [

	alreadyInitializedClasses addIfNotPresent: aClass ifPresentDo: [ ^ self ].
	super writeClassInitializeOf: aClass
]

{ #category : #transpiling }
PjDependentTranspilerOLD >> writeClassVariableDeclarationsOf: aClass [

	alreadyVariablesDeclaredClasses addIfNotPresent: aClass ifPresentDo: [ ^ self ].
	super writeClassVariableDeclarationsOf: aClass
]
