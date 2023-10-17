Class {
	#name : #PjDependencyAnalyzerTest,
	#superclass : #TestCase,
	#instVars : [
		'analyzer',
		'factory'
	],
	#category : #'PharoJs-Base-Exporter-Tests-Tests'
}

{ #category : #running }
PjDependencyAnalyzerTest >> analyzeClass: aClass [

	analyzer := PjDependencyAnalyzer new.
	analyzer analyzeClass: aClass
]

{ #category : #accessing }
PjDependencyAnalyzerTest >> methodsToConvert [

	^ analyzer methodsToConvertDict
		  inject: Set new
		  into: [ :allMethods :classMethods | allMethods , classMethods ]
]

{ #category : #accessing }
PjDependencyAnalyzerTest >> methodsToConvertFor: aClass [

	^ analyzer methodsToConvertDict at: aClass
]

{ #category : #running }
PjDependencyAnalyzerTest >> newClassHiearchy [

	| superclass classes |
	superclass := Object.
	classes := OrderedCollection new.
	3 timesRepeat: [
		classes add: (factory newSubclassOf: superclass).
		superclass := classes last ].
	^classes
]

{ #category : #running }
PjDependencyAnalyzerTest >> setUp [

	| superclass |
	super setUp.
	factory := ClassFactoryForTestCase new.
	superclass := Object.

]

{ #category : #running }
PjDependencyAnalyzerTest >> tearDown [

	factory cleanUp.
	super tearDown 
]

{ #category : #running }
PjDependencyAnalyzerTest >> testFindAllSuperclasses [

	| expectedClasses classes |
	classes := self newClassHiearchy.
	self analyzeClass: classes last.
	expectedClasses := classes copyWith: PjObject.
	self
		assertCollection: analyzer classesToConvert
		hasSameElements: expectedClasses
]

{ #category : #running }
PjDependencyAnalyzerTest >> testFindBasicClassMethods [

	| expectedMethods newMethods classes |
classes := self newClassHiearchy.
	expectedMethods := Set with: ProtoObject >> #initialize.
	classes do: [ :cl |
		newMethods := #( start #initialize ) collect: [ :selector |
			              cl class
				              compile: selector;
				              compiledMethodAt: selector ].
		expectedMethods addAll: newMethods ].
	self analyzeClass: classes last.
	self deny:
		(self methodsToConvert includes: Object class >> #initialize).
	self
		assertCollection: self methodsToConvert
		hasSameElements: expectedMethods
]

{ #category : #running }
PjDependencyAnalyzerTest >> testFindBasicInstanceMethods [

	| expectedMethods newMethods classes |
	classes := self newClassHiearchy.
	expectedMethods := Set with: ProtoObject >> #initialize.
	classes do: [ :cl |
		newMethods := #( start #initialize ) collect: [ :selector |
			              cl
				              compile: selector;
				              compiledMethodAt: selector ].
		expectedMethods addAll: newMethods ].
	self analyzeClass: classes last.
	self
		assertCollection: self methodsToConvert
		hasSameElements: expectedMethods
]

{ #category : #running }
PjDependencyAnalyzerTest >> testFindMethodsFromSources [

	| sourceClass targetClass |
	sourceClass := factory newClass.
	sourceClass compile: #zork.
	targetClass := factory newClass.
	targetClass class compile: ('methodSources
		^\{{1}\}' format: { sourceClass name }).
	targetClass compile: 'initialize
		self zork'.
	self analyzeClass: targetClass.
	self assert: (self methodsToConvert includes: sourceClass >> #zork).
	self
		assertCollection: analyzer classesToConvert
		hasSameElements: {PjObject. targetClass }
]

{ #category : #running }
PjDependencyAnalyzerTest >> testFindOnlyMethodsWithUsedSelectors [

	| class expectedMethods |
	class := factory newClass.
	#( 'start
		self startCall' 'initialize
		self initCall' #startCall #initCall #foo #bar ) do: [ :methodSrc |
		class compile: methodSrc ].
	expectedMethods :=
		#( start initialize startCall initCall ) asSet collect: [ :selector |
			(class compiledMethodAt: selector) ].
	expectedMethods add: (ProtoObject >> #initialize).
	self analyzeClass: class.
	self
		assertCollection: self methodsToConvert
		hasSameElements: expectedMethods
]

{ #category : #running }
PjDependencyAnalyzerTest >> testFindReferencedClasses [

	| expectedClasses classes entryPointClass expectedMethods |
	classes := self newClassHiearchy.
	classes first compile: #foo.
	classes second compile: #bar.
	classes last compile: 'initialize
		self foo.
		self bar.'.
	entryPointClass := factory newClass.
	#( foo bar ) do: [ :each | entryPointClass compile: each ].
	entryPointClass compile: ('initialize
	{1} new' format: { classes last name }).
	self analyzeClass: entryPointClass.
	expectedClasses := classes , {
		                   PjObject.
		                   entryPointClass }.
	self
		assertCollection: analyzer classesToConvert
		hasSameElements: expectedClasses.
	expectedMethods := Set with: ProtoObject >> #initialize.
	classes, { entryPointClass  } do: [ : cl | expectedMethods addAll: cl methods ].
	self assertCollection: self methodsToConvert hasSameElements: expectedMethods .
	
]

{ #category : #running }
PjDependencyAnalyzerTest >> testMethodSourcesAreNotInherited [
	"Avoid inheriting duplicating methods imported by a superclass"

	| classes sourceClass targetClass |
	sourceClass := factory newClass.
	sourceClass compile: #zork.
	classes := self newClassHiearchy.
	targetClass := classes first.
	targetClass compile: 'start
		self zork'.
	targetClass class compile: ('methodSources
		^\{{1}\}' format: { sourceClass name }).
	self analyzeClass: classes last.
	self
		assertCollection: (self methodsToConvertFor: targetClass)
		hasSameElements: {
				(targetClass >> #start).
				(sourceClass >> #zork) }.
	classes allButFirst do: [ :each |
		self assert: (self methodsToConvertFor: each) isEmpty ]
]

{ #category : #running }
PjDependencyAnalyzerTest >> testSkipMethodsWithSkipPragma [

	| class |
	class := factory newClass.
	#( 'start
		<pharoJsSkip>
		self startCall' 'initialize
		self initCall' #startCall #initCall ) do: [ :methodSrc |
		class compile: methodSrc ].
	self analyzeClass: class.
	self
		assertCollection: (self methodsToConvertFor: class)
		hasSameElements: {
				(class >> #initialize).
				(class >> #initCall) }
]
