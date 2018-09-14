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
			-Creation}
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
	slim/open/expose 'slut none [extract]
	slim/open/expose 'utils-files none [absolute-path?]

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------



	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PARSE RULES
	;
	;-----------------------------------------------------------------------------------------------------------
	;-     -charsets
	=rebol-simple-separator=: charset "[ {(^"^/^-"
	=whitespace=: charset " ^-^/"
	=whitespaces=: [some =whitespace=]
	=whitespaces?=: [any =whitespace=]
	=content-char=: complement =whitespace=
	=content=: [some =content-char=]
	=eol=: charset "^/"
	=!eol=: complement =eol=
	=digit=: charset "0123456789"
	=alpha=: charset [#"a" - #"z" #"A" - #"Z"]
	=digits=: [some =digit=]
	=newline=: [newline (line-count: line-count + 1)]
	=colon=: charset ":"
	=word-char=: union (union =alpha= =digit=) charset "-_.!?$&*=+|~"
	...: tab
	
	;-     -patterns
	=word=: [=alpha= any =word-char=]
	=spacing=: [
		some [
			=whitespaces=
			| [#";" some =!eol=]
		]
	]


	;-     -debuging rules
	=print-line=: [
		.zzz: 
		(
			.zzz: any [
				find/reverse/tail .zzz #"^/"  
				head .zzz
			]
			vprint  copy/part .zzz any [find .zzz #"^/"  tail .zzz ] 
		)
	]
	
	=print-to-eol=: [ 
		.zzz: 
		(
			vprint  copy/part .zzz any [ find .zzz #"^/"  tail .zzz ]
		)
	]


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------


	;--------------------------
	;-     document-file()
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
	document-file: funcl [
		[catch]
		"Add / refresh a file in the documentation"
		path [file!] "An absolute path."
		root [file!] "From which root does was file accumulated.  All folders from here to the "
		/docset document-set [word!] "Associate this file to a document set."
		/except except-funcs [block!] "Ignore these things (functions, properties, etc)"
	][
		vin "slide/document-file()"
		v?? document-set
		throw-on-error [
			;------------------------------
			;-        - read file
			;------------------------------
			unless all [
				absolute-path? path 
				absolute-path? root 
			][
				to-error "slide/document-file() requires absolute paths"
			]
			unless exists? path [
				to-error rejoin [ "slide/document-file() path : " path " doesn't exist" ]
			]
			unless exists? root [
				to-error rejoin [ "slide/document-file() root-path : " root " doesn't exist" ]
			]
			data: read path
			
			v?? [length? data]
			
			
			;------------------------------
			;-        - find functions
			;------------------------------
			parse/all data [
				some [
					[
						.here:
						(
							tags: clear []
							.lbl: none
							.lbls: clear []
							;prin first .here
						)
						any [
							"#" copy .tag =content= ( append tags to-issue .tag )
							=spacing=
						]

						some [
							opt =spacing=
							copy .lbl =word= #":" ;(v?? .lbl) =print-line=
							=spacing=
							(append .lbls .lbl)
						]
						[
							  "function"
							| "funct"
							| "funcl"
							| "func" 
						]
						=rebol-simple-separator= (
							vin .lbl
							vprint "-------------------"	
							vprint ["FOUND : " .lbls]
						)
						=print-line=
						(
							vprint "-------------------"	
							vout
						)
					]
					| [
						; skip a whole token
						=content=
					]
					| skip
				]
			]
			
			
			
			;------------------------------
			;-        - add functions to index(s)
			;-        - document each function
			;-            *name
			;-            *#tags
			;-            *args 
			;-            *locals 
			;-            *see also 
			;-            *usage 
			;-            *manage TODO notes
			;-            *alternate spellings
			;-            *used by (list other libs which use this function (track slim/open calls))
			;-            *unit tests (run and track results, including speed!)
			;-            *note if it has missing fields in function documentation block.
			;-            *inner documentation / notes / usage
			
		]
			
		vout
	]

	



	
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

