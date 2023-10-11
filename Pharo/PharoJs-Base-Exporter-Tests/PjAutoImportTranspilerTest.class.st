Class {
	#name : #PjAutoImportTranspilerTest,
	#superclass : #PjPackageTranspilationTest,
	#category : #'PharoJs-Base-Exporter-Tests-AutoImport'
}

{ #category : #accessing }
PjAutoImportTranspilerTest >> methodsToConvert [

	^ transpiler methodsToConvertDict
		  inject: Set new
		  into: [  :allMethods :classMethods | allMethods , classMethods ]
]

{ #category : #accessing }
PjAutoImportTranspilerTest >> testOnlyRequiredClassesTranspiled [

	self convertClass: PjMinimalAppForTest.
	self
		assertCollection: transpiler classesToConvert
		hasSameElements: {
				PjMinimalAppForTest.
				PjObject }
]

{ #category : #accessing }
PjAutoImportTranspilerTest >> testOnlyRequiredMethodsTranspiled [

	| minimalAppClassMethods objectMethods objectClassMethods |
	self convertClass: PjMinimalAppForTest.
	minimalAppClassMethods := #( start hiddenForPharoJS superSendForPharoJS hiddenCalledBySuperForPharoJS) collect: [
		                          :each | PjMinimalAppForTest class >> each ].
	objectMethods := #( initialize ) collect: [ :each |
		                 ProtoObject >> #initialize ].
	objectClassMethods := #( zorkForPharoJS hiddenForPharoJS superSendForPharoJS hiddenCalledBySuperForPharoJS) collect: [
		                      :each | Object class >> each ].
	self
		assertCollection: self methodsToConvert
		hasSameElements:
		minimalAppClassMethods , objectClassMethods , objectMethods
]

{ #category : #accessing }
PjAutoImportTranspilerTest >> transpilerClass [

	^ PjAutoImportTranspiler
]
