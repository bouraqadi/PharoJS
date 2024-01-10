Class {
	#name : #PjCoverageAnalysisTranspiler,
	#superclass : #PjTranspiler,
	#instVars : [
		'result'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #'transpiling classes' }
PjCoverageAnalysisTranspiler >> convertClass: aClass [

	result := PjClassTranspilationResult new transpiledClass: aClass.
	[ super convertClass: aClass ]
		on: Error
		do: [ result classDeclarationFailed ].
	result jsCode: self jsCode.
	^result
]

{ #category : #'transpiling methods' }
PjCoverageAnalysisTranspiler >> shouldSkipMethod: aMethod [

	| shouldSkip |
	self halt: 'TODO: Use analyzer to collect skipped methods'.
	shouldSkip := super shouldSkipMethod: aMethod.
	shouldSkip ifTrue: [ result addSkippedMethod: aMethod ].
	^ shouldSkip
]

{ #category : #'transpiling methods' }
PjCoverageAnalysisTranspiler >> transpileMethod: aMethod [


	[ super transpileMethod: aMethod ]
		on: Error
		do: [ ^ result addFailingMethod: aMethod ].
	result addSuccessMethod: aMethod
]

{ #category : #'transpiling classes' }
PjCoverageAnalysisTranspiler >> writeClassDefinitionOf: aClass [

	result := PjClassTranspilationResult new transpiledClass: aClass.
	[ super writeClassDefinitionOf: aClass ]
		on: Error
		do: [ result classDeclarationFailed ].
	result jsCode: self jsCode.
	^ result
]
