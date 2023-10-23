Extension { #name : #CompiledMethod }

{ #category : #'*PharoJs-Base-Exporter' }
CompiledMethod >> isMethodSourcesProvider [

	^ (self pragmaAt: self methodSourcesPragmaKey) notNil
]

{ #category : #'*PharoJs-Base-Exporter' }
CompiledMethod >> isPharoOnly [
	^ self hasPragmaNamed: self skipMethodPragmaKeyword
]

{ #category : #'*PharoJs-Base-Exporter' }
CompiledMethod class >> methodSourcesPragmaKey [
	^#pjMethodSources
]

{ #category : #'*PharoJs-Base-Exporter' }
CompiledMethod >> methodSourcesPragmaKey [

	^ self class methodSourcesPragmaKey
]

{ #category : #'*PharoJs-Base-Exporter' }
CompiledMethod >> skipMethodPragmaKeyword [
	"Methods with this pragma are skipped upon conversion to javascript."
	^#pharoJsSkip
]
