Extension { #name : #Metaclass }

{ #category : #'*PharoJs-Base-Exporter' }
Metaclass >> allMethodSourcesProviders [

	<pharoJsSkip>
	^ self methods select: [ :each |
		             each isMethodSourcesProvider ].
]

{ #category : #'*PharoJs-Base-Exporter' }
Metaclass >> asClassMethodsSource [
	<pharoJsSkip>
	^ self
]

{ #category : #'*PharoJs-Base-Exporter' }
Metaclass >> asInstanceMethodsSource [

	<pharoJsSkip>
	^ self instanceSide
]

{ #category : #'*PharoJs-Base-Exporter' }
Metaclass >> methodSourceFrom: anObject [

	<pharoJsSkip>
	^ anObject asClassMethodsSource
]
