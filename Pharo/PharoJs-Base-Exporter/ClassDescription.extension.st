Extension { #name : #ClassDescription }

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> withMethodSourcesDo: aBlock [

	<pharoJsSkip>
	^ { self } , self methodSources do: aBlock
]
