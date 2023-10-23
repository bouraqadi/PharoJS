Class {
	#name : #PjExporterOLD,
	#superclass : #Object,
	#instVars : [
		'classes',
		'appClass',
		'fileName',
		'transpiler',
		'jsStream',
		'launchBlock',
		'launchArgs',
		'globalsPools'
	],
	#category : #'PharoJs-Base-Exporter-Kernel'
}

{ #category : #accessing }
PjExporterOLD class >> bootstrapClasses [
	^ {Object. Boolean. Number. String. UndefinedObject. BlockClosure. Error. Array. Class}
]

{ #category : #accessing }
PjExporterOLD class >> coreClass [
	^ self transpilerClass coreClass
]

{ #category : #'instance creation' }
PjExporterOLD class >> newWithAppClass: aClass [
	^self new
		initializeWithAppClass: aClass;
		yourself
]

{ #category : #accessing }
PjExporterOLD class >> transpilerClass [
	^ PjDependencyTranspiler 
]

{ #category : #'writing low-level' }
PjExporterOLD >> << aString [

	jsStream << aString
]

{ #category : #adding }
PjExporterOLD >> addAllClasses: someClasses [

	someClasses do: [ :each | self addClass: each ]
]

{ #category : #adding }
PjExporterOLD >> addAllPackages: packageNames [

	packageNames do: [ :each | self addPackage: each ]
]

{ #category : #adding }
PjExporterOLD >> addClass: aClass [

	(self isExportable: aClass) ifFalse: [ ^ self ].
	self classes add: aClass
]

{ #category : #adding }
PjExporterOLD >> addPackage: packageName [

	"gather all classes from the package with name packageName. This includes definedClasses
	and extendedClasses. As there could be a Metaclass in the list we collect only the 
	instanceSide of Metaclass"

	self addAllClasses:
		((self classesInPackageNamed: packageName) collect:
			 #instanceSide) asSet
]

{ #category : #accessing }
PjExporterOLD >> appClass [

	^ appClass
]

{ #category : #accessing }
PjExporterOLD >> bootstrapClasses [

	^ self class bootstrapClasses
]

{ #category : #accessing }
PjExporterOLD >> classes [

	^ classes
]

{ #category : #adding }
PjExporterOLD >> classesInPackageNamed: packageName [

	| package tagName tag |
	package := RPackage organizer packageMatchingExtensionName:
		           packageName.
	packageName == packageName ifTrue: [ ^ package classes ].
tagName := packageName allButFirst:  package name size + 1.
tag := package classTagNamed: tagName.
^tag classes.
]

{ #category : #loading }
PjExporterOLD >> convertAllClassesToJs: someClasses [

	someClasses do: [ :aClass | self invalidateClass: aClass ].
	self addAllClasses: someClasses.
	^ self transpiler onTempStreamDo: [ 
		  self transpiler
			  convertAllClasses: self nonBootstrapClasses
			  writeDnu: true ]
]

{ #category : #writing }
PjExporterOLD >> copyMethodsSelector [

	^ #copyMethods
]

{ #category : #accessing }
PjExporterOLD >> coreClass [

	^ self class coreClass
]

{ #category : #'writing low-level' }
PjExporterOLD >> cr [

	jsStream lf
]

{ #category : #'writing low-level' }
PjExporterOLD >> crtab [

	jsStream cr; tab
]

{ #category : #writing }
PjExporterOLD >> dnuHook [

	^ [ 
	  self writeGlobalsPolyfills: nil.
	  true ]
]

{ #category : #'writing core' }
PjExporterOLD >> fixInheritanceLinkOfMethodDefinition [
	^'function(aClass) {
    if (!aClass.hasOwnProperty("subclasses")) {
        aClass.subclasses = [];
    }
    let currentSuperclass;
    if (aClass == Object) {
        currentSuperclass = undefined;
    } else {
        currentSuperclass = aClass.__proto__;
    }
    if (currentSuperclass == undefined) { return this; }
    if (!currentSuperclass.hasOwnProperty("subclasses")) {
        return currentSuperclass.subclasses = [aClass];
    }
    if (currentSuperclass.subclasses.includes(aClass)) { return; }
    currentSuperclass.subclasses.push(aClass);
}'
]

{ #category : #'writing core' }
PjExporterOLD >> fixInheritanceLinkOfSelector [

	^ #fixInheritanceLinkOf
]

{ #category : #'writing core' }
PjExporterOLD >> fixMetaclassOfMethodDefinition [
	^'function(aClass)
{
  if (aClass === this) { return this; }
  if (aClass === Object) {
    return Object.setPrototypeOf(aClass, PjClass.prototype);
  }
  if (Object.getPrototypeOf(aClass) === Function.prototype){ 
    return Object.setPrototypeOf(aClass, Object);
  }
}'
]

{ #category : #'writing core' }
PjExporterOLD >> fixMetaclassOfSelector [

	^ #fixMetaclassOf
]

{ #category : #accessing }
PjExporterOLD >> headerLine [

	^ self appClass headerLine
]

{ #category : #'initialize-release' }
PjExporterOLD >> initialize [

	super initialize.
	classes := Set new.
	globalsPools := Set new.
	self transpiler: self transpilerClass new.
	self transpiler addAllOptionalConversions "Except: 0 to: 1/2".
	self setUpForPolyfill
]

{ #category : #accessing }
PjExporterOLD >> initializeWithAppClass: aClass [

	appClass := aClass.
	transpiler pharoJsSelectorPrefix: aClass pharoJsSelectorPrefix.
	self addAllClasses: appClass appClasses.
	self addAllPackages: appClass appPackages
]

{ #category : #writing }
PjExporterOLD >> installAllAliasesSelector [
	^PjTranspiler installAllAliasesSelector
]

{ #category : #'writing core' }
PjExporterOLD >> installClassSelector [
	^self transpiler installClassSelector
]

{ #category : #writing }
PjExporterOLD >> installJsClassPlaceholderSelector [
	^self transpiler installJsClassPlaceholderSelector
]

{ #category : #testing }
PjExporterOLD >> isExportable: aClass [

	aClass ifNil: [ ^ false ].
	aClass isTrait ifTrue: [ ^false ].
	aClass isTestCase ifTrue: [ ^false ].
	(aClass includesBehavior: TestResource) ifTrue: [ ^false ].
	^ true
]

{ #category : #'test support' }
PjExporterOLD >> javascriptCode [

	^ String streamContents: [: aStream | self writeJsCodeOn: aStream]
]

{ #category : #'writing low-level' }
PjExporterOLD >> jsStream: aStream do: aBlock [

	| savedStream |
	savedStream := jsStream.
	jsStream := aStream.
	[
		aBlock value
	] ensure: [ jsStream := savedStream ]
]

{ #category : #accessing }
PjExporterOLD >> launchBlock [

	^ launchBlock ifNil: [ self appClass appLaunchBlock ]
]

{ #category : #accessing }
PjExporterOLD >> launchBlock: aBlock [

	launchBlock := aBlock
]

{ #category : #'writing low-level' }
PjExporterOLD >> nextPut: aCharacter [

	jsStream nextPut: aCharacter
]

{ #category : #'writing low-level' }
PjExporterOLD >> nextPutAll: aString [

	jsStream nextPutAll: aString
]

{ #category : #writing }
PjExporterOLD >> nonBootstrapClasses [

	| actualBootstrapClasses |
	actualBootstrapClasses := self bootstrapClasses asSet collect: #classToUseForJsConversion.
	^self classes reject: [ :setClass | 
			actualBootstrapClasses includes: setClass classToUseForJsConversion]
]

{ #category : #writing }
PjExporterOLD >> pharoJsSelectorPrefix [

	^ self transpiler pharoJsSelectorPrefix
]

{ #category : #'initialize-release' }
PjExporterOLD >> setUpForPolyfill [

	self transpiler beforeCodeOutputHook: [: pools | self writeGlobalsPolyfills: pools]
]

{ #category : #accessing }
PjExporterOLD >> setupCode [

	^ self appClass setupCode
]

{ #category : #writing }
PjExporterOLD >> space [
	jsStream space
]

{ #category : #accessing }
PjExporterOLD >> transpiler [

	^ transpiler
]

{ #category : #accessing }
PjExporterOLD >> transpiler: aTranspiler [

	transpiler := aTranspiler.
	transpiler onStream: self
]

{ #category : #accessing }
PjExporterOLD >> transpilerClass [

	^ self class transpilerClass
]

{ #category : #'writing core' }
PjExporterOLD >> writeCore [

	self writeCoreObject.
	self writeCoreClass.
	self transpiler
		writeNameForClass: PjCore;
		<< '.theClassClass=';
		writeNameForClass: PjClass;
		<< $;;
		cr;
		writeNameForClass: PjCore;
		<< $.;
		<< transpiler pharoJsSelectorPrefix;
		<< 'initializeCore();';
		cr
]

{ #category : #'writing core' }
PjExporterOLD >> writeCoreClass [

	self transpiler
		convertMethodAsts: PjClass newClasses: Set new;
		writeClassDefinitionOf: PjClass
]

{ #category : #'writing core' }
PjExporterOLD >> writeCoreObject [

	self writeCoreObjectCreation.
	self writeCoreObjectBasicMethods.
	self transpiler
		convertMethodAsts: PjCore newClasses: Set new;
		writeClassDefinitionOf: PjCore
]

{ #category : #'writing core' }
PjExporterOLD >> writeCoreObjectBasicMethods [

	self
		writeCoreObjectCopyMethods;
		writeFixMetaclassOfMethod;
		writeFixInheritanceLinkOfMethod;
		writeCoreObjectInstallClassMethod;
		writeCoreObjectInstallClassExtensionMethod;
		writeCoreObjectInstallAliasesMethods
]

{ #category : #'writing core' }
PjExporterOLD >> writeCoreObjectCopyMethods [

	self transpiler
		cr;
		writeNameForClass: PjCore;
		<< $.;
		<< self copyMethodsSelector;
		<< '=function(source,target){
    let propertyNames = Object.getOwnPropertyNames(source).filter((each)=>
			/\b';
		<< self pharoJsSelectorPrefix;
		<< '/.test(each)
	  ); 
    propertyNames.forEach('.
	self writePropertyDefinitionFunctionFrom: 'source' to: 'target'.
	self transpiler
		<< ');
}';
		cr
]

{ #category : #'writing core' }
PjExporterOLD >> writeCoreObjectCreation [

	self transpiler
		<< 'globalThis.';
		writeNameForClass: PjCore;
		<< '=globalThis.';
		writeNameForClass: PjCore;
		<< '??class extends Object{};'
]

{ #category : #'writing core' }
PjExporterOLD >> writeCoreObjectInstallAliasesMethods [

	| coreClassName |
	coreClassName := PjCore instanceSide nameToUseForJsConversion.
	self transpiler
		<< coreClassName;
		<<
			'.installSelectorAliases=function(aliases, selector, target){
		aliases.forEach('.
	self
		writePropertyDefinitionFunctionFrom: 'target'
		at: 'selector'
		to: 'target'.
	self transpiler
		<< ');
	}';
		cr;
		<< coreClassName;
		<< '.installAliasesFromDict=function(aliasesDict, target){
		for(let key of Object.getOwnPropertyNames(aliasesDict)){';
		<< coreClassName;
		<< '.installSelectorAliases(aliasesDict[key], key, target);
	}}';
		cr;
		<< coreClassName;
		<< $.;
		<< self installAllAliasesSelector;
		<<
			'=function(instanceSideAliasesDict, classSideAliasesDict, targetClass){';
		cr;
		<< coreClassName;
		<<
			'.installAliasesFromDict(instanceSideAliasesDict, targetClass.prototype);';
		cr;
		<< coreClassName;
		<< '.installAliasesFromDict(classSideAliasesDict, targetClass);
	}';
		cr
]

{ #category : #'writing core' }
PjExporterOLD >> writeCoreObjectInstallClassExtensionMethod [

	self transpiler
		writeNameForClass: PjCore;
		<< $.;
		<< self installJsClassPlaceholderSelector;
		<<
			'=function(extensionClass,targetClass,instanceSideAliasesDict,classSideAliasesDict){';
		crtab;
		<< 'this.';
		<< self copyMethodsSelector;
		<< '(extensionClass.prototype, targetClass.prototype);';
		crtab;
		<< 'this.';
		<< self copyMethodsSelector;
		<< '(extensionClass, targetClass);';
		crtab;
		<< 'targetClass.';
		writeClassVarsPoolName;
		<< '=';
		<< 'targetClass.';
		writeClassVarsPoolName;
		<< '??{};';
		crtab;
		<< 'Object.assign(targetClass.';
		writeClassVarsPoolName;
		<< ', extensionClass.';
		writeClassVarsPoolName;
		<< ');';
		crtab;
		<< 'this.';
		<< self installAllAliasesSelector;
		<<
			'(instanceSideAliasesDict, classSideAliasesDict, targetClass);';
		crtab;
		<< 'this.';
		<< self fixMetaclassOfSelector;
		<< '(targetClass);';
		crtab;
		<< 'this.';
		<< self fixInheritanceLinkOfSelector;
		<< '(targetClass);';
		crtab;
		<< 'this[targetClass.name]=targetClass;';
		crtab;
		<< 'globalThis[targetClass.name]=targetClass;';
		cr;
		<< $};
		cr
]

{ #category : #'writing core' }
PjExporterOLD >> writeCoreObjectInstallClassMethod [

	self transpiler
		writeNameForClass: PjCore;
		<< $.;
		<< self installClassSelector;
		<<
			'=function(newClass,instanceSideAliasesDict,classSideAliasesDict){';
		crtab;
		<< 'this.';
		<< self installAllAliasesSelector;
		<<
			'(instanceSideAliasesDict, classSideAliasesDict, newClass, newClass);';
		crtab;
		<< 'this.';
		<< self fixMetaclassOfSelector;
		<< '(newClass);';
		crtab;
		<< 'this.';
		<< self fixInheritanceLinkOfSelector;
		<< '(newClass);';
		crtab;
		<< 'this[newClass.name]=newClass;';
		crtab;
		<< 'globalThis[newClass.name]=newClass;';
		cr;
		<< $};
		cr
]

{ #category : #'writing core' }
PjExporterOLD >> writeFixInheritanceLinkOfMethod [

	self transpiler
		writeNameForClass: PjCore;
		<< $.;
		<< self fixInheritanceLinkOfSelector;
		<< $=;
		<< self fixInheritanceLinkOfMethodDefinition;
		<< $; ;
		cr
]

{ #category : #'writing core' }
PjExporterOLD >> writeFixMetaclassOfMethod [

	self transpiler
		writeNameForClass: PjCore;
		<< $.;
		<< self fixMetaclassOfSelector;
		<< $=;
		<< self fixMetaclassOfMethodDefinition;
		<< $; ;
		cr
]

{ #category : #writing }
PjExporterOLD >> writeGlobalsPolyfills: pools [

	pools do: [ :pool | 
		self appClass
			polyfill: pool
			withTranspiler: self transpiler
			unlessIn: globalsPools ]
]

{ #category : #writing }
PjExporterOLD >> writeJsCode [

	self appClass beforeExportApp.
	self writeJsCoreAndBootstrap.
	self writeNonBootstrapClasses.
	self writeLaunchCode.
	self appClass afterExportApp
]

{ #category : #writing }
PjExporterOLD >> writeJsCodeOn: aStream [

	self jsStream: aStream do: [ self writeJsCode ]
]

{ #category : #writing }
PjExporterOLD >> writeJsCoreAndBootstrap [

	self nextPutAll: self setupCode; cr.
	self writeCore.
	self transpiler convertAllClasses: self bootstrapClasses writeDnu: false
]

{ #category : #writing }
PjExporterOLD >> writeLaunchCode [

	self transpiler convertAndWriteClosedBlock: self launchBlock
]

{ #category : #writing }
PjExporterOLD >> writeNonBootstrapClasses [

	self transpiler
		convertAllClasses: self nonBootstrapClasses
		writeDnu: true
]

{ #category : #'writing core' }
PjExporterOLD >> writePropertyDefinitionFunctionFrom: sourceString at: sourceSelector to: targetString [

	self
		writePropertyDefinitionFunctionFrom: sourceString
		at: sourceSelector 
		to: targetString
		at: 'name'
]

{ #category : #'writing core' }
PjExporterOLD >> writePropertyDefinitionFunctionFrom: sourceString at: sourceSelector to: targetString at: targetSelector [

	self transpiler
		<< '(';
		<< targetSelector;
		<< ')=>Object.defineProperty(';
		<< targetString;
		<< ',';
		<< targetSelector;
		<< ',{value:';
		<< sourceString;
		<< '[';
		<< sourceSelector;
		<< '],configurable:true})'
]

{ #category : #'writing core' }
PjExporterOLD >> writePropertyDefinitionFunctionFrom: sourceString to: targetString [

	self writePropertyDefinitionFunctionFrom: sourceString at: 'name' to: targetString at: 'name'
]
