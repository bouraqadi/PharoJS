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

{ #category : 'OLD' }
TaTranspilabilityAnalyzer >> allCompilerMethodsSendingPragmasDict [

	| candidatePragmaSelectors associations |
	candidatePragmaSelectors := self candidatePragmaSelectors.
	associations := self compilerMethodsSendingPragmaSelectors collect: [ :meth |
		                meth ->  (self
			                 allSelectorsIn: candidatePragmaSelectors
			                 sentBy: meth) ].
	^ associations asDictionary
]

{ #category : 'OLD' }
TaTranspilabilityAnalyzer >> allMethods [

	^ SystemNavigation default allMethods
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> allPragmaSelectors [

	^ self allPragmas collect: #selector
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> allPragmas [

	^ Pragma all asSet
]

{ #category : 'OLD' }
TaTranspilabilityAnalyzer >> allSelectorsIn: selectors sentBy: method [
	^method literals select: [ :aLiteral |
		self isLiteral: aLiteral senderOfAny: selectors ]
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> candidatePragmaSelectors [

	^ self allPragmaSelectors reject: [ :selector |
		  selector beginsWith: #deprecated ]
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> compilationRelatedClasses [

	^ self compilerClasses asSet copyWithAll: self compilerPluginClasses 
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> compilationRelatedMethods [

	^ self compilationRelatedClasses flatCollect: [ : each | each methods ]
]

{ #category : 'accessing' }
TaTranspilabilityAnalyzer >> compilerClasses [

	^ self compilerPackages flatCollect: [ : name | 
		(Smalltalk packageOrganizer packageNamed: name) classes ].
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

{ #category : 'OLD' }
TaTranspilabilityAnalyzer >> newAnalysis [

	^TaAnalysis new
		allPragmaSelectors: self allPragmaSelectors;
		allMethods: self allMethods;
		yourself
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> pragmasAffectingCompilation [
	| selectors |
	selectors := self selectorsOfPragmasAffectingCompilation.
	^self allPragmas select: [ : each | selectors includes: each selector ]
]

{ #category : 'analyzing' }
TaTranspilabilityAnalyzer >> selectorsOfPragmasAffectingCompilation [

	| methods |
	methods := self compilerMethodsSendingPragmaSelectors.
	^ self candidatePragmaSelectors select: [ :selector |
		  methods anySatisfy: [ :compiledMethod |
			  self isMethod: compiledMethod senderOf: selector ] ]
]
