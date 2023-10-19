Class {
	#name : #PjAlternateClassForTranspilationTest,
	#superclass : #PjSuperClassForTranspilationTest,
	#classVars : [
		'A',
		'X',
		'Y',
		'prototype'
	],
	#pools : [
		'PjDomGlobals'
	],
	#category : #'PharoJs-Base-Exporter-Tests-Support'
}

{ #category : #'initialization-release' }
PjAlternateClassForTranspilationTest class >> initialize [
]

{ #category : #any }
PjAlternateClassForTranspilationTest >> initialize [ 
	self m
]

{ #category : #any }
PjAlternateClassForTranspilationTest >> m [
	^ PjClassEForPackageTranspilationTest new
]
