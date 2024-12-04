Class {
	#name : 'TaTranspilabilityAnalyzer',
	#superclass : 'Object',
	#category : 'PharoJs-Benchmark-Coverage-Analyzer',
	#package : 'PharoJs-Benchmark-Coverage',
	#tag : 'Analyzer'
}

{ #category : 'utility' }
TaTranspilabilityAnalyzer class >> inspectAnalysis [

	<example>
	self newAnalysis inspect
]

{ #category : 'utility' }
TaTranspilabilityAnalyzer class >> newAnalysis [

	^self new newAnalysis
]

{ #category : 'utility' }
TaTranspilabilityAnalyzer class >> printMetricsOnTranscript [

	<example>
	^self newAnalysis printMetricsOnTranscript; yourself
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> allPragmaSelectors [

	^ self allPragmas collect: #selector
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> allPragmas [

	^ Pragma all asSet
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> candidatePragmaSelectors [

	^ self allPragmaSelectors reject: [ :selector |
		  selector beginsWith: #deprecated ]
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> compilationRelatedMethods [

	^ self compilerMethods asSet 
		addAll: self compilerPluginMethods;
		yourself
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> compilerMethods [

	^ self compilerPackages flatCollect: [ : name | 
		(Smalltalk packageOrganizer packageNamed: name) methods ].
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> compilerMethodsSendingPragmaSelectors [

	| candidatePragmaSelectors |
	candidatePragmaSelectors := self candidatePragmaSelectors.
	^ self compilationRelatedMethods select: [ :method |
		  self isMethod: method senderOfAny: candidatePragmaSelectors ]
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> compilerPackages [
	"From 'CompilerGroup' in BaselineOfPharoBootstrap>>#baseline:"

	^ #( 'AST-Core' 'Collections-Arithmetic' 'Collections-Atomic'
	     'CodeImport' 'CodeImportCommandLineHandlers'
	     'ClassDefinitionPrinters' 'System-SourcesCondenser'
	     'Debugging-Utils' 'OpalCompiler-Core' ) 
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> compilerPluginClasses [

	^ OCASTCompilerPlugin withAllSubclasses 
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> compilerPluginMethods [

	^ self compilerPluginClasses flatCollect: [ : class | 
		class methods ].
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> dictionaryWithSelectorsOfPragmasAffectingCompilation [

	| methods selectors dictionary methodSet |
	methods := self compilerMethodsSendingPragmaSelectors.
	selectors := self selectorsOfPragmasAffectingCompilation.
	dictionary := Dictionary new.
	methods do: [ : aMethod | 
		selectors do: [ : aSelector | 
					methodSet := dictionary at: aSelector ifAbsentPut: [ Set new ].
					(self isMethod: aMethod senderOf: aSelector) ifTrue: [ methodSet add: aMethod ]
			] ].
	^dictionary
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> isLiteral: aLiteral equalOrIncludes: selector [

	aLiteral isArray ifFalse: [ ^ aLiteral = selector ].
	^ aLiteral includes: selector
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> isLiteral: aLiteral senderOfAny: selectors [
	aLiteral isArray ifFalse: [^selectors includes: aLiteral]. 
	^aLiteral anySatisfy: [ : each | self isLiteral: each senderOfAny: selectors ]
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> isMethod: method senderOf: selector [

	^ method literals anySatisfy: [ :aLiteral |
		  self isLiteral: aLiteral equalOrIncludes: selector ]
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> isMethod: method senderOfAny: selectors [

	^method literals anySatisfy: [ :aLiteral |
		self isLiteral: aLiteral senderOfAny: selectors ]
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> pragmasAffectingCompilation [
	| selectors |
	selectors := self selectorsOfPragmasAffectingCompilation.
	^self allPragmas select: [ : pragma | selectors includes: pragma selector ]
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> selectorsOfPragmasAffectingCompilation [

	| methods |
	methods := self compilerMethodsSendingPragmaSelectors.
	^ self candidatePragmaSelectors select: [ :selector |
		  methods anySatisfy: [ :compiledMethod |
			  self isMethod: compiledMethod senderOf: selector ] ]
]
