REBOL [
	; -- Core Header attributes --
	title: "SLIM | Unit testing"
	file: %slut.r
	version: 1.0.4
	date: 2019-02-12
	author: "Maxim Olivier-Adlhoch"
	purpose: {Unit testing integrated into slim using inlined test definitions.}
	web: http://www.revault.org/modules/slut.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'slut
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/slut.r

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
		v0.1.0 - 2012-11-21
			-creation
			-basic parsing rules created.
			
		... a LOT OF HISTORY GOES UNMARKED ...
		
		v1.0.0 - 2013-02-01
			-improved main rule so it skips text and only matches rule when they start at newlines.
			 this allows us to comment out tests, even though they are within REBOL comments
			-note that previous fix doesn't affect the internals of a test which can still span mulitple lines as before.
			-better error reporting for string error reports
	
		v1.0.1 - 2013-09-12
			-License changed to Apache v2
			
		v1.0.2 - 2013-10-03
			-added support for comment lines in test-groups, via =test-newlines= rule.
			
		v1.0.3 - 2018-04-04
			-DO-TESTS Result now includes timing information.
			-DO-TESTS now supports two tag filtering modes
			
}			
	;-  \ history

	;-  / documentation
	documentation: {        
	
		<Note: the documentation might be due for an update, based on latest features.>

		add unit testing WITHIN any file, in order to localise tests and actual source code.
		
		the tests are placed within source comments, so they have NO IMPACT on running source code.
		
		this library allows you to extract the tests out of any slut compliant file and run them.
		
		using a variety of standardized test settings, you can select which tests to run out of the complete set, if you want.
		
		you can also build test groups and have tests which span several lines.
		
		test are allowed to specify preambles, which are executed prior to the test.  preambles are stored independently,
		so they can be re-used for several tests. this is often used to setup data, preserve session or restore 
		the evironment in a default state to prevent test side-effects from affecting further tests.
		
		you may specify init blocks which are ALWAYS executed only only once when a running test is performed.
		all init blocks of all files are run before any test is executed, which allows you to properly initialize your
		session.
		
		like prebol, you can also run code immediately, when the slut scanner runs, when you use the TEST-DO command.
		In this case, the given block will be executed just after the parser finds it before all other test considerations are met.
		you could print version errors, quit the testing, even setup data BEFORE a slim library loads.
		
		additionaly, slim is integrated into slut, which allows any slim library to load itself (as well as its
		dependencies, as usual) and run the test within that module's context, effectively binding the test code
		to the library itself.
		
		note that the slim library will only be opened once all the file or string is parsed... thus, you can use the
		immediate mode 'TEST-DO command to run code before the module loads, when a module is affected by the global
		environement it runs it.  (maybe a lib initialized differently when global values are set?) .
		
		
		TEST return values
		-----------------
		the return value for any test determines its success or failure.
		
		any none, false, error! or string! return value is considered a failure.
		
		strings are used to report explicit error messages.
		
		if your test triggers an error, it will be recovered, and the error object put in the test report.
		
		if you with to test failures, simply prefix your test with a negative or recovering piece of code like so:
			test 'label [ error?  try [ 0 / 0] ]
			test 'label [ none? all [ select [] 'lbl ] ]
			
		These will return true, so they are marked as successfull tests.  The point is to test if the function
		properly triggers errors or returns none when it should.
		
		  
		
		
		currently, we do not catch any throws.
		
		
	}
	;-  \ documentation
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'slut
;
;--------------------------------------

