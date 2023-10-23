"
I am the Collection trait.

Because Collection cannot be inserted between Array and Object in the Javascript world, I have all the pieces that are needed by both PjCollection and PjArray.
"
Trait {
	#name : #PjTCollection,
	#category : #'PharoJs-Base-JS-CoreLibraries-Kernel'
}

{ #category : #random }
PjTCollection classSide >> atRandom_jsGenerator: transpiler [
	<pharoJsSkip>
	^'var randomIndex = Math.floor((Math.random() * this.', transpiler pharoJsSelectorPrefix, 'size()) + 1);
	return this.', transpiler pharoJsSelectorPrefix, 'at_(randomIndex);'
]

{ #category : #'pharojs support' }
PjTCollection classSide >> jsTranspilationImportMethodsCollection [

	<pharoJsSkip>
	^ {Collection.(OrderedCollection) }
]

{ #category : #'pharojs support' }
PjTCollection classSide >> methodsToSkip [

	<pharoJsSkip>
	^ { (OrderedCollection class >> #new) }
]

{ #category : #testing }
PjTCollection >> = aMagnitude [
	^self explicitRequirement
]

{ #category : #random }
PjTCollection >> atRandom [
	<jsGenerator: #atRandom_jsGenerator:>
]
