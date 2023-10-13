Extension { #name : #Metaclass }

{ #category : #'*PharoJs-Base-Exporter' }
Metaclass >> methodSources [

	<pharoJsSkip>
	^ self instanceSide methodSources collect: #class
]
