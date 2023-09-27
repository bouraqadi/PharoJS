Class {
	#name : #PjMinimalAppForTest,
	#superclass : #Object,
	#category : #'PharoJs-Base-Exporter-Tests-AutoImport'
}

{ #category : #'start/stop' }
PjMinimalAppForTest class >> hiddenCalledBySuperForPharoJS [
	^self
]

{ #category : #'start/stop' }
PjMinimalAppForTest class >> hiddenForPharoJS [
	^self
]

{ #category : #'start/stop' }
PjMinimalAppForTest class >> start [
	self zorkForPharoJS.
	self hiddenForPharoJS.
	self superSendForPharoJS.
]

{ #category : #'start/stop' }
PjMinimalAppForTest class >> superSendForPharoJS [
	super superSendForPharoJS
]

{ #category : #'start/stop' }
PjMinimalAppForTest class >> unWantedForPharoJS1 [
	^self unWantedForPharoJS2
]
