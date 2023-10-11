Class {
	#name : #PjAutoImportTranspilerTestV1,
	#superclass : #PjPackageTranspilationTest,
	#category : #'PharoJs-Base-Exporter-Tests-AutoImport'
}

{ #category : #accessing }
PjAutoImportTranspilerTestV1 >> testOnlyRequiredClassesTranspiled [

	self convertClass: PjMinimalAppForTest.
	self
		assertCollection: transpiler convertedClasses
		hasSameElements: {
				PjMinimalAppForTest.
				PjObject }
]

{ #category : #accessing }
PjAutoImportTranspilerTestV1 >> testOnlyRequiredMethodsTranspiled [

	| minimalAppMethods objectMethods |
	self convertClass: PjMinimalAppForTest.
	minimalAppMethods := PjMinimalAppForTest class selectors collect: [ : each |  PjMinimalAppForTest class >> each].
	objectMethods :=  #(hiddenCalledBySuperForPharoJS hiddenForPharoJS superSendForPharoJS) collect: [ : each | Object class >> each  ].
	self
		assertCollection: transpiler convertedMethods
		hasSameElements: minimalAppMethods, objectMethods
]

{ #category : #accessing }
PjAutoImportTranspilerTestV1 >> transpilerClass [ 
	^PjAutoImportTranspilerV1 
]
