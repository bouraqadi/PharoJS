Class {
	#name : #PjAutoImportTranspiler,
	#superclass : #PjDependentTranspiler,
	#instVars : [
		'selectorsToConvert'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #transpiling }
PjAutoImportTranspiler >> convertAllClasses: classes [

	| newClasses |
	self
		addClassesToConvert: (classes select: #javascriptIsExportableClass).
	newClasses := OrderedCollection new.
	[ classesToConvert isEmpty and: [ selectorsToConvert isEmpty ] ] 
		whileFalse: [ | theseClasses |
			theseClasses := classesToConvert.
			classesToConvert := Set new.
			theseClasses
				do:
					[ :aClass | self convertMethodAsts: aClass instanceSide newClasses: newClasses ] ].
	super convertAllClasses: newClasses
]

{ #category : #transpiling }
PjAutoImportTranspiler >> convertMethodAsts: aClass newClasses: newClasses [
	"Stops infinite loop in #convertAllClasses: because of selectorsToConvert"
	self flag: #todo.
	super convertMethodAsts: aClass newClasses: newClasses.
	selectorsToConvert  := #()
]

{ #category : #accessing }
PjAutoImportTranspiler >> convertedClasses [
	^convertedClasses 
]

{ #category : #initialization }
PjAutoImportTranspiler >> initialize [

	super initialize.
	selectorsToConvert := Set withAll: #(initialize start)
]

{ #category : #transpiling }
PjAutoImportTranspiler >> withMethodsOf: aClass do: aBlock [

	| methodsToOutput |
	methodsToOutput := OrderedCollection new.
	super withMethodsOf: aClass do: [ :method |
		(selectorsToConvert includes: method selector) ifTrue: [
			methodsToOutput add: method ] ].
	methodsToOutput sort: [ :l :r | l selector < r selector ].
	methodsToOutput do: aBlock
]
