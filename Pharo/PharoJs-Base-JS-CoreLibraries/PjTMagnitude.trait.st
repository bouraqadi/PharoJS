"
I am the Magnitude trait.

Because Magnitude cannot be inserted between Number and Object in the Javascript world, I have all the pieces that are needed by both PjMagnitude and PjNumber.
"
Trait {
	#name : #PjTMagnitude,
	#category : #'PharoJs-Base-JS-CoreLibraries-Kernel'
}

{ #category : #'pharoJs support' }
PjTMagnitude classSide >> jsTranspilationImportMethodsMagnitude [

	<pjMethodSources>
	<pharoJsSkip>
	^ { (Magnitude) }
]

{ #category : #testing }
PjTMagnitude >> < aMagnitude [
	^self explicitRequirement
]

{ #category : #testing }
PjTMagnitude >> = aMagnitude [
	^self explicitRequirement
]
