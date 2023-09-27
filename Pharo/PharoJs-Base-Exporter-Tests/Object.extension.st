Extension { #name : #Object }

{ #category : #'*PharoJs-Base-Exporter-Tests' }
Object class >> hiddenCalledBySuperForPharoJS [
	^self 
]

{ #category : #'*PharoJs-Base-Exporter-Tests' }
Object class >> hiddenForPharoJS [
	^self
]

{ #category : #'*PharoJs-Base-Exporter-Tests' }
Object class >> superSendForPharoJS [
	^self hiddenCalledBySuperForPharoJS 
]

{ #category : #'*PharoJs-Base-Exporter-Tests' }
Object class >> unWantedForPharoJS2 [
	^self
]

{ #category : #'*PharoJs-Base-Exporter-Tests' }
Object class >> zorkForPharoJS [
	^self
]
