Class {
	#name : 'OLDTaAnalyzer',
	#superclass : 'Object',
	#category : 'PharoJs-Benchmark-Coverage-Analyzer',
	#package : 'PharoJs-Benchmark-Coverage',
	#tag : 'Analyzer'
}

{ #category : 'OLD' }
OLDTaAnalyzer >> allCompilerMethodsSendingPragmasDict [

	| candidatePragmaSelectors associations |
	candidatePragmaSelectors := self candidatePragmaSelectors.
	associations := self compilerMethodsSendingPragmaSelectors collect: [ :meth |
		                meth ->  (self
			                 allSelectorsIn: candidatePragmaSelectors
			                 sentBy: meth) ].
	^ associations asDictionary
]

{ #category : 'OLD' }
OLDTaAnalyzer >> allMethods [

	^ SystemNavigation default allMethods
]

{ #category : 'OLD' }
OLDTaAnalyzer >> allSelectorsIn: selectors sentBy: method [
	^method literals select: [ :aLiteral |
		self isLiteral: aLiteral senderOfAny: selectors ]
]

{ #category : 'OLD' }
OLDTaAnalyzer >> newAnalysis [

	^OLDTaAnalysis new
		allPragmaSelectors: self allPragmaSelectors;
		allMethods: self allMethods;
		yourself
]
