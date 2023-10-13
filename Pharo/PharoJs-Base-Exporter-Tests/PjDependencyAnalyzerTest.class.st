Class {
	#name : #PjDependencyAnalyzerTest,
	#superclass : #TestCase,
	#instVars : [
		'analyzer'
	],
	#category : #'PharoJs-Base-Exporter-Tests-AutoImport'
}

{ #category : #accessing }
PjDependencyAnalyzerTest >> analyzeClass: aClass [
analyzer analyzeClass: aClass 
]

{ #category : #accessing }
PjDependencyAnalyzerTest >> methodsToConvert [

	^ analyzer methodsToConvertDict
		  inject: Set new
		  into: [ :allMethods :classMethods | allMethods , classMethods ]
]

{ #category : #running }
PjDependencyAnalyzerTest >> setUp [
	super setUp.
	analyzer := PjDependencyAnalyzer new
]

{ #category : #accessing }
PjDependencyAnalyzerTest >> testFindClassesToConvert [

	self analyzeClass: PjEntryPointForDependencyTest.
	self assertCollection: analyzer classesToConvert hasSameElements: {
			PjEntryPointForDependencyTest.
			PjObject }
]

{ #category : #accessing }
PjDependencyAnalyzerTest >> testFindMethodsToConvert [

	| minimalAppClassMethods objectMethods objectClassMethods |
	self analyzeClass: PjEntryPointForDependencyTest.
	minimalAppClassMethods := #( start hiddenForPharoJS superSendForPharoJS
	                             hiddenCalledBySuperForPharoJS )
		                          collect: [ :each |
		                          PjEntryPointForDependencyTest class >> each ].
	objectMethods := #( initialize ) collect: [ :each |
		                 ProtoObject >> #initialize ].
	objectClassMethods := #( zorkForPharoJS hiddenForPharoJS
	                         superSendForPharoJS hiddenCalledBySuperForPharoJS )
		                      collect: [ :each | Object class >> each ].
	self
		assertCollection: self methodsToConvert
		hasSameElements:
		minimalAppClassMethods , objectClassMethods , objectMethods
]
