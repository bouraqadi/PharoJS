Class {
	#name : 'TaAnalysis',
	#superclass : 'Object',
	#instVars : [
		'allPragmaSelectors',
		'allCompiledMethods',
		'thisContextMethods',
		'metricsStream',
		'allClassesAndTraits',
		'problematicPragmaSelectors'
	],
	#category : 'PharoJs-Benchmark-Coverage-Analyzer',
	#package : 'PharoJs-Benchmark-Coverage',
	#tag : 'Analyzer'
}

{ #category : 'accessing' }
TaAnalysis class >> allPoblematicPragmaSelectors [
	"Is there a way to at least partially automate extracting this collection?"

	^ #( #ffiCalloutTranslator #primitive: #primitive:error:
	     #primitive:error:module: #primitive:module: #primitive:module:error:
	     #var:declareC: #var:type: )
]

{ #category : 'accessing' }
TaAnalysis >> allClassesAndTraits [

	^ allClassesAndTraits
]

{ #category : 'accessing' }
TaAnalysis >> allMethods [

	^ allCompiledMethods
]

{ #category : 'accessing' }
TaAnalysis >> allMethods: allMethods [

	allCompiledMethods := allMethods asSortedCollection: [ :a :b |
		                      a selector < b selector ].
	thisContextMethods := allMethods select: [ :each |
		                      each readsThisContext ].
	allClassesAndTraits := (allCompiledMethods collect: #methodClass) asSet
]

{ #category : 'accessing' }
TaAnalysis >> allPragmaSelectors [

	^ allPragmaSelectors
]

{ #category : 'accessing' }
TaAnalysis >> allPragmaSelectors: somePragmas [

	allPragmaSelectors := somePragmas asSet asSortedCollection.
	problematicPragmaSelectors := self class allPoblematicPragmaSelectors
		                              select: [ :each |
		                              allPragmaSelectors includes: each ]
]

{ #category : 'accessing' }
TaAnalysis >> allPragmas [
	^Pragma all
]

{ #category : 'accessing' }
TaAnalysis >> imageDescription [
	^SystemVersion current version
]

{ #category : 'printing' }
TaAnalysis >> metricsString [

	^ metricsStream contents
]

{ #category : 'printing' }
TaAnalysis >> metricsWritingArray [

	| allMethodsCount thisContextMethodsCount allClassesAndTraitsCount problematicPragmasCount allPragmasCount problematicPragmaMethodsCount problameticMethodsCount problematicClassesAndTraitsCount |
	allMethodsCount := self allMethods size.
	allClassesAndTraitsCount := self allClassesAndTraits size.
	thisContextMethodsCount := self thisContextMethods size.
	allPragmasCount := self allPragmaSelectors size.
	problematicPragmasCount := self problematicPragmaSelectors size.
	problematicPragmaMethodsCount := self problematicPragmaMethods size.
	problameticMethodsCount := self problematicMethods size.
	problematicClassesAndTraitsCount := self problematicClassesAndTraits
		                                    size.
	^ {
		  {
			  '------ '.
			  self imageDescription.
			  ' Analyzed on '.
			  Date today.
			  Time now print24 }.
		  { '# Pragmas' }.
		  {
			  '- All Pragmas:'.
			  allPragmasCount }.
		  {
			  '- Problematic Pragmas: '.
			  problematicPragmasCount.
			  (self percentOf: problematicPragmasCount by: allPragmasCount) }.
		  { '# Methods' }.
		  {
			  '- All Methods:'.
			  allMethodsCount }.
		  {
			  '- Methods reading `thisContext`:'.
			  thisContextMethodsCount.
			  (self percentOf: thisContextMethodsCount by: allMethodsCount) }.
		  {
			  '- Total Methods with a Problematic Pragma:'.
			  problematicPragmaMethodsCount.
			  (self
				   percentOf: problematicPragmaMethodsCount
				   by: allMethodsCount) }.
		  {
			  '- Total Problematic Methods:'.
			  problameticMethodsCount.
			  (self percentOf: problameticMethodsCount by: allMethodsCount) }.
		  { '# Classes & Traits' }.
		  {
			  '- All Classes & Traits:'.
			  allClassesAndTraitsCount }.
		  {
			  '- Total Classes & Traits with a Probelmatic Method'.
			  problematicClassesAndTraitsCount.
			  (self
				   percentOf: problematicClassesAndTraitsCount
				   by: allClassesAndTraitsCount) } }
]

{ #category : 'printing' }
TaAnalysis >> percentOf: numerator by: denominator [

	| percent |
	percent := (numerator * 100 / denominator) asFloat.
	^ String streamContents: [ :str |
		  str << $(.
		  percent printOn: str showingDecimalPlaces: 3.
		  str << ' %)' ]
]

{ #category : 'printing' }
TaAnalysis >> printMetricsOnTranscript [

	self writeMetrics.
	Transcript crShow: self metricsString
]

{ #category : 'accessing' }
TaAnalysis >> problematicClassesAndTraits [
	"A class and its metaclass count for 1.
	Same for a Trait and its classTrait"

	^ self problematicMethods collect: [ : each | each methodClass instanceSide ]
]

{ #category : 'accessing' }
TaAnalysis >> problematicMethods [
	^(self problematicPragmaMethods, self thisContextMethods) asSet 

]

{ #category : 'accessing' }
TaAnalysis >> problematicPragmaMethods [

	^ self problematicPragmas collect: [: each | each method ]
]

{ #category : 'accessing' }
TaAnalysis >> problematicPragmaSelectors [
	^problematicPragmaSelectors
]

{ #category : 'accessing' }
TaAnalysis >> problematicPragmas [
	^self allPragmas select: [ : each | 
		self problematicPragmaSelectors includes: each selector ]
	
]

{ #category : 'accessing' }
TaAnalysis >> thisContextMethods [

	^ thisContextMethods
]

{ #category : 'printing' }
TaAnalysis >> writeArray: anArray [

	anArray do: [  :each | 
		metricsStream << each asString
	] separatedBy: [ metricsStream space ]

]

{ #category : 'printing' }
TaAnalysis >> writeMetrics [

	metricsStream := WriteStream on: String new.
	self metricsWritingArray 
		do: [ :anArray | self writeArray: anArray ]
		separatedBy: [ metricsStream cr ]
]
