Class {
	#name : 'PjImageAnalyzer',
	#superclass : 'Object',
	#category : 'PharoJs-Benchmark-Coverage-Analyzer',
	#package : 'PharoJs-Benchmark-Coverage',
	#tag : 'Analyzer'
}

{ #category : 'utility' }
PjImageAnalyzer class >> inspectAnalysis [

	<example>
	self newAnalysis inspect
]

{ #category : 'utility' }
PjImageAnalyzer class >> newAnalysis [

	^self new newAnalysis
]

{ #category : 'utility' }
PjImageAnalyzer class >> printMetricsOnTranscript [

	<example>
	^self newAnalysis printMetricsOnTranscript; yourself
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> allCompilerClasses [

	^ self allCompilerPackages flatCollect: [ : name | 
		(Smalltalk packageOrganizer packageNamed: name) classes ].
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> allCompilerMethods [

	^ self allCompilerClasses flatCollect: [ : each | each methods ]
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> allCompilerMethodsSendingPragmas [

	| candidatePragmaSelectors |
	candidatePragmaSelectors := self candidatePragmaSelectors.
	^ self allCompilerMethods select: [ :method |
		  self isMethod: method senderOfAny: candidatePragmaSelectors ]
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> allCompilerMethodsSendingPragmasDict [

	| candidatePragmaSelectors associations |
	candidatePragmaSelectors := self candidatePragmaSelectors.
	associations := self allCompilerMethodsSendingPragmas collect: [ :meth |
		                meth ->  (self
			                 allSelectorsIn: candidatePragmaSelectors
			                 sentBy: meth) ].
	^ associations asDictionary
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> allCompilerPackages [
	"From 'CompilerGroup' in BaselineOfPharoBootstrap>>#baseline:"

	^ #( 'AST-Core' 'Collections-Arithmetic' 'Collections-Atomic'
	     'CodeImport' 'CodeImportCommandLineHandlers'
	     'ClassDefinitionPrinters' 'System-SourcesCondenser'
	     'Debugging-Utils' 'OpalCompiler-Core' ) 
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> allMethods [

	^ SystemNavigation default allMethods
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> allPragmaSelectors [

	^ Pragma all asSet collect: #selector
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> allSelectorsIn: selectors sentBy: method [
	^method literals select: [ :aLiteral |
		self isLiteral: aLiteral senderOfAny: selectors ]
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> candidatePragmaSelectors [

	^ self allPragmaSelectors reject: [ :sel |
		  sel beginsWith: #deprecated ]
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> isLiteral: aLiteral senderOfAny: selectors [
	aLiteral isArray ifFalse: [^selectors includes: aLiteral]. 
	^aLiteral anySatisfy: [ : each | self isLiteral: each senderOfAny: selectors ]
]

{ #category : 'anlyzing' }
PjImageAnalyzer >> isMethod: method senderOfAny: selectors [

	^method literals anySatisfy: [ :aLiteral |
		self isLiteral: aLiteral senderOfAny: selectors ]
]

{ #category : 'building' }
PjImageAnalyzer >> newAnalysis [

	^PjMethodsAnalysis new
		allPragmaSelectors: self allPragmaSelectors;
		allMethods: self allMethods;
		yourself
]
