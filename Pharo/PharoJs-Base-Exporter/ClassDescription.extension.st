Extension { #name : #ClassDescription }

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> allMethodSources [

	<pharoJsSkip>
	^ self allRawMethodSources collect: [ :each |
		  self methodSourceFrom: each ]
]

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> allMethodSourcesProviders [

	self subclassResponsibility
]

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> allRawMethodSources [

	<pharoJsSkip>
	^ self allMethodSourcesProviders
		  inject: #()
		  into: [ :sources :provider |
			  sources ,
				  (provider valueWithReceiver: self instanceSide arguments: #(  )) ]
]

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> hasMethodSources [

	<pharoJsSkip>
	^ self allMethodSourcesProviders notEmpty
]

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> methodSourceFrom: anObject [

	self subclassResponsibility
]

{ #category : #'*PharoJs-Base-Exporter' }
ClassDescription >> withMethodSourcesDo: aBlock [

	<pharoJsSkip>
	self hasMethodSources ifFalse: [ ^ aBlock value: self ].
	^ { self } , self allMethodSources do: aBlock
]
