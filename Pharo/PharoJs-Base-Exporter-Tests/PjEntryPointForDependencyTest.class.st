Class {
	#name : #PjEntryPointForDependencyTest,
	#superclass : #Object,
	#category : #'PharoJs-Base-Exporter-Tests-AutoImport'
}

{ #category : #'start/stop' }
PjEntryPointForDependencyTest class >> anotherSkip [

	<pharoJsSkip>
	self unWantedForPharoJS1
]

{ #category : #'start/stop' }
PjEntryPointForDependencyTest class >> hiddenCalledBySuperForPharoJS [
	^self
]

{ #category : #'start/stop' }
PjEntryPointForDependencyTest class >> hiddenForPharoJS [
	^self
]

{ #category : #'start/stop' }
PjEntryPointForDependencyTest class >> start [
	self zorkForPharoJS.
	self hiddenForPharoJS.
	self superSendForPharoJS.
]

{ #category : #'start/stop' }
PjEntryPointForDependencyTest class >> superSendForPharoJS [
	super superSendForPharoJS
]

{ #category : #'start/stop' }
PjEntryPointForDependencyTest class >> unWantedForPharoJS1 [
	^self unWantedForPharoJS2
]

{ #category : #'start/stop' }
PjEntryPointForDependencyTest class >> unWantedForPharoJSNotReferenced1 [

	^ self
]
