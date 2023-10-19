Class {
	#name : #PjDependencyAnalyzerTest,
	#superclass : #TestCase,
	#instVars : [
		'analyzer',
		'factory'
	],
	#category : #'PharoJs-Base-Exporter-Tests-Tests'
}

{ #category : #accessing }
PjDependencyAnalyzerTest >> methodsToConvert [

	^ analyzer methodsToConvertDict
		  inject: Set new
		  into: [ :allMethods :classMethods | allMethods , classMethods ]
]

{ #category : #accessing }
PjDependencyAnalyzerTest >> methodsToConvertFor: aClass [

	^ analyzer methodsToConvertFor: aClass
]

{ #category : #test }
PjDependencyAnalyzerTest >> newClassHiearchy [

	| superclass classes |
	superclass := Object.
	classes := OrderedCollection new.
	3 timesRepeat: [
		classes add: (factory newSubclassOf: superclass).
		superclass := classes last ].
	^classes
]

{ #category : #test }
PjDependencyAnalyzerTest >> setUp [

	super setUp.
	factory := ClassFactoryForTestCase new.
	analyzer := PjDependencyAnalyzer new

]

{ #category : #test }
PjDependencyAnalyzerTest >> tearDown [

	factory cleanUp.
	super tearDown 
]

{ #category : #test }
PjDependencyAnalyzerTest >> testFindAllSuperclasses [

	| expectedClasses classes |
	classes := self newClassHiearchy.
	analyzer analyzeClass: classes last.
	expectedClasses := classes copyWith: PjObject.
	self
		assertCollection: analyzer classesToConvert
		hasSameElements: expectedClasses
]

{ #category : #test }
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
	analyzer analyzeClass: classes last.
	self deny:
		(self methodsToConvert includes: Object class >> #initialize).
	self
		assertCollection: self methodsToConvert
		hasSameElements: expectedMethods
]

{ #category : #test }
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
	analyzer analyzeClass: classes last.
	self
		assertCollection: self methodsToConvert
		hasSameElements: expectedMethods
]

{ #category : #test }
PjDependencyAnalyzerTest >> testFindMethodsFromSources [

	| sourceClass targetClass |
	sourceClass := factory newClass.
	sourceClass compile: #zork.
	targetClass := factory newClass.
	targetClass class compile: ('methodSources
		<{1}>
		^\{{2}\}' format: {				 CompiledMethod methodSourcesPragmaKey.
 sourceClass name }).
	targetClass compile: 'initialize
		self zork'.
	analyzer analyzeClass: targetClass.
	self assert: (self methodsToConvert includes: sourceClass >> #zork).
	self assertCollection: analyzer classesToConvert hasSameElements: {
			PjObject.
			targetClass }
]

{ #category : #test }
PjDependencyAnalyzerTest >> testFindMethodsMatchingReferencedSymbols [

	| class expectedMethods |
	class := factory newClass.
	#( 'start
		#mA. {#mB}' #mA #mB #foo #bar ) do: [ :methodSrc |
		class compile: methodSrc ].
	expectedMethods := #( start mA mB ) asSet collect: [ :selector |
		                   class compiledMethodAt: selector ].
	expectedMethods add: ProtoObject >> #initialize.
	analyzer analyzeClass: class.
	self
		assertCollection: self methodsToConvert
		hasSameElements: expectedMethods
]

{ #category : #test }
PjDependencyAnalyzerTest >> testFindMethodsMatchingReferencedSymbolsIn2UnrelatedClasses [

	| classA classB expectedMethods |
	classA := factory newClass.
	#( 'start
		self mA. self mB' #mA ) do: [ :methodSrc | classA compile: methodSrc ].
	classB := factory newClass.
	#( mA mB) do: [ :methodSrc | classB compile: methodSrc ].
	expectedMethods := #( start mA ) asSet collect: [ :selector |
		                   classA >> selector ].
	expectedMethods addAll: {
			(ProtoObject >> #initialize).
			classA >> #start.
			classA >> #mA.
			(classB >> #mA).
			classB >> #mB }.
	analyzer analyzeAllClasses: {
			classA.
			classB }.
	self
		assertCollection: self methodsToConvert
		hasSameElements: expectedMethods
]

{ #category : #test }
PjDependencyAnalyzerTest >> testFindMethodsSkippingSymbolsInLiteralArrays [

	| class expectedMethods |
	class := factory newClass.
	#( 'initialize
		 #(foo bar)' #foo #bar ) do: [ :methodSrc |
		class compile: methodSrc ].
	expectedMethods := {
		                   (class >> #initialize).
		                   (ProtoObject >> #initialize) }.
	analyzer analyzeClass: class.
	self
		assertCollection: self methodsToConvert
		hasSameElements: expectedMethods
]

{ #category : #test }
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
	analyzer analyzeClass: class.
	self
		assertCollection: self methodsToConvert
		hasSameElements: expectedMethods
]

{ #category : #test }
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
	analyzer analyzeClass: entryPointClass.
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

{ #category : #test }
PjDependencyAnalyzerTest >> testFindReferencedMoreClasses [

	| expectedClasses classes  |
	classes := { PjAlternateClassForTranspilationTest. PjCore.
			Object. PjClassEForPackageTranspilationTest }.
	analyzer analyzeAllClasses: classes.
	expectedClasses := (classes copyWithout: Object), {SharedPool.
		                   PjObject. PjSharedPoolForTest.  PjSuperClassForTranspilationTest. PjClassEForPackageTranspilationTest. PjClassDForPackageTranspilationTest. PjClassBForPackageTranspilationTest. PjClassAForPackageTranspilationTest}.
	self
		assertCollection: analyzer classesToConvert
		hasSameElements: expectedClasses.
	
]

{ #category : #test }
PjDependencyAnalyzerTest >> testImplementedMethodsAreHigerPriorityThanOnesFromSources [

	| sourceClass targetClass |
	sourceClass := factory newClass.
	sourceClass compile: #zork.
	targetClass := factory newClass.
	targetClass class compile: ('methodSources
		^\{{1}\}' format: { sourceClass name }).
	targetClass compile: 'initialize
		self zork'.
	targetClass compile: #zork.
	analyzer analyzeClass: targetClass.
	self assertCollection: self methodsToConvert hasSameElements:{ProtoObject >> #initialize. targetClass >> #zork. targetClass >> #initialize }.
	self assertCollection: analyzer classesToConvert hasSameElements: {
			PjObject.
			targetClass }
]

{ #category : #test }
PjDependencyAnalyzerTest >> testMethodSourceFromClassToSelectorsAssociation [

	| fooBarSource defaultSource targetClass expectedMethods |
	fooBarSource := factory newClass.
	defaultSource := factory newClass.
	#( foo bar ) do: [ :selector |
		{
			fooBarSource.
			defaultSource } do: [ :cl | cl compile: selector ] ].
	defaultSource compile: #zork.
	targetClass := factory newClass.
	targetClass class compile: ('methodSources
		<{1}>
		^\{{2} -> #(foo bar). {3}\}' format: {
				 CompiledMethod methodSourcesPragmaKey.
				 fooBarSource name.
				 defaultSource name }).
	targetClass compile: 'initialize
		#zork. #foo. #bar'.
	analyzer analyzeClass: targetClass.
	self assertCollection: analyzer classesToConvert hasSameElements: {
			PjObject.
			targetClass }.
	expectedMethods := {
		                   (ProtoObject >> #initialize).
		                   (targetClass >> #initialize).
		                   (fooBarSource >> #foo).
		                   (fooBarSource >> #bar).
		                   (defaultSource >> #zork) }.
	self
		assertCollection: (analyzer methodsToConvertFor: targetClass)
		hasSameElements: expectedMethods
]

{ #category : #test }
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
		<{1}>
		^\{{2}\}' format: {
				 CompiledMethod methodSourcesPragmaKey.
				 sourceClass name }).
	analyzer analyzeClass: classes last.
	self
		assertCollection: (self methodsToConvertFor: targetClass)
		hasSameElements: {
				(targetClass >> #start).
				(sourceClass >> #zork) }.
	classes allButFirst do: [ :each |
		self assert: (self methodsToConvertFor: each) isEmpty ]
]

{ #category : #test }
PjDependencyAnalyzerTest >> testSharedPoolsDirectlyReferenced [

	| expectedClasses |
	analyzer analyzeClass: PjSuperClassForTranspilationTest.
	expectedClasses := {SharedPool.
		                   PjObject.
		                   PjSuperClassForTranspilationTest.
		                   PjSharedPoolForTest }.
	self
		assertCollection: analyzer classesToConvert
		hasSameElements: expectedClasses
]

{ #category : #test }
PjDependencyAnalyzerTest >> testSharedPoolsForJsGlobalsIgnored [
	| expectedClasses class |
	class := factory newClass.
	class sharedPools: { PjDomGlobals }.
	analyzer analyzeClass: class.
	expectedClasses := {
		                   PjObject.
		                   class }.
	self
		assertCollection: analyzer classesToConvert
		hasSameElements: expectedClasses
]

{ #category : #test }
PjDependencyAnalyzerTest >> testSharedPoolsIndirectlyReferenced [

	| expectedClasses class |
	class := factory newClass.
	class compile: 'initialize
	' , PjSuperClassForTranspilationTest name.
	analyzer analyzeClass: class.
	expectedClasses := {SharedPool.
		                   PjObject.
		                   PjSuperClassForTranspilationTest.
		                   PjSharedPoolForTest.
		                   class }.
	self
		assertCollection: analyzer classesToConvert
		hasSameElements: expectedClasses
]

{ #category : #test }
PjDependencyAnalyzerTest >> testSkipMethodsWithSkipPragma [

	| class |
	class := factory newClass.
	#( 'start
		<pharoJsSkip>
		self startCall' 'initialize
		self initCall' #startCall #initCall ) do: [ :methodSrc |
		class compile: methodSrc ].
	analyzer analyzeClass: class.
	self
		assertCollection: (self methodsToConvertFor: class)
		hasSameElements: {
				(class >> #initialize).
				(class >> #initCall) }
]
