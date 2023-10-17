Class {
	#name : #PjClassTranspilationResult,
	#superclass : #Object,
	#instVars : [
		'transpiledClass',
		'jsCode',
		'isClassDeclarationFailed',
		'failedMethods',
		'skippedMethods',
		'successMethods'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #accessing }
PjClassTranspilationResult >> addFailingMethod: aMethod [

	failedMethods add: aMethod
]

{ #category : #accessing }
PjClassTranspilationResult >> addSkippedMethod: aMethod [

	skippedMethods add: aMethod
]

{ #category : #accessing }
PjClassTranspilationResult >> addSuccessMethod: aMethod [

	successMethods add: aMethod
]

{ #category : #initialization }
PjClassTranspilationResult >> classDeclarationFailed [
	isClassDeclarationFailed := true
]

{ #category : #accessing }
PjClassTranspilationResult >> classSelectors [

	^ [transpiledClass selectors] on: Error do: [ #() ]
]

{ #category : #accessing }
PjClassTranspilationResult >> failedMethods [

	^ failedMethods 
]

{ #category : #accessing }
PjClassTranspilationResult >> failedSelectors [

	^ failedMethods collect: #selector
]

{ #category : #initialization }
PjClassTranspilationResult >> initialize [

	super initialize.
	failedMethods := IdentitySet new.
	skippedMethods := IdentitySet new.
	successMethods := IdentitySet new.
	isClassDeclarationFailed := false
]

{ #category : #testing }
PjClassTranspilationResult >> isClassDeclarationFailed [

	^ isClassDeclarationFailed
]

{ #category : #testing }
PjClassTranspilationResult >> isFailure [
	^self isClassDeclarationFailed or: [ self isMethodTranspilationFailed  ] 
]

{ #category : #testing }
PjClassTranspilationResult >> isMethodTranspilationFailed [
	^failedMethods notEmpty
]

{ #category : #testing }
PjClassTranspilationResult >> isSuccess [
	^self isFailure not
]

{ #category : #accessing }
PjClassTranspilationResult >> jsCode [

	^ jsCode
]

{ #category : #accessing }
PjClassTranspilationResult >> jsCode: anObject [

	jsCode := anObject
]

{ #category : #accessing }
PjClassTranspilationResult >> skippedMethods [

	^ skippedMethods
]

{ #category : #accessing }
PjClassTranspilationResult >> skippedSelectors [

	^ skippedMethods collect: #selector
]

{ #category : #accessing }
PjClassTranspilationResult >> successMethods [
	^ successMethods
]

{ #category : #accessing }
PjClassTranspilationResult >> successSelectors [

	^ successMethods collect: #selector
]

{ #category : #accessing }
PjClassTranspilationResult >> transpiledClass [

	^transpiledClass 
]

{ #category : #accessing }
PjClassTranspilationResult >> transpiledClass: aClass [ 
	transpiledClass := aClass
]