slim/register [


	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	slim/open/expose/platform 'chrono none [ chrono-time dt: time-lapse ]
	slim/open/expose 'utils-blocks none [ set-tag ]
	slim/open/expose 'utils-series none [ count contains? ]

	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     preambles:
	;
	; a list of test preambles which can be used for any test
	;--------------------------
	preambles: []
	
	
	
	;--------------------------
	;-     tests:
	;
	; list of tests which where defined.
	;--------------------------
	tests: []
	
	
	;--------------------------
	;-     inits:
	;
	; initialization code storage.
	;--------------------------
	inits: []
	
	
	;--------------------------
	;-     last-used-tags:
	; when tags are used on a DO-TESTS() we store them here
	; and can reuse them without specifying them again.
	;--------------------------
	last-used-tags: none
	
	
	;--------------------------
	;-     tags-mode:
	; when using tags with DO-TESTS() did we use /ANY-OF or /ALL-OF
	;--------------------------
	tags-mode: none
	
	
	
	
	;--------------------------
	;-     current-test-library:
	;
	; when there is an active library, we attempt to load it and all code blocks are bound to it.
	; 
	; because files will eventually be allowed to run tests on subfiles, this is a stack, of current/parent files.
	; the "current" file is the last file in the list.
	;
	; this allows us to make unit-tests which depend on the code of that library.
	;
	; If we didn't do this, the tests would try to run in global space.
	;
	; Note that if you run testing on files, libraries will be automatically unset when they are finished
	; if you run testing on a string, then its your job to manage this.
	;--------------------------
	current-test-library: none
	
	
	;--------------------------
	;-     lib-stack:
	;
	; when loading libraries, 
	;--------------------------
	lib-stack: []
	
	
	;--------------------------
	;-     file-list:
	;
	; just remember what files where already loaded so we don't try to load them again.
	;--------------------------
	file-list: []
	
	
	
	;--------------------------
	;-     process-list-stack:
	;
	; joins the two things above into a single list.
	;--------------------------
	process-list-stack: []
	
	

	;--------------------------
	;-     summary-columns:
	;
	; stores how many columns are in the summary result block of 'DO-TESTS
	;--------------------------
	summary-columns: 5
	
	;--------------------------
	;-     summary-header-elements:
	;
	; how many items are in the header data of the 'DO-TESTS summary
	;--------------------------
	summary-header-elements: 4
	
	
	
	
	
	;-----------------------------------------------------------------------------------------------------------
	;
	;- CLASSES
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     !test [ ]
	;
	; storage for a unit test
	;--------------------------
	!test: context [
		;--------------------------
		;-         meta:
		;
		; stores information picked up by the test parser.
		;
		; these are stored as select pairs, and some fields are often shared across tests (file or library, for example).
		;
		; the meta information is often used for reporting purposes or for searching.
		;--------------------------
		meta: []

	
		;--------------------------
		;-         labels:
		;
		;
		;--------------------------
		labels: []
		
		
		;--------------------------
		;-         options:
		;
		; a set of option flags which change how the test is performed
		;
		;  it may include one or more of the following flags:
		;     'no-GC
		;
		; note that when adding options, do not use lit-words.  i.e. use [ no-GC ]  not [ 'no-GC ]
		;--------------------------
		options: []
		
		
		;--------------------------
		;-         preambles:
		;
		; test snippets which must be executed prior to our own test code
		;--------------------------
		preambles: none
		
		
		;--------------------------
		;-         code:
		;
		; the rebol code to execute using 'DO
		;--------------------------
		code: []
		
		
		;--------------------------
		;-         start:
		;
		; when did the test start running
		;--------------------------
		start: none
		
		
		;--------------------------
		;-         finish:
		;
		; when did the test finish execution
		;--------------------------
		finish: none
		
		
		;--------------------------
		;-         mem-usage:
		;
		; difference in stats before/after
		;--------------------------
		mem-usage: none
		
		
		;--------------------------
		;-         expect-error?:
		;
		; when set to true, the error reporting is inversed,
		; we expect an error to occur, we are enforcing this specifically.
		; 
		; put the REBOL error code to expect 
		; (we will compare the disarmed error)
		;
		; in the dialects, use a #xxx in front of the test.
		;		ex:  #400 [ 0 / 0 ]
		;
		; you can optionaly add an error 'id as well, using a lit-word!
		;		ex:  #400 'zero-divide [ 0 / 0 ]
		;
		;--------------------------
		expect-error?: none
		
		
		;--------------------------
		;-         expect-error-id?:
		; 
		; stores the error ID as explained above
		;--------------------------
		expect-error-id?: none
		
		
	]
	
	
	
	;--------------------------
	;-     !preamble [ ]
	;
	; stores a preamble
	;--------------------------
	!preamble: context [
		;--------------------------
		;-         labels:
		;
		;
		;--------------------------
		labels: []
		
		
		;--------------------------
		;-         code:
		;
		;
		;--------------------------
		code: []
	]
	
	
	;--------------------------
	;-     !summary [ ]
	;
	;
	;--------------------------
	!summary: context [
		;--------------------------
		;-         errors?:
		;
		; number of tests which generated errors
		;--------------------------
		errors?: 0
		
		
		;--------------------------
		;-         failed?:
		;
		; number of tests that returned none, false or a string
		;--------------------------
		failed?: 0
		
		
		;--------------------------
		;-         succeeded?:
		;
		; number of tests which didn't fail or errored.
		;--------------------------
		succeeded?: 0
		
		
		;--------------------------
		;-         total:
		;
		; total number of tests
		;--------------------------
		total: does [errors? + failed? + succeeded?]
		
		
		
		;--------------------------
		;-         labels:
		;
		; what tests where requested
		;--------------------------
		labels: none
		
		
		
		
		
		;--------------------------
		;-         report:
		;
		; a block of strings which report various test activities.
		;
		; note that if a test returns a string!, it is added here
		; and counted as a failure.
		;--------------------------
		report: []
		
		
	]
	
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- INTERNAL FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	
	;--------------------------
	;-     add-init()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	add-init: funcl [
		blk [block!]
		/extern inits
	][
		vin "add-init()"
		;v?? blk 
		inits: [] ; note that this is a static block and will be re-used AFTER do-init clears inits.
		append/only inits bind-test-block blk
		new-line/all inits true
		vout
		inits
	]
	
	
	
	;--------------------------
	;-     add-preamble()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	add-preamble: funcl [
		labels [block!]
		blk [block!]
	][
		vin "add-preamble()"
		append preambles preamble: make !preamble compose/only [
			labels: (labels)
		]
		
		preamble/code: bind-test-block blk
		vprobe length? preambles
		
		vout
	]
	
	
	
	
	;--------------------------
	;-     add-test()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	add-test: funcl [
		labels [block!]
		blk [block!]
		/using pre [block!]
		/meta [block!]  "meta test information like current library or file, line numbers, etc."
	][
		vin "add-test()"
		append tests test: make !test compose/only [
			labels: (labels)
			;code: test
			if using [
				preambles: pre
			]
		]
		
		test/code: bind-test-block blk
		
		vout
		test
	]
	
	
	
	
	
	
	;--------------------------
	;-     set-test-meta()
	;--------------------------
	; purpose:  a dialect to setup a tests's meta properties.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	set-test-meta: funcl [
		test [object!]
		meta 
	][
		vin "set-test-meta()"
		input: compose [(meta)]
		
		
		test/meta: meta:  any [ test/meta copy [] ]
		
		
		v?? input
		parse input [
			any [
				set .data file! (
					set-tag meta  'file .data
				)
				
				| set .data word! (
					set-tag meta 'library .data
					set-tag meta 'file    rejoin [%"" .data ".r"]
				)
				
				| set .data integer! (
					;vprint "integer!"
					set-tag meta 'line .data
				)
			]
		]
		
		new-line/skip meta true 2
		
		vprobe test
		
		vout
		meta
	]
	
	
	
	
	;--------------------------
	;-     add-file()
	;--------------------------
	; purpose:  add a file to our list of test files
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    will not add the same file twice.
	;
	; tests:    
	;--------------------------
	add-file: funcl [
		file [ file! ]
	][
		vin "add-file()"
		unless find file-list file [
			append file-list clean-path file
			append process-list-stack clean-path file
		]
		vout
	]
	
	
	
	;--------------------------
	;-     enter-library()
	;--------------------------
	; purpose:  specify a slim library we wish to use for the next tests.
	;
	; inputs:   name of a loadable library.
	;
	; notes:    raises an error if the library can't be loaded.
	;--------------------------
	enter-library: funcl [
		name [word! lit-word!]
		/extern current-test-library
	][
		vin "slut/enter-library()"
		;-----
		; make sure we don't have a lit-word! within NAME
		;
		; any lit-word input will be evaluated as a word,
		; a word! remains a word!
		;---
		name: name
		
		v?? name
		current-test-library: slim/open name none ; we always use the latest version with slut.
		
		;vprobe type? current-test-library
		;vprobe words-of current-test-library
		
		append lib-stack current-test-library
		append process-list-stack current-test-library
		
		vout
	]
	
	
	
	;--------------------------
	;-     exit-library()
	;--------------------------
	; purpose:  exits the current library in order to return to the one being used prior.
	;
	; inputs:   none
	;
	; notes:    if no library was being used, we raise an error
	;
	; tests:    
	;--------------------------
	exit-library: funcl [
		/extern current-test-library
	][
		vin "slut/exit-library()"
		if empty? lib-stack [
			to-error "Slim Unit Testing engine is trying to exit a library which isn't set."
		]
		remove back tail lib-stack
		remove back tail process-list-stack
		current-test-library: attempt [
			last lib-stack
		]
		vprobe type? current-test-library
		vout
	]
	
	
	
	;--------------------------
	;-     bind-test-block()
	;--------------------------
	; purpose:  given any block, will setup the code so it executes properly.
	;
	; inputs:   a block of code
	;
	; returns:  a COPY of the code
	;--------------------------
	bind-test-block: funcl [
		blk [block!]
	][
		vin "bind-test-block()"
		blk: copy/deep blk
		
		;vprobe words-of current-test-library
		
		if current-test-library [
			vprint "binding block to library"
			bind blk current-test-library
		]
		
		
		
		;ask "..."
		
		vout
		
		blk
	]
	
	
	
	;--------------------------
	;-     get-preambles()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	get-preambles: funcl [
		;test [object!]
		labels [block! word! lit-word! object!] "If given an object!, it will lookup its preambles list."
		/script
	][
		vin "get-preambles()"
		switch type?/word labels [
			object! [
				labels: get in labels 'preambles
			]
			
			word! lit-word! [
				labels: reduce [labels]
			]
			
			block! [
			
			]
		]
		v?? labels
		if labels [
			prmbls: copy []
			
			foreach preamble preambles [
				v?? preamble
				if contains?  labels  preamble/labels  [
					vprint "--> MATCH <--"
					append prmbls preamble
				]
			]
		]
		
		vout
		
		
		prmbls
	]
	
	
	
	;--------------------------
	;-     do-inits()
	;--------------------------
	; purpose:  run the init blocks which where extracted from source.
	;
	; notes:    -ALL inits are executed no matter what tests are run.
	;           -once executed, they are flushed.  you cannot run them again (its the point of them).
	;           -you may need to use preambles instead of inits in some cases.
	;
	;           -there is no execution sand-box.   if the inits fail, errors will be raised normally.
	;           
	; tests:    
	;--------------------------
	do-inits: funcl [
		/extern inits
	][
		vin "slut/do-inits()"
		
		v?? inits
		
		if block? inits [
			foreach block inits [
				do block
			]
			clear inits ; we flush it cause it will be reused by ADD-INIT()
		]
		inits: none
		vout
	]
	


	
	;--------------------------
	;-     count-line()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	count-line: func [
		new-offset
		/local i
	][
		vin "count-line()"
		i: count/part .last-line-offset  "^/" new-offset
		v?? i
		v?? .last-line
		.last-line: .last-line + i
		.last-line-offset:  new-offset
		vprobe i
		vout
		i
	]
	
	
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PARSE RULES
	;
	;-----------------------------------------------------------------------------------------------------------
	
	.blk:  none
	.name: none
	.here: none
	.preambles: none
	.labels: none
	.current-file: none
	.line-backup:  none
	.line-offset-backup: none
	.last-line:       none
	.last-line-offset: none


	=whitespace=: charset "^-^/ "
	=whitespaces=: [some =whitespace=]
	=whitespaces?=: [opt =whitespaces=]
	
	=space=:  charset "^- " ; there is no difference between spaces and tabs in slut.
	=spaces=: [some =space=]
	=spaces?=: [opt =spaces=]
	
	=letter=: charset [ #"a" - #"z"    #"A" - #"Z" ] 
	=digit=:  charset "0123456789"
	=word-special-char=: charset "-_=!?."
	
	=word!=:  [
		[ =word-special-char= | =letter= ] 
		any [ =word-special-char= | =letter= | =digit= ]
	]
	
	=lit-word!=: [ #"'" =word!= ]
	
	=newline=: charset "^/"
	=content-char=: complement =newline=
	=content=: [some =content-char=]
	=content?=: [opt =content=]
	
	
	;--------------------------
	;-     =test-prefix=:
	;
	; this is set as a string, since some users might want to use some other token.
	;--------------------------
	=test-prefix=: "test-"
	
	;--------------------------
	;-     =test-newline=:
	;
	; verifies if there is a new-line and comment between two rules.
	; note that it always consumes all whitespaces it can find (other than newlines)
	;--------------------------
	=test-newline=: [
		=spaces?=  
		;(prin ".1.")  
		
		#"^/" 
		;(prin ".2.")  
		
		=spaces?=  
	;   (prin ".3.") 
	
		#";" 
	;   (prin ".4.") 
	
		=spaces?= 
	;   (prin ".5.") 
	]
	=test-newlines=: [
		=spaces?=  
		;(prin "-1-")  
		some [ 
			;(prin "-2-")
			;here:
			;(probe mold/all copy/part here 10)
			
			#"^/"  
			;(prin "-3-") 
			
			=spaces?=  
			;(prin "-4-") 
			
			#";" 
			;(prin "-5-") 
			
			=spaces?= 
			;(prin "-6-") 
			
			opt [
				#";"
				to #"^/"
			]
		]
	]
	
	
	
	
	
	
	;--------------------------
	;-     =test-block=:
	;
	; returns a slut-compliant block of code hidden within comments.
	; multi-line BLOCKS must start with <[ and end with ]> 
	;
	; note that the <> chars are removed before loading the code.
	;
	; also note that the first comment char of any line if removed.
	; thus, if you want to comment out a line you require two comments.
	;
	; usually this is harmless since the first comment is at the start of the line.
	; and the second one will be indented at the code's depth.
	;--------------------------
	
	=test-block=: [
		[ 
			; single line block
			[
				copy .blk ["[" to "^/" ] (
					.blk: load .blk 
				)
			]
			| [
				; multi-line block
				"<" copy .blk [
					"[" to "]>" ; make sure we find both "]>" characters 
					skip        ; skip the "]" so its part of the .blk
				] skip          ; skip the ">" since we don't need it.
				
				
				(
					;now we must remove all the first ";" characters of each line.
					parse/all .blk [
						=content?=
						any [
							=newline=  =spaces?=  opt [
								.here: ";" (remove .here) :.here
							]
							; skip the rest of the line... we ignore it
							[to "^/" | to end]
						]
					]
				)
				(
					.blk: load .blk 
					;?? .blk
				)
			]
			
						
			| [
				(.blk: none) [to end skip] ; always fails, but resets .blk
			]
		]
	]

	
	
	;--------------------------
	;-     =block-of-words=:
	;
	; note that there MUST be at least one word in the block.
	;--------------------------
	=block-of-words=: [
		#"[" 
		some [
			=whitespaces?=  
			=word!=
		]
		=whitespaces?= 
		#"]"
	]
	
	
	;--------------------------
	;-     =labels=:
	;
	; setup name using one or more words (lit-word or a block)
	; note that there MUST be at least one word.
	;--------------------------
	=labels=: [
		copy .labels [
			=lit-word!= 
			| =block-of-words=
		](
			.labels: load .labels
			.labels: .labels ; convert lit-word! to word!
			.labels: compose [(.labels)]
			;?? .labels
		)
	]
	
	;--------------------------
	;-     =opt-labels=:
	;
	; setup name using one or more words (lit-word or a block)
	;
	; allows empty blocks, but sets .labels to none, while skipping the empty block.
	;--------------------------
	=opt-labels=: [
		copy .labels [
			=lit-word!= 
			| =block-of-words=
			| #"[" =whitespaces?= #"]"
		](
			.labels: load .labels
			.labels: .labels ; convert lit-word! to word!
			.labels: compose [(.labels)]
			if empty? .labels [
				.labels: none
			]
			;?? .labels
		)
	]
	
	
	
	;--------------------------
	;-     =test-do=:
	;
	; the  code following the keyword  will be evaluated immediately, when encountered by the slut engine.
	; this may be used to setup rebol or the test environment itself before testing runs start  (including test-inits)
	;--------------------------
	=test-do=: [
		";" =whitespaces?=  =test-prefix= "do" =whitespaces= =test-block=
		(
			vin ["Found test execution blocks: " .labels ]
			
			do   .blk
			vout
		)
	]
	
	
	

	;--------------------------
	;-     =test-init=:
	;
	; this rule will run exactly once and only once at the begining of the test execution phase.
	;
	; you may assign init to different labels, but you can only init once.  so you may init a subset of tests.
	;--------------------------
	=test-init=: [
		";" =whitespaces?=  =test-prefix= "init" =whitespaces= =test-block=
		(
			vin ["found test initialization: " .labels ]
			add-init   .blk
			vout
		)
	]
	

	;--------------------------
	;-     =preamble=:
	;
	;  these can be added to any test to set it up.
	;--------------------------
	=preamble=: [
		";" =whitespaces?= =test-prefix= "preamble" =whitespaces=  =labels=  =whitespaces?= =test-block=
		(
			vin ["found a preamble: " .labels ]
			v?? .blk
			
			add-preamble  .labels  .blk
			vout
		)
	]


	;--------------------------
	;-     =expect-error-spec=:
	;
	;--------------------------
	=expect-error-spec=: [
		(.err-num: none .err-id: none)
		"#" copy .err-num some =digit= (.err-num: to-integer .err-num) ; got an error number
		opt [
			=whitespaces?= 
			copy .err-id =lit-word!=
			(.err-id: to-word next .err-id) ; got an error
		] 
		=whitespaces?= 
	] 


	;--------------------------
	;-     =test=:
	;
	; a test specification
	;--------------------------
	=test=: [
		
		#";" 
		=whitespaces?= 
		
		"test"
		 =whitespaces= 
		opt =expect-error-spec=
		
		 =labels=  ( .name: copy .labels )  =whitespaces?=
		
		[
			;---------
			; the preambles block is optional in simple TEST instructions
			;---------
			[
				=labels=  ( .preambles: .labels ) =whitespaces?=  .line-offset: =test-block=
				|
				(.preambles: none)
				.line-offset: =test-block=
			]
			(
				vin ["found a test: " .name]
				;?? .blk 
				;?? .preambles
				
				either .preambles [
					tst: add-test/using .name .blk .preambles
				][
					tst: add-test .name .blk
				]
				count-line .line-offset
				
				file: last process-list-stack
				if object? file [
					file: file/header/slim-name
				]
				set-test-meta tst reduce [
					.last-line 
					file
				]
				
				if .err-num [
					tst/expect-error?: .err-num
					tst/expect-error-id?: .err-id
				]
				
				vout
			)
			
			
		]
		; set meta information for test
		(
		
		)
	]
	


	;--------------------------
	;-     =test-group=:
	;
	; a specification for many tests grouped under a common label and preamble setup.
	; the preamble is run for each test in the group.
	;--------------------------
	=test-group=: [
		(.group: clear [])
		#";" =whitespaces?=  =test-prefix= "group" =whitespaces=   
		(vprint "test group?")
		
		;---
		; names for test-group
		=labels=  ( .name: copy .labels )  =whitespaces?= 
		(vprint "Has labels")
		
		;---
		; requires preambles?
		opt =opt-labels=  ( .preambles: .labels )
		(
			vin ["found a test group: " mold .name]
			v?? .preambles
		)
		
		(
			.line-backup:         .last-line
			.line-offset-backup:  .last-line-offset
		)
		
		
	
		;---
		; list of tests. 
		; each test runs the preamble(s) again.
		[
			[
				some [
					;-------------
					; we skip comment lines...
					;-------------
					
					
					[
						;here:
						=test-newlines=  
						.line-offset: =test-block= 
						(
							count-line .line-offset
						)
					]
					
					(
						append .group reduce [ .last-line .blk ]
					)
				]
				=test-newlines= 
				"end-group"
					
					
				(
					;probe copy/part .last-list-check .here
					
					vprint ["grouped tests: " ]
					new-line/all .group true
					vprobe .group
					
					file: last process-list-stack
					if object? file [
						file: file/header/slim-name
					]
					
					
					foreach [line item] .group [
						tst: either .preambles [
							add-test/using .name item .preambles
						][
							add-test .name item
						]
						set-test-meta tst reduce [
							line 
							file
						]
					]
				)
			]
			|
			[
					
				; restore backups !!!!
				(
					.last-line: .line-backup        
					.last-line-offset: .line-offset-backup
				)
		
			
			]           
		]
		(
			vout
		)
	]
	
	
	;--------------------------
	;-     =enter-library=:
	;
	;
	;--------------------------
	=enter-library=: [
		#";"  =whitespaces?=  =test-prefix=  "enter-slim"  =whitespaces=   copy  .name  =lit-word!=  ( .name: load .name )
		(
			vin  [ "testing a slim library: " mold .name ]
			v?? .name
			enter-library  .name
			vout 
		)
	]
	
	
	;--------------------------
	;-     =exit-library=:
	;
	;
	;--------------------------
	=exit-library=: [
		#";"  =whitespaces?=  =test-prefix=  "exit-slim" 
		(
			vin  [ "exiting slim library: " mold .name ]
			exit-library  .name
			vout 
		)
	]
	
	
	;--------------------------
	;-     =extract-tests=:
	;
	;  get all the slut information out of a string.
	;--------------------------
	=extract-tests=: [
		.here:
		(
			.current-line: 0
			.last-line-offset: .here
			.last-line: 1  ; having no newlines means we are at line 1
		)
		.last-list-check:  ; reset position so we can start counting from first line
		some [
			[
				(
					.blk:  none
					.name: none
					.here: none
					.preambles: none
					.labels: none
				)
				newline
				=whitespaces?=
				[
					=preamble=
					| =test-do=
					| =enter-library=
					| =exit-library=
					| =test=
					| =test-group=
					| =test-init=
					| =whitespaces=
				]
				to newline
			]
			| skip
		]
	]

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- END USER SLUT API
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     extract()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	extract: funcl [
		data [ string! file! ]
	][
		vin "extract()"
		if file? data [
			file: data
			v?? file
			add-file file
			data: read data ; we want the error to occur if the file doesn't exist.
		]
		
		
		
		vprobe length? data
		parse/all data =extract-tests=
		
		vout
	]

	;--------------------------
	;-     do-tests()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    when tests return a string, its considered a failure, and will be accumulated
	;           within a list of messages to return to the user.
	;
	; tests:    
	;--------------------------
	do-tests: funcl [
		/any-of labels [block! word!]  "Run any test tagged with AT LEAST one of the given tags."
		/all-of alabels [block! word!]  "Run tests tagged with ALL given tags."
		/verbose
		
		; deprecated
		/only olabels [block! word!] "deprecated name for /any-of"
		
		/extern tags-mode last-used-tags
	][
		vin "slut/do-tests()"
		
		if only [
			any-of: true
			labels: olabels
		]
		
		if all [any-of  all-of][
			vout
			to-error "cannot use  /any-of  AND  /all-of  at the same time"
		]
		
		
		case [
			any-of  [tags-mode: 'any]
			all-of  [tags-mode: 'all]
			'default [tags-mode: none]
		]
		
		last-used-tags: any [ labels alabels ]
		
		;----
		; local declarations
		current-file: none
		rval: none 
		
		
		
		;--------------------------
		; setup filtering
		;--------------------------
;		; we pick which set of labels to use based on function's arguments.
;		labels: compose [(any [alabels labels olabels])] 
;		
;		remove-each label labels [
;			; if no label was given, labels will end up being an empty block.
;			not word? label
;		]
;		
;		; we setup as unfiltered, if we end up with no labels in block
;		if empty? labels [
;			labels: none
;		]
		
		;--------------------------
		; setup filtering
		;--------------------------
		labels: all [
			blk: compose [(any [alabels labels])] 
		
			remove-each label blk [
				; if no valid label was given, labels will end up being an empty block.
				not word? label
			]
			
			; we setup as unfiltered, if we end up with no labels in block
			not empty? blk

			; all is good, we have some labels.
			blk
		]
		
		v?? labels ; remove this line
		
		
		
		do-inits ; this can be called over and over, it will only do anything if new inits are found
		
		
		summary: make !summary []
		summary/labels: labels
		
		filtered-tests: copy tests
		
		;---------------
		; setup list of tests to execute
		;
		; (by default we run all tests)
		;---------------
		case [
			;---
			; filter out any test which doesn't have AT LEAST one of the given tags
			(any-of) [
				vprint ["keeping tests matching any of " labels]
				remove-each test filtered-tests [
					not contains? test/labels labels
				]
			]
			
			;---
			; filter out any test which doesn't have ALL given tags
			(all-of) [
				vprint ["keeping tests matching all of " labels]
				remove-each test filtered-tests [
					not contains?/all test/labels labels
				]
			]
		]
		
		
		i: 0
		foreach test filtered-tests [
			;--------
			; track test #
			i: i + 1
			
			;vprobe test
			preambles: any [get-preambles test  []]
			
			
			if current-file  <> (current-file: select test/meta 'file) [
				append summary/report reduce [
					'-------------------------
					'- current-file 
					'-------------------------
				]
			]
			
			;?? current-file
			;ask ".."
			
			
			
			append summary/report select test/meta 'line
			append summary/report rejoin [ "#" i  ]
			append/only summary/report test/labels
			
			vprobe preambles
			foreach preamble preambles [
				do preamble/code
			]
			if verbose [
				print rejoin ["=============== " i " =================" ]
				probe test/code
				print ""
			]
			
			either error? err: try [ 
				delay: dt [
					set/any 'rval do test/code if unset? get/any 'rval [none]
				] 
			][
				rval: disarm err
				tp: 'error!
			][
				tp: type?/word get/any 'rval
			]
			
			
			success?: false
			
			append summary/report delay
			
			;------------
			; evaluate return type to determine if the test failed or succeeded
			switch/default tp [
				;----
				; Erros
				;----
				error! [
					; do we expect an error? 
					either test/expect-error? [
						either all [
							; does the error code match
							any [
								test/expect-error? = 0 ; ANY error is good
								test/expect-error? = rval/code
							]
							; do we also match an error id ?
							any [
								not test/expect-error-id?
								test/expect-error-id? = rval/id
							]
						][
							;----
							; GOT EXPECTED ERROR
							;----
							success?: true
							summary/succeeded?: summary/succeeded? + 1
							append summary/report  'OK
						][
							; GOT UNEXPECTED ERROR FAIL!
							summary/errors?: summary/errors? + 1
							;rval: disarm rval
							append summary/report replace/all replace/all (mold rval) "    " ""  "^/" "  "
						]
					][
						summary/errors?: summary/errors? + 1
						;rval: disarm rval
						append summary/report replace/all replace/all (mold rval) "    " ""  "^/" "  "
					]
				]
				
				;----
				; Simple Failures
				;----
				none! unset!  [
					append summary/report 'FAILED
					summary/failed?: summary/failed? + 1
				]
				
				;----
				; Failure messages
				;----
				string! [
					summary/failed?: summary/failed? + 1
					append summary/report rval
				]
			
			][
				either #[false] = :rval [
					;----
					; Failure (false returned)
					;----
					summary/failed?: summary/failed? + 1
					append summary/report  'FAILED
				][
					;----
					; All is good
					;----
					success?: true
					summary/succeeded?: summary/succeeded? + 1
					append summary/report  'OK
				]
			]
			
			if verbose [
				print ["test evalutated to type: " tp]
				?? success?
				print "================================^/"
			]
		
		]
		
		new-line/all/skip ( skip summary/report summary-header-elements ) true summary-columns
			
		
		vout
		summary/total: summary/total
		
		summary
	]
	
	;--------------------------
	;-     reload()
	;--------------------------
	; purpose:  flush all loaded data from files and reload their tests from scratch
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    also flushes inits and preamble
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	reload: funcl [
		/extern inits preambles tests last-used-tags
	][
		vin "reload()"
		
		clear last-used-tags
		last-used-tags: none
		
		if block? inits [
			clear inits
		]
		inits: none

		clear preambles
		;preambles: copy []
		
		clear tests
		;tests: copy []
	
		 
		foreach file file-list [
			extract file
		]
		vout
	]
	
	
	;--------------------------
	;-     retest()
	;--------------------------
	; purpose:  reloads and test files
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	retest: funcl [
		/verbose
		/extern last-used-tags
	][
		vin "retest()"
		tags: copy last-used-tags
		
		any?: tags-mode = 'any
		all?: tags-mode = 'all
		
		
		v?? tags
		v?? any?
		v?? all?
		
		reload
		
		last-used-tags: tags
		v?? tags
		v?? any?
		v?? all?
		
		
		rval: any [
			all [verbose tags all?   do-tests/verbose/any-of last-used-tags ]
			all [verbose tags any?   do-tests/verbose/all-of last-used-tags]
			all [verbose             do-tests/verbose]
			all [tags all? 			do-tests/all-of last-used-tags]
			all [tags any? 			do-tests/any-of last-used-tags]
			do-tests
		]
		
		vout
		rval
	]
	
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

 