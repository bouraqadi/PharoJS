Extension { #name : #PjExporterOLD }

{ #category : #'*PharoJs-Base-Bridge' }
PjExporterOLD >> convertToJs: anObject [

	self transpiler enableWriteDnuDuring: [ 
		^ self transpiler convertToJs: anObject ]
]

{ #category : #'*PharoJs-Base-Bridge' }
PjExporterOLD >> invalidateClass: aClass [

	self transpiler invalidateClass: aClass
]

{ #category : #'*PharoJs-Base-Bridge' }
PjExporterOLD >> setExtraBindings: aDictionary [

	^ self transpiler setExtraBindings: aDictionary
]
