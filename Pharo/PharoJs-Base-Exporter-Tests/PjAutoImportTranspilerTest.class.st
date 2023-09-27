Class {
	#name : #PjAutoImportTranspilerTest,
	#superclass : #PjPackageTranspilationTest,
	#category : #'PharoJs-Base-Exporter-Tests-AutoImport'
}

{ #category : #accessing }
PjAutoImportTranspilerTest >> testOnlyRequiredClassesTranspiled [

	self convertClass: PjMinimalAppForTest.
	self
		assertCollection: transpiler convertedClasses
		hasSameElements: {
				PjMinimalAppForTest.
				PjObject }
]

{ #category : #accessing }
PjAutoImportTranspilerTest >> testOnlyRequiredMehdodsTranspiled [

	self convertClass: PjMinimalAppForTest.
	self fail: #todo
]

{ #category : #accessing }
PjAutoImportTranspilerTest >> transpilerClass [ 
	^PjAutoImportTranspiler 
]
