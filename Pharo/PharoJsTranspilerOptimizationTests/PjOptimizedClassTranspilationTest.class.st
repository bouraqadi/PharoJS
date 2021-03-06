Class {
	#name : #PjOptimizedClassTranspilationTest,
	#superclass : #PjTranspilationClassCompilationTest,
	#category : #'PharoJsTranspilerOptimizationTests-Tests'
}

{ #category : #running }
PjOptimizedClassTranspilationTest >> setUp [
	super setUp.
	transpiler addAllOptionalConversions
]

{ #category : #testing }
PjOptimizedClassTranspilationTest >> testBlockTempNames [
	self generateJsCodeForClasses: { PjClassForTranspilationTest }.
	self assertInstanceMethod: #blockWithUnnamedParameter
		equals: '(){var $1;if(($1=this._m1())==undefined){return 42;}else{return $1}}'.
	self assertInstanceMethod: #blockWithUnnamedParameterNonTail
		equals: '(){var $1;return 3+(($1=this._m1())==undefined?42:$1)}'.
	self assertInstanceMethod: #blockWithNamedParameter
		equals: '(){var foo;if((foo=this._m1())==undefined){return undefined;}else{return $asNil$(foo)._m1()}}'.

]

{ #category : #testing }
PjOptimizedClassTranspilationTest >> testBlocksAndReturns [
	self jsCode: (self convertClass: PjClassForTranspilationTest).
	self assertInstanceMethod: #whileNotAtEnd
		equals: '(){this._m_(function(x){while(true==$asNil$(x)._m1()){}});while(true==this._m2()){}return 42}'.
	self assertInstanceMethod: #whileAtEnd
		equals: '(){this._m_(function(x){while(true==$asNil$(x)._m1()){}});while(true==this._m2()){}return this}'.

]

{ #category : #testing }
PjOptimizedClassTranspilationTest >> testSubIf [
	self jsCode: (self convertClass: PjClassForTranspilationTest).
	self assertClassMethod: #setupMessage
		equals: '(){return $asNil$((this===JsClass?"":"Sorry, "))._44_("Click anywhere")}'.
	self assertClassMethod: #click:
		equals: '(ev){var m,$1;var $_err_$={};try{m=($1=this._setupMessage())==undefined?',PjCore throwFunctionName,'($_err_$=this):$1;return m}catch(e){if(e===$_err_$)return e;throw e}}'.

]
