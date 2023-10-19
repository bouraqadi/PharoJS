Extension { #name : #CompiledMethod }

{ #category : #'*PharoJs-Base-Exporter' }
CompiledMethod >> isMethodSourcesProvider [

	^ (self pragmaAt: self methodSourcesPragmaKey) notNil
]

{ #category : #'*PharoJs-Base-Exporter' }
CompiledMethod >> methodSourcesPragmaKey [

	^ self class methodSourcesPragmaKey
]

{ #category : #'*PharoJs-Base-Exporter' }
CompiledMethod class >> methodSourcesPragmaKey [
	^#pjMethodSources
]
