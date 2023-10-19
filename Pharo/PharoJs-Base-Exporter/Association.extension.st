Extension { #name : #Association }

{ #category : #'*PharoJs-Base-Exporter' }
Association >> asClassMethodsSource [

	<pharoJsSkip>
	^ self asMethodsSource: key isClassSide
]

{ #category : #'*PharoJs-Base-Exporter' }
Association >> asInstanceMethodsSource [

	<pharoJsSkip>
	^self asMethodsSource: (key isInstanceSide )
]

{ #category : #'*PharoJs-Base-Exporter' }
Association >> asMethodsSource: aBoolean [

	<pharoJsSkip>
	| source |
	source := PjMethodSource new.
	aBoolean ifFalse: [ ^ source ].
	self value do: [ :selector |
		source at: selector put: key >> selector ].
	^ source
]
