REBOL [
	; -- Core Header attributes --
	title: "slim documentaion engine"
	file: %slate.r
	version: 0.1.0
	date: 2018-4-19
	author: "Maxim Olivier-Adlhoch"
	purpose: {Provides and automated and rich documentation aggregation engine.}
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'slate
	slim-version: 1.3.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/slide.r

	; -- Licensing details  --
	copyright: "Copyright © 2018 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2018 Maxim Olivier-Adlhoch

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.}

	;-  / history
	history: {
		v0.1.0 - 2018-04-19
			-Creation
	}
	;-  \ history

	;-  / documentation
	documentation: {
		Documentation goes here
	}
	;-  \ documentation
]





;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'slide
;
;--------------------------------------

slim/register [

;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- LIBS
;
;-----------------------------------------------------------------------------------------------------------
;slim/open/expose 'slut 			none [  ]
slim/open/expose 'utils-files	none [ absolute-path? is-dir? ]
slim/open/expose 'slate-templates none [ get-template setup-template]

slim/open/expose 'parse-context none [ annex analyse parse-status get-parse-ctx ]
slim/open/expose 'utils-files none [ prefix-of directory-of filename-of]

slim/open 'charset-rules none
slim/open 'rebol-rules none
slim/open 'debug-rules none ; comment when not required

;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- SLATE-GLOBALS: []
;
;-----------------------------------------------------------------------------------------------------------
slate-globals: context [
	;--------------------------
	;-     current-filepath:
	;
	; this should always contain the full path (dir + filename) of the file being analysed
	;--------------------------
	current-filepath: none

	;--------------------------
	;-     last-fid:
	;
	; stores the last-used function id as a serial number
	;--------------------------
	last-fid: 0
	
	;--------------------------
	;-     root-html-dir:
	;
	; you can specify a sub-directory to use for all the html files.
	;
	; This allows you to call the slate engine several times 
	; with different sub dirs within a larger framework
	; 
	; a possible extension to slate could be to write an overall root index page 
	; when working within a multi segment documentaion project (each slim libs package as a separate site, for example).
	;
	; you could then have one accumulated index for all subsites and another for each subsite, at its own root.
	;--------------------------
	root-html-dir: %""
	
	;--------------------------
	;-     site-root:
	;
	; where do we store all the pages on disk
	;--------------------------
	site-root: none 
	
	
	;--------------------------
	;-     root-js-dir:
	;
	; any javascript file is put or refered from a single directory for the whole site.
	;--------------------------
	root-js-dir: %/js/
	
	;--------------------------
	;-     root-css-dir:
	;
	; any css fill is put or refered from a single directory for the whole site.
	;--------------------------
	root-css-dir: %/css/
	
	
	;--------------------------
	;-     overall-site-func-index:
	;
	; stores information from all call to 'DOCUMENT
	;--------------------------
	overall-site-func-index: []
	
	;--------------------------
	;-     local-site-func-index:
	;
	; stores information for the current/last call to 'DOCUMENT
	;
	; note that the same function may appear several times, with different names!
	;--------------------------
	local-site-func-index: []
		
	
	;--------------------------
	;-     function-list-columns:
	;
	;--------------------------
	function-list-columns: 5
	
	
	
]


;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- CLASSES
;
;-----------------------------------------------------------------------------------------------------------

;--------------------------
;- !slate-function [ ... ]
;
;--------------------------
!slate-function: context [
	;--------------------------
	;-     fid:
	;
	; this is used to differenciate between several functions with the same name
	;--------------------------
	fid: 0
	
	;--------------------------
	;-     src-file:
	;
	; filepath of the source file from which this function is extracted. 
	;--------------------------
	src-file: none
	
	;--------------------------
	;-     filepath:
	;
	; output filename (once generated) re-used for any reference to this function.
	;
	; this path is already baked with the global root-html-dir, so don't change it.
	;--------------------------
	filepath: none
	
	;--------------------------
	;-     tags:
	;
	;--------------------------
	tags: none
	
	;--------------------------
	;-     names:
	;
	;--------------------------
	names: none
	
	;--------------------------
	;-     hdr-name:
	;
	;--------------------------
	hdr-name: none
	
	;--------------------------
	;-     hdr:
	;
	;--------------------------
	hdr: none
	
	;--------------------------
	;-     summary:
	;
	;--------------------------
	summary: none
	
	;--------------------------
	;-     also:
	;
	;--------------------------
	also: none
	
	;--------------------------
	;-     notes:
	;
	;--------------------------
	notes: none
	
	;--------------------------
	;-     args:
	;
	;--------------------------
	args: none
	
	;--------------------------
	;-     body:
	;
	;--------------------------
	body: none
	
	;--------------------------
	;-     func-source:
	;
	;--------------------------
	func-source: none
	
	;--------------------------
	;-     func-type:
	;
	; what datatype! is this function?
	;
	; it can currently be either function! or routine!
	;--------------------------
	func-type: none
	
]




;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- SLATE HEADER CORE RULES
;
;-----------------------------------------------------------------------------------------------------------
annex [

	;--------------------------
	;-     .functions:
	;
	; accumulated list of functions outside of contexts.
	;--------------------------
	.functions: []

	;--------------------------
	;-     .contexts:
	;
	; accumulated list of contexts, these will include functions and may include attributes, at some point.
	;--------------------------
	.contexts: []

	;--------------------------
	;-     .val:
	; used to temporarily store values while parsing
	;--------------------------
	.val: none

	;--------------------------
	;-     .current-hdr-detail:
	;
	; when accumulating header details
	;--------------------------
	.current-hdr-detail: none

	;--------------------------
	;-     .current-hdr-details:
	;
	; stores multiple details while parsing a header
	;--------------------------
	.current-hdr-details: clear []


	;--------------------------
	;-     =continue-hdr-property=:
	;
	; this is the rest of a property detail on the next line.
	;--------------------------
	=continue-hdr-property=: [
		=comment-start= 
		spacers=
		!not-dash!
		!not-eol!
		copy .val [
			1 3 =simple-token= ; these cannot include a colon.
			!not-colon! ; make sure the last word doesn't end with colon
			some =not-eol=
			(append .current-hdr-detail rejoin [.val "^/"])
		]
		=eol=
	]
	

	;--------------------------
	;-     =header-property-details=:
	;
	; a generic list of properties following a property.
	;
	; the boundaries are two-fold:  
	;		- a blank line between two items
	;       - a dash starting at the line.
	;
	; note that the 'TESTS property will eventually be treated explicitely.
	;--------------------------
	=header-property-details=: [
		(
			.current-hdr-detail: clear ""
			.current-hdr-details: clear []
		)
		
		; first detail CAN live on the same line as the property
		opt [
			=spacers?=
			; make sure we're not at a comment
			.here: =not-comment-marker= :.here
			any =not-eol=
			=eol=
			any =continue-hdr-property=
			
		]
		any [
		
		]
	]
	
	
	;--------------------------
	;-     =header-property=:
	;
	;--------------------------
	=header-property=: [
		=spacers?= #";" =spacers?= some [=simple-token= =spacers?=] #":"
		=spacers?=
		=header-property-details=
	]
]


;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- SLATE FUNCTION RULES
;
;-----------------------------------------------------------------------------------------------------------

annex [
	;--------------------------
	;-     =func-header=:
	;
	; will match details and some special patterns 
	; in the comments preceding a function.
	;--------------------------
	=func-header=: [
		()
		.hdr-start:
		;----------
		; extract optional function name in header
		=dash-comment-line=
		;(vprint "dash line!")
		any =empty-comment-line=
		opt [
			=spacers?= 
			";-"  
			=spacers= 
			copy .val  =word= 
			=spacers?= 
			"(" =spacers?= ")" 
			=spacers?= =eol=
			( .header-func-name: .val )
		]
		any =empty-comment-line=
		opt =dash-comment-line=
		
		;-------------------------
		; extract header properties.
		;-------------------------
		any [
			=empty-comment-line=
			| =comment=
			;#";"
		]
		opt =dash-comment-line=
		.hdr-end:
;		(
;		vprint "HEADER DONE"
;		v?? [copy/part .hdr-start .hdr-end]
;		vprint "------"
;		)
	]


	;--------------------------
	;-     =arg-spec=:
	;
	;--------------------------
	=arg-spec=: [
		set .arg-name word! 
		;(v?? .arg-name)
		; we may have type specifiers and doc strings
		opt [
			set .arg-doc string! opt [set .arg-types block!]
			|
			set .arg-types block! opt [set .arg-doc string!]
		]
		( .new-arg: context [
			name: .arg-name
			doc: .arg-doc
			types: .arg-types
			refinement-args: none
		])
		;(vprint "###########" v??  .new-arg)
	]

	


	;--------------------------
	;-     =func-args=:
	; 
	; <todo> better error detection, recovery and reporting (we want to document the problem, if any).
	;--------------------------
	=func-args=: [
		=block=
		(
			;vprint "^/"
			;vprint ">>>>>>>>>>>>>>>>>>"
			;v?? .rebol-block
			.func-summary: none
			.func-args: copy []
			parse .rebol-block [
				; skip the throw handler flags
				
				opt [ 
					into ['CATCH | 'THROW]
					;(vprint "EXCEPTION FLAGS")
				]
				
				
				opt [ set .func-summary string! ]
				any [
					; required argument
					=arg-spec=
					(append .func-args .new-arg)
				]
				;(vprint "DONE WITH ARGS, TRYING REFINEMENTS")
				;----
				; refinement can only follow required args
				any [
					set .arg-name refinement!
					set .arg-doc  opt string! ; "the refinement itself can have documentation"
					(
						.ref-arg: context [
							name: .arg-name ; will be a refinement!
							doc: .arg-doc
							types: none
							refinement-args: copy [] ; could be empty
						]
						append .func-args .ref-arg
						;v?? .ref-arg
					)
					any [
						=arg-spec=
						(append .ref-arg/refinement-args .new-arg)
					]
					;---
					; erase list if its empty
					;(if empty? .ref-arg/refinement-args [ .ref-arg/refinement-args: none ])
				]
			]
			;v?? .func-args
			;vprint "<<<<<<<<<<<<<<<<<^/^/"
		)
	]
	
	
	;--------------------------
	;-     =func-body=:
	; 
	;--------------------------
	=func-body=: [
		=block= (.func-body: copy .rebol-block )
		(
			;v?? .func-body
		)
	]
	

	;--------------------------
	;-     =func-spec=:
	;
	;--------------------------
	=func-spec=:  [
		.slate-func-start:
		(
			.func-tags: clear []
			.func-names: clear []
			;.func-deprecated-names: clear []
			.func-args: clear []
			.func-body: clear []
			.func-summary: clear []
			.func-also: clear []
			.func-notes: clear []
			.func-header: none
			.header-func-name: none
			.func-type: function!
			.func-summary: none
		)
		;------------------------------
		; try to get the header, and its data.
		;------------------------------
		copy .func-header opt =func-header=
		
		
		;------------------------------
		;-        - find tags (ex: #API)
		;------------------------------
		any [
			=whitespaces?=
			"#" copy .tag =content= (
				append .func-tags to-issue .tag 
			)
			=whitespaces=
			;( vprint "found tag"	)
		]
		;	(v?? .header-func-name)
		
		;------------------------------
		;-        - find function name(s)
		;------------------------------
		.qhere:
		;(
		;vprint ">>>>>>>>>>>>>>>>>>>>>>>"
		;v?? [copy/part .qhere 20]
		;)
		some [
			=whitespaces?= 
			[
				=set-word= 
				| ["set" =whitespaces= "'" copy .val =word=]
			]
			=whitespaces=
			(append .func-names .val)
		]
		
		;------------------------------
		;-        - match one of any valid function builders
		;------------------------------
		[
			[
				[
					[
						  "funct"
						| "funcl"
						| "func" 
					]
					=whitespaces?=
					;(vprint "============>")
					;=print-line=
					;(vprint "============>")
					=func-args= 
					
				| [
				]
					"function"  ; must be adapted for red... (where it is equivalent to funcl)
					=whitespaces?=
					=func-args= 
					
					; skip locals block
					=whitespaces?=
					=block=
				]
				
				| "has" =whitespaces?= =block= ; in this case the given block is just locals
				| "does"
			]
			=whitespaces?=
			=func-body=

			| [
				"make" =whitespaces= "routine!" =whitespaces?= =func-args=
				(.func-type: routine!)
			]
		]
		.slate-func-end:
		(
			append .functions make !slate-function [
				fid: 		slate-globals/last-fid: slate-globals/last-fid + 1  ; this is used to differenciate between several functions with the same name
				file:		slate-globals/current-filepath
				tags:		all [not empty? .func-tags	copy .func-tags]
				names:		all [not empty? .func-names	copy .func-names]
				hdr-name:	all [.header-func-name		copy .header-func-name]
				hdr:		all [.func-header				copy .func-header]
				summary:	all [.func-summary not empty? .func-summary copy .func-summary]
				also:		all [not empty? .func-also	copy .func-also]
				notes:		all [not empty? .func-notes	copy .func-notes]
				args:		.func-args ; will remain empty, this means its a refinement.
				body:		all [not empty? .func-body	.func-body] ; already a copy of =block= rule
				func-source: copy/part .slate-func-start .slate-func-end
				func-type:  .func-type
			]
			;v?? fspec
			vprint ["FUNCTION " .func-names "^/" ]
		)
		
		;(ask ">")
	]	
]


;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- SLATE CONTEXT RULES
;
;-----------------------------------------------------------------------------------------------------------

annex [
	;--------------------------
	;-     =context=:
	;
	; will detect a single use of context and will detect any functions inside.
	;--------------------------
	=slate-context=: [
		(
			.func-lbls: clear []
		)
	]
]



;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- FUNCTIONS
;
;-----------------------------------------------------------------------------------------------------------



;--------------------------
;-     extract-source-data()
;--------------------------
; purpose:  
;
; inputs:   
;
; returns:  
;
; notes:    
;
; to do:    
;
; tests:    
;--------------------------
extract-source-data: funcl [
	source-data [string!]
][
	vin "extract-source-data()"
	analyse/bind source-data [
		any [
			=comment=
			| =whitespaces=
		]
		any [
			[
				=rebol-header=
				opt =whitespaces=
				(v?? .rebol-header)
			]
			| [
				=red-header=
				opt =whitespaces=
				(v?? .rebol-header)
			]
		]
	
		some [
			.here: 
			[
				=func-spec=
				; skip the following 
				;| =
				| some =rebol-token-char=
				| some [ =spacers= =eol= ] ; empty lines
				| skip ;(if 1000 = modulo index? here 1000 [vprint index? here]) 
			]
		]
	]

	vout
]


;--------------------------
;-     func-html-path()
;--------------------------
; purpose:  returns a unique html page name for any resource given.
;
; inputs:   
;
; returns:  
;
; notes:    there may be a default html dir applied to all paths, when used within a framework.
;
; to do:    
;
; tests:    
;--------------------------
func-html-path: funcl [
	data [object! word! none!] "when a word, it can be one of the index type pages... any of [index test-results].  note that any index page will be contextualized to the current slate-global setup none! ( are we in a lib? , a slim package?, etc.) returns the root page"
	/label value [string! word!] "some data may allow an option label to categorize the page within a framework. when data is none!, it returns a root level page of this name."
][
	;vin "func-html-path()"
	dir: copy %""
	
	
	;---
	; is html root set?
	append dir any [ slate-globals/root-html-dir %"" ]
	
	;v?? slate-globals/root-html-dir
	
	;---
	; are we within a source file?
	if file? slate-globals/current-filepath [
		append dir prefix-of slate-globals/current-filepath
		append dir "/"
	]

	;--
	; TODO: increase path based on things like  slim lib, slim package, dir-tree depth, etc.
	;--

	;?? dir
	
	switch type?/word data [
		;---
		; we currently only expect a function spec
		; todo: support other extracted data 
		;---
		object! [
			name: any [
				all [value to-string value]
				form data/names
			]
			append name ".html"
			path: join dir name
		]
		
		word! [
			switch/default data [
				index [ 
					path: join dir %index.html
				]
			][
				path: rejoin [dir data ".html"]
			]
		]
		
		none! [
			;--
			; note we do not rejoin with the html-root-dir
			path: join any [slate-globals/root-html-dir %""] %index.html
		]
	]

	;----
	; cleanup path to remove bogus characters:
	path: as-string path
	analyse/bind path [
		some [
			some =valid-filesystem-char=
			| .here: skip (change .here "_")
		]
	]
	
	path: to-file path
	;v?? path
	;vout
	path
]



;--------------------------
;-     apply-arg-to-template()
;--------------------------
; purpose:  given an arg object, will apply all the fields to the given text.
;
; inputs:   
;
; returns:  
;
; notes:    
;
; to do:    
;
; tests:    
;--------------------------
apply-arg-to-template: funcl [
	template [string!] "text to modify"
	arg [object!] "an argument spec object, can be refinement or argument.."
	;/refinement "this is a sub argument to a ref, change the class name"
][
	vin "apply-arg-to-template()"
	v?? arg
	v?? template
	
	type-content: copy ""
	either arg/types [
		foreach item arg/types [
			append type-content rejoin [ "  " item ]
		]
		unless empty? arg/types [
			type-content: rejoin [type-content {</span>}]
		]
	][
		type-content: "any-type!"
	]
	
	
	
	either arg/refinement-args [
		replace/all template "##REFINEMENT##"   	arg/name
		replace/all template "##REFINEMENT-DOC##"   any [arg/doc "Undocumented"]
	][
		replace/all template "##ARG-NAME##"  any [arg/name ""]
		replace/all template "##ARG-TYPES##" type-content
		replace/all template "##ARG-DOC##"   any [arg/doc "Undocumented"]
	]
	vout
	template
]



;--------------------------
;-     build-args-spec()
;--------------------------
; purpose:  
;
; inputs:   
;
; returns:  
;
; notes:    
;
; to do:    
;
; tests:    
;--------------------------
build-args-spec: funcl [
	func [object!]
][
	vin "build-args-spec()"
	
	html: copy ""
	
	;----
	; iterate over required arguments
	foreach arg func/args [
		v?? arg
		;---
		; are we done with required arguments?
		if arg/refinement-args [
			break
		]
		;-----
		; add a required argument
		tmplt: get-template 'argument
		append html apply-arg-to-template tmplt arg
	]
	
	
	vout
	copy html
]




;--------------------------
;-     build-refinements-spec()
;--------------------------
; purpose:  
;
; inputs:   
;
; returns:  
;
; notes:    
;
; to do:    
;
; tests:    
;--------------------------
build-refinements-spec: funcl [
	func [object!] "function context for which to build refinement documentaiton"
][
	vin "build-refinements-spec()"
	HTML: copy ""

	;----	
	; loop on refinements
	foreach arg func/args [
		;------
		; are we a refinement?
		if arg/refinement-args [
			;--------
			; we ignore local and /external words since this is implementation specific, the user
			; of a function doesn't need to know how it uses words internally.
			;---
			unless any [
				arg/name = /local
				arg/name = /extern
			][
				; first line is special, we may have a refinement docstring or not.
				either all [
					not arg/doc 
					not empty? arg/refinement-args
				][
					;----
					; we have no docstring AND we have arguments to display, 
					;
					; we'll merge this arg (the refinement) and our first sub-arg on the same line (table row)
					tmplt: get-template 'refinement-arg
					apply-arg-to-template tmplt arg ; it will setup the /refinement name
					v?? tmplt
					
					ref-arg: first arg/refinement-args
					apply-arg-to-template tmplt ref-arg ; it will now add the refinement's argument data
					arg/refinement-args: next arg/refinement-args ; we should skip it since we don't want to add it a second time.
				][
					tmplt: get-template 'refinement-doc
					apply-arg-to-template tmplt arg ; it will setup the /refinement name AND given docstring
				]
				
				append HTML tmplt
				
				;---
				; add all remaining refinement arguments.
				foreach sub-arg arg/refinement-args [
					tmplt: get-template 'refinement-arg
					append HTML apply-arg-to-template tmplt sub-arg
				]
				
				;---
				; make sure any manipulations of the list are reset.
				arg/refinement-args: head arg/refinement-args
			]
		]
	]
	vout
	
	HTML
]





;--------------------------
;-     document()
;--------------------------
; purpose:  
;
; inputs:   
;
; returns:  
;
; notes:    - docset is just a global tag added to all documentation in order to group them
;
; to do:    
;
; tests:    
;--------------------------
document: funcl [
	[catch]
	"Add / refresh a file in the documentation"
	path [file!] "An absolute path."
	;root [file!] "From which root does was file accumulated.  All folders from here to the "
	/docset document-set [word!] "Associate this file to a document set."
	/except except-funcs [block!] "Ignore these things (functions, properties, etc)"
][
	vin "slate/document()"
	v?? document-set
	
	throw-on-error [
	
		unless slate-globals/site-root [
			to-error "must set slate-globals/site-root before calling slate/document()"
		]
		;------------------------------
		;-        - Read file(s)
		;------------------------------
		unless all [
			absolute-path? path 
		][
			to-error "slide/document-file() requires absolute paths"
		]
		
		unless exists? path [
			to-error rejoin [ "slide/document-file() path : " path " doesn't exist" ]
		]
		
		either dir? path [
			files: dir-list/absolute path 
		][
			files: reduce [ path ]
		]
		
		
		;------------------------------
		;-        - Extract source code data
		;------------------------------
		foreach file files [
			slate-globals/current-filepath: file
			data: read file
			extract-source-data data
		]
		
		
		data: get-parse-ctx
		;v?? data/.functions
		
		
		;------------------------------
		;-        - Create dictionary-type index page
		;------------------------------
		foreach f data/.functions [
			;probe f/names
			;v?? f/names
			;v?? f/hdr-name
			
			;vdump f
			
			
			all [
				block? f/names
				string? f/hdr-name
				not find f/names f/hdr-name 
				(
					vprint ["possible header mismatch in function: " mold f/names " vs. " mold f/hdr-name]
					
					; add the label with a marker noting the name is wrong.
					append slate-globals/local-site-func-index reduce [rejoin [f/hdr-name " **" ] f]
				)
			]
			(
				foreach name f/names [
					append slate-globals/local-site-func-index reduce [name f]
				]
			)
		]
		
		
		
		;------------------------
		; setup some reusable templates and values
		;------------------------
		site-menu: get-template 'site-menu
		source-filename: any [
			all [
				file? slate-globals/current-filepath
				filename-of slate-globals/current-filepath
			]
			"unknown file"
		]
		source-prefix: any [
			all [
				file? slate-globals/current-filepath
				prefix-of slate-globals/current-filepath
			]
			"unknown-file"
		]
		
		
		
		;------------------------
		; build index page
		;------------------------
		vprint "================================="
		vprint " building index page"
		vprint "================================="
		
		v?? [length? slate-globals/local-site-func-index ]
		
		tmplt: get-template 'source-file
		
		;------------------------
		; build index dictionnary menu
		sort/skip slate-globals/local-site-func-index 2
		index-text: copy {<TABLE class="function-list">^/}
		list-row: clear ""
		i: 0
		foreach [ name ctx ] slate-globals/local-site-func-index [
			++ i
			append list-row rejoin [ {<TD><a class="dict-link" href="} filename-of func-html-path/label ctx name {">} lowercase copy name {</a></TD>} ]
			if 0 = modulo i slate-globals/function-list-columns [
				append index-text rejoin ["^-<TR>" list-row "</TR>^/"]
				clear list-row
			]
			v?? name
		]
		append index-text  {</TABLE>^/}
		
		replace tmplt "##DICT-MENU##" index-text
		replace tmplt "##SITE-MENU##" site-menu
		replace/all tmplt "##TITLE##" rejoin ["" source-filename " script file documentation"]
		replace/all tmplt "##FILE-NAME##" source-filename
		replace/all tmplt "##DOCSET##" document-set
		
		path: join slate-globals/site-root func-html-path 'index
		dir: directory-of  path
		make-dir/deep dir
		write path tmplt
		
		
		;------------------------------
		;-        - build function description page
		;------------------------------
		foreach [ name ctx ] slate-globals/local-site-func-index [
			;------------------------
			; setup function-specific templates and values
			;------------------------
			tmplt: get-template 'function
			
			
			either (length? ctx/names) > 1 [
				all-names: clear ""
				foreach func ctx/names [
					append all-names rejoin [{<span class="func-names-list">} func {</span>} ]
				]
			][
				all-names: "(none)"
			]
			
			
			replace/all tmplt "##TITLE##" rejoin ["" name " function documentation"]
			replace/all tmplt "##UPPER-FUNCTION##" uppercase copy name
			replace/all tmplt "##FUNCTION##" name
			replace/all tmplt "##FILE-NAME##" source-filename
			replace/all tmplt "##ALL-NAMES##" all-names
			replace/all tmplt "##DOCSET##" document-set
			replace     tmplt "##SITE-MENU##" site-menu
			replace     tmplt "##ARGS##" build-args-spec ctx
			replace     tmplt "##REFINEMENTS##" build-refinements-spec ctx
			replace     tmplt "##FUNC-SOURCE-CODE##" replace/all (replace/all ctx/func-source "<" "&lt;")  ">" "&gt;"
			replace/all tmplt "##FUNC-SUMMARY##" any [ctx/summary "This function has no embedded documentation."]
			
			write join slate-globals/site-root func-html-path/label ctx name tmplt
		]
		;------------------------------
		; TO DO:  
		;-        - document each function
		;-            * name
		;-            * #tags
		;-            * args 
		;-            * locals 
		;-            * see also 
		;-            * usage 
		;-            * manage TODO notes
		;-            * alternate spellings
		;-            * used by (list other libs which use this function (track slim/open calls))
		;-            * unit tests (run and track results, including speed!)
		;-            * note if it has missing fields in function documentation block.
		;-            * inner documentation / notes / usage
		;-            * add user comments section, allowing documentation extensions at the end. (** REQUIRES DB AND SERVER **)
		;-            *
		
	]
		
	vout
]





; end of register
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

