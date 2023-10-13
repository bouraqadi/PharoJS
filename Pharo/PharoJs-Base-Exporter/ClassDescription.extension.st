Extension { #name : #ClassDescription }

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> hasMethodSources [

	<pharoJsSkip>
	self classSide compiledMethodAt: #methodSources ifAbsent: [ ^false ].
	^true
]

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> methodSources [

	<pharoJsSkip>
	^ #(  )
]

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> withMethodSourcesDo: aBlock [

	<pharoJsSkip>
	self hasMethodSources ifFalse: [ ^ aBlock value: self].
	^ { self } , self methodSources do: aBlock
]
