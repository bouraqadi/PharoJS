Class {
	#name : #PjCoverageTranspilerTest,
	#superclass : #TestCase,
	#instVars : [
		'factory',
		'result',
		'class'
	],
	#category : #'PharoJs-Base-Exporter-Tests-Tests'
}

{ #category : #tests }
PjCoverageTranspilerTest >> assertSuccessSelectors: successSelectors [ 
self assertSuccessSelectors: successSelectors failedSelectors: #()

]

{ #category : #tests }
PjCoverageTranspilerTest >> assertSuccessSelectors: successSelectors failedSelectors: failedSelectors [

self assertSuccessSelectors: successSelectors failedSelectors: failedSelectors skippedSelectors: #()

]

{ #category : #tests }
PjCoverageTranspilerTest >> assertSuccessSelectors: successSelectors failedSelectors: failedSelectors skippedSelectors: skippeSelectors [

	failedSelectors ifEmpty: [ self deny: result isMethodTranspilationFailed.
 ] ifNotEmpty: [  self assert: result isMethodTranspilationFailed.
  ].
	self
		assertCollection: result successSelectors
		hasSameElements: successSelectors.
	self
		assertCollection: result failedSelectors
		hasSameElements: failedSelectors.
	self
		assertCollection: result skippedSelectors
		hasSameElements: skippeSelectors
]

{ #category : #tests }
PjCoverageTranspilerTest >> setUp [

	super setUp.
	factory := ClassFactoryForTestCase new.
	class := factory newClass
]

{ #category : #tests }
PjCoverageTranspilerTest >> tearDown [ 
	factory cleanUp.
	super tearDown.

]

{ #category : #tests }
PjCoverageTranspilerTest >> testClassDeclarationTranspilationFailure [

	class := nil.
	self transpile.
	self deny: result isSuccess.
	self assert: result isClassDeclarationFailed.
	self assertSuccessSelectors: #(  )
]

{ #category : #tests }
PjCoverageTranspilerTest >> testTranspileClassWith1EmptyMethod [

	class compile: #m.
	self transpile.
	self assert: result isSuccess.
	self deny: result isClassDeclarationFailed.
	self assertSuccessSelectors: #( m )
]

{ #category : #tests }
PjCoverageTranspilerTest >> testTranspileClassWith1PrimitiveMethod [

	class
		compile: 'failingPrimitive
	<primitive: 110>';
		compile: 'passingPrimitive
	<primitive: 110>
	self alternativeCode';
		compile: #m1;
		compile: #m2.
	self transpile.
	self deny: result isSuccess.
	self deny: result isClassDeclarationFailed.
	self
		assertSuccessSelectors:#( m1 m2 passingPrimitive )
	failedSelectors: #( failingPrimitive )
]

{ #category : #tests }
PjCoverageTranspilerTest >> testTranspileClassWithMethodAccessingThisContext [

	class
		compile: 'currentContext
	^thisContext';
		compile: #m1;
		compile: #m2.
	self transpile.
	self deny: result isSuccess.
	self deny: result isClassDeclarationFailed.
	self
		assertSuccessSelectors: #( m1 m2 ) failedSelectors: #( currentContext )
]

{ #category : #tests }
PjCoverageTranspilerTest >> testTranspileEmptyClass [

	self transpile.
	self assert: result isSuccess.
	self deny: result isClassDeclarationFailed.
	self assertSuccessSelectors: #(  )
]

{ #category : #tests }
PjCoverageTranspilerTest >> testTranspileSkippedMethod [

	class
		compile: 'skippedMethodA
	<pharoJsSkip>';
		compile: 'skippedMethodB
	<pharoJsSkip>';
		compile: #m1;
		compile: #m2.
	self transpile.
	self assert: result isSuccess.
	self deny: result isClassDeclarationFailed.
	self
		assertSuccessSelectors: #( m1 m2 )
		failedSelectors: #()
		skippedSelectors: #( skippedMethodA skippedMethodB )
]

{ #category : #tests }
PjCoverageTranspilerTest >> transpile [

	result := self transpileClass: class
]

{ #category : #tests }
PjCoverageTranspilerTest >> transpileClass: aClass [

	^ PjCoverageAnalysisTranspiler  new convertClass: aClass
]
