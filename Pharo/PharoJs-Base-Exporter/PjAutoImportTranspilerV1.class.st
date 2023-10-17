Class {
	#name : #PjAutoImportTranspilerV1,
	#superclass : #PjDependentTranspilerOLD,
	#instVars : [
		'selectorsToConvert',
		'isNewSelectorFound',
		'convertedSelectors'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #transpiling }
PjAutoImportTranspilerV1 >> convertAllClasses: classes [

	| newClasses |
	[ isNewSelectorFound ] whileTrue: [
		classesToConvert addAll: convertedClasses.
		selectorsToConvert addAll: convertedSelectors.
		[ classesToConvert isEmpty and: [ selectorsToConvert isEmpty ] ]
			whileFalse: [
				| theseClasses |
				theseClasses := classesToConvert.
				classesToConvert := Set new.
				theseClasses do: [ :aClass |
					self
						convertMethodAsts: aClass instanceSide
						newClasses: newClasses ] ] ].
	super convertAllClasses: newClasses
]

{ #category : #transpiling }
PjAutoImportTranspilerV1 >> convertMethodAsts: aClass newClasses: newClasses [
	"Stops infinite loop in #convertAllClasses: because of selectorsToConvert"
	self flag: #todo.
	super convertMethodAsts: aClass newClasses: newClasses.
	selectorsToConvert  := #()
]

{ #category : #accessing }
PjAutoImportTranspilerV1 >> convertedClasses [
	^convertedClasses 
]

{ #category : #accessing }
PjAutoImportTranspilerV1 >> convertedMethods [
	^convertedMethods
]

{ #category : #initialization }
PjAutoImportTranspilerV1 >> initialize [

	super initialize.
	selectorsToConvert := Set withAll: #(initialize start)
]

{ #category : #transpiling }
PjAutoImportTranspilerV1 >> withMethodsOf: aClass do: aBlock [

	| methodsToOutput |
	methodsToOutput := OrderedCollection new.
	super withMethodsOf: aClass do: [ :method |
		(selectorsToConvert includes: method selector) ifTrue: [
			methodsToOutput add: method ] ].
	methodsToOutput sort: [ :l :r | l selector < r selector ].
	methodsToOutput do: aBlock
]
