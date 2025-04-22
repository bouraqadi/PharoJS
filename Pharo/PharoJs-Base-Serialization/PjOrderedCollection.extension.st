Extension { #name : 'PjOrderedCollection' }

{ #category : '*PharoJs-Base-Serialization' }
PjOrderedCollection class >> phxJsonClassName [
	^ 'OrderedCollection'
]

{ #category : '*PharoJs-Base-Serialization' }
PjOrderedCollection class >> with: anObject [

	^ self new
		  add: anObject;
		  yourself
]

{ #category : '*PharoJs-Base-Serialization' }
PjOrderedCollection class >> with: anObject with: anOtherObject [

	^ self new
		  add: anObject;
		  add: anOtherObject;
		  yourself
]
