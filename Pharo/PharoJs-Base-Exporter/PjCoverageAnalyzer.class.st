Class {
	#name : #PjCoverageAnalyzer,
	#superclass : #Object,
	#instVars : [
		'errorClasses',
		'successClasses',
		'failures',
		'duration',
		'processedClasses'
	],
	#classInstVars : [
		'latest'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #analyzing }
PjCoverageAnalyzer class >> analyzeAllImageClasses [

	<script>
	Transcript clear.
	latest := self new.
	^latest
		  analyzeAllImageClasses;
		  yourself
]

{ #category : #analyzing }
PjCoverageAnalyzer class >> latest [
	^latest 
]

{ #category : #analyzing }
PjCoverageAnalyzer >> analyzeAllClasses: classesToAnalyse [

	processedClasses := classesToAnalyse.
	Transcript
		cr;
		show: '>>>Transpilation coverage started'.
	duration := [
	            processedClasses withIndexDo: [ :each :index |
		            self analyzeClass: each index: index.
		            Processor yield ] ] timeToRun.
	self traceSummary
]

{ #category : #analyzing }
PjCoverageAnalyzer >> analyzeAllImageClasses [

	[self analyzeAllClasses: SystemNavigation default allClasses] fork
]

{ #category : #analyzing }
PjCoverageAnalyzer >> analyzeClass: aClass index: index [

	| result percent percentString |
	self currentClass: aClass.
	percent := index * 100.0/processedClasses size.
	percentString := percent printShowingDecimalPlaces: 2.
	Transcript
		cr;
		show: percentString;
		show: '%) ';
		show: aClass name;
		show: ' : '.
	result := [ self newTranspiler convertClass: aClass ]
		          on: Error
		          do: [
			          Transcript show: 'ERROR!!!'.
			          ^ errorClasses add: aClass ].
	result isSuccess ifTrue: [
		Transcript show: 'OK :-)'.
		^ successClasses add: aClass ].
	Transcript show: 'Failed'.
	failures add: result
]

{ #category : #analyzing }
PjCoverageAnalyzer >> classDeclarationFailures [

	^ failures select: #isClassDeclarationFailed
]

{ #category : #accessing }
PjCoverageAnalyzer >> errorClasses [

	^ errorClasses
]

{ #category : #analyzing }
PjCoverageAnalyzer >> failedMethodsCount [

	^ self methodTranspileFailures
		  inject: 0
		  into: [ :total :result | total + result failedMethods size ]
]

{ #category : #initialization }
PjCoverageAnalyzer >> initialize [

	super initialize.
	failures := IdentitySet new.
	successClasses := IdentitySet new.
	errorClasses := IdentitySet new
]

{ #category : #analyzing }
PjCoverageAnalyzer >> methodTranspileFailures [

	^failures select: #isMethodTranspilationFailed
]

{ #category : #analyzing }
PjCoverageAnalyzer >> newTranspiler [
	^self transpilerClass new
]

{ #category : #accessing }
PjCoverageAnalyzer >> successClasses [

	^ successClasses
]

{ #category : #analyzing }
PjCoverageAnalyzer >> totalMethodsCount [
	^processedClasses inject: 0 into: [ : total : cl | total + cl selectors size ]
]

{ #category : #analyzing }
PjCoverageAnalyzer >> traceSummary [

	Transcript
		cr;
		show: '>>>Transpilation coverage finished';
		cr;
		show: '- Duration: ';
		show: duration humanReadablePrintString;
		cr;
		show: '- Total Processed classes: ';
		show: processedClasses size;
		cr;
		show: '- Passing classes: ';
		show: self successClasses size;
		cr;
		show: '- Class with Declaration Failures: ';
		show: self classDeclarationFailures size;
		cr;
		show: '- Classes with Method Failures: ';
		show: self methodTranspileFailures size;
		cr;
		show: '- Others Errors: ';
		show: self errorClasses size;
		cr;
		show: '- Total Methods: ';
		show: self totalMethodsCount;
		cr;
		show: '- Failed Methods: ';
		show: self failedMethodsCount
]

{ #category : #analyzing }
PjCoverageAnalyzer >> transpilerClass [

	^ PjCoverageAnalysisTranspiler
]
