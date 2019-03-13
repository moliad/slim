Red [
	; -- Core Header attributes --
	title: "SLIM | SLIM Library Manager"
	file: %slim.red
	version: 2.0.1
	date: 2019-03-13
	author: "Maxim Olivier-Adlhoch"
	purpose: {Loads and Manages Run-time & statically linkable libraries.}
	web: http://www.revault.org/tools/slim.rmrk
	source-encoding: "Windows-1252"

	; -- Licensing details  --
	copyright: "Copyright © 2019 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2019 Maxim Olivier-Adlhoch

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
		v0.0.0 - 2002-01-01
			-older history lost  :-(
			
		v0.9.12 - 2008-08-12/02:46:53 (max)
			-load, save, read, and write are now left as-is and 'xxx-resource versions created: load-resource, save-resource, etc.

		v0.9.13 - 2009-03-07/2:54:44 (MOA)
			-error when loading libs no longer use the /error refinement, allows console-quiet reloading from the net.

		v0.9.14 - 05/05/2009/10:13AM (MOA)
			-package-success added to locals block of validate func... created encap errors.

		v1.0.0  - 2012-02-11 (MOA)
			-slim now properly does word binding encapsulation when exposing words.
			 this means that sub-modules do not bleed their exposed words into the global word list anymore!

		v1.0.1  - 2012-02-17 (MOA)
			-slim now includes funcl(), defined globally.  It is such a basic mezz that will be used in all apps.
			
		v1.0.2  - 2012-09-04
			-load path ordering changed manually specified paths now have precedence over local paths.
			-'FAST() is now deprecated and no longer supported.  Any code using it should revert to using  'OPEN()

		v1.0.3  - 
			-Added SILENCE-LIB() - removes the code for vprinting from a library, making it much faster
			-added /SILENT refinement to OPEN() and REGISTER()
			-added SILENCE-ALL() - disabling vprinting for all libs loaded so far.

		v1.0.4  - 2012-11-15
			-changed license to Apache v2.0
			
		v1.0.5  - 2013-01-04
			-FLUSH() rebuilt... now requires /all or /lib refinement to be used.
			-COMPLETELY REVAMPED VPRINTING to support logging.
			-deprecated and removed ALL /error refinements from vprint 
			-vprinting  /always now overides all tags and always matches on print? or log?
			-removed all traces of STEEL, a now defunct project, slim is now simply a recursive name.
			-temporarily deprecated resource file handlers.  they are not being used by any tools yet and their implementation is obsolete, they will be revisited in next major release.
			
		v1.0.6 - 2013-01-21
			-added quiet? attribute to slim manager
			-added SLIM-ERROR() for a universal management of error reports, adapted a few functions to use it
			-All error during loading or opening libs should raise errors (unless you use the /quiet mode in slim/open).
			
		v1.0.7 - 2013-01-23
			-'GET is now expressly allowed as an overwrite within slim.
			-Added a global alias for GET ( GET* ) 
			-slim now uses GET* so there is no collision with any use of it within library
		
		v1.0.8 - 2013-02-01
			-Completely revamped vprint function binding within libraies when registering them.
			 we now use a block of functions to share with lib, and they are added to spec and bound at run-time within loops
			 this cures the problem where manipulating the vprint funcs created big gaps in symmetry from what is add and rebound.
			 
			 now you just need to add a word to the list (within REGISTER() ) and it will be shared with all libs, sharing any
			 values the library doesn't include in its spec with slim.
			
			-The above change should also remove the previous collision we had with GET since the previous vprinting binding mechanism
			 used GET within the module spec.
			-patched vtags-ctrl so it doesn't need INCLUDE AND also fixes a really bad bug it had. (basically voff with tags didn't work at all)
			 it should also be much faster since it uses rebol's native funcs to manage SETs of tags instead of a loop.
			-removed the INCLUDE() function from slim.
			-now supports module-bound VASK(), VDUMP() & VHELP() within modules.
			
		v1.0.9 - 2013-02-08
			-Improved the error message which reports invalid expose attempts. uses advanced binding tricks to recuperate
			 the calling context and discover its slim-name form the header.  We can now know exactly which module is trying
			 to expose which word from which other module.
			 
		v1.1.0 - 2013-02-21
			-added VPRINT and VINDENT to vexpose list.  somehow they where forgotten.  this prevented the use of VPRINT in slim modules.
			
		v1.1.1 - 2013-07-20
			-added package support when a group of libs are grouped in a sub dir at the same level as slim.r
			-license changed to Apache
			
		v1.2.1 - 2013-09-06
			-new git-friendly packaging system.  slim.r now also looks if it parent dir is called /libs/.  when so, it uses
			 that as its root path for library searching.
			-added default-lib-extensions to ease r2/r3 code-base integration
			
	
		v1.2.2 - 2013-11-02
			-Added 'SEARCH-PATHS function
			-'FIND-PATH now uses 'SEARCH-PATHS
			-fixed leaking global word use... 'PATH
	
		v1.2.3 - 2013-11-07
			-'VDUMP is now cyclic reference safe and identifies which objects and blocks are re-used 
			-changed output format of 'VDUMP: * blocks show length, 
											  * objects show word count
											  * function bodies are not displayed, 
											  * block & object reference IDs are shown
											  * object words are uppercased to make them stand out (helps a lot)
	
		v1.2.4 - 2013-11-15
			- 'VDUMP now has an /ignore refinement allowing it to ignore data.  This is very useful to restrict
			  output to something very specific.  you can filter by datatype, word name, or explicit value.
	
		v1.2.5 - 2014-05-14
			-Added 'ENUM function to build enum lists easily (uses a simple dialect)
			
		v1.2.6 - 2014-05-22
			-Added 'ENUM-FLAGS function (also triggered by using 'ENUM/FLAGS).
			 Allows easy building of binary flags.  The dialect supports merging of flags
			 with the use of |, you can set values directly with a Hex oriented issue! 
			 and you can set bits using integer! values.
			 
		v1.2.6 - 2014-09-12
			-file logging now has a separate verbosity switch, allowing us to have console off, and logging on.
			-added vlog-on  vlog-off
			
		v1.2.9 - 2018-08-31
			-merged bit(xx) syntax to the ENUM-FLAGS dialect
			
		v1.3.0 - 2018-09-13
			- Fixed a MASSIVE hole in implementation.  we forgot to do the slim manager version check.
			- VALIDATE() renamed to VALIDATE-LIB-HEADER()
			- removed some calls to LIB?
			- moved the last call to LIB?() within REGISTER()
			- updated LIB? conditions, moved some of the previous lib? checks to VALIDATE-LIB-HEADER()
		
		v1.3.1 - 2018-09-13
			- added explicit header validation to make sure the slim-name is the same as the actual file name
			
		v2.0.0 - 2019-02-27 - 2019-03-12
			- first Red version
			- MAJOR CLEANUP of all code, including comments, and literate comments.
			- added R2-BACKWARDS to allow loading Rebol 2 code
			- PRINT? and LOG? are revamped and simpler.
			- 'INDENTED-PRINT/'INDENTED-PRIN now do logging directly, no need to call function twice.
			- 'INDENTED-PRINT/'INDENTED-PRIN  no longer handle indenting in/out use 'PUSH-IN/'PULL-OUT
			- VIN/VOUT now call PUSH-IN and PULL-OUT directly.
			- simplified engine so logging and console now use all the same params and indents.
			  logging just puts the same traces as in the console on disk.
			  experience shows that we never want different setups. 
			  we usually either trace in console OR on disk, rarely both at the same time.
			- replaced 'VTAGS-CTRL() by 'FILTER-TAGS() a simpler mechanism
			- rebuilt von/voff/vlog-on/vlog-off using new simpler filter tags system
			- added /on to vlog to enable logging in one call.
			
			
		v2.0.1 - 2019-03-13
			- now uses a catalog system which speeds up load-time.
			  when a file catalog exists, we use it directly and actual file info.
			
			
	}
	;-  \ history

	;-  / documentation
	documentation: {        Documentation can be found here:
		https://github.com/moliad/slim-libs/wiki
	}
	;-  \ documentation
]



;-----------------------------------------------------------------------------------------------------------
;
;- slim-header
;
;-----------------------------------------------------------------------------------------------------------
either any [
	none? system/script/parent
	none? system/script/header
][
	;---
	; full sub-script hierarchy is not yet enabled...
	;
	; find and load ourself.
	;---
	script: read %slim.red
	script: find/case/tail script "Red"
	slim-header: construct load/next script 'script
	script: none ;erase script from RAM
][
	slim-header: system/script/header
]
??  slim-header
;print "!!!!!!!!!!!!"

;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- SLIM-DEBUGGER
;
;-----------------------------------------------------------------------------------------------------------
; we create the debugger context, allowing us to use it or not, without scripts crashing even if 
; we aren't debugging.
;--------------------------
slim-debugger: context [
	;--------------------------
	;
	;-     PROFILER
	;
	;--------------------------
	profiler: context [
		funcl-timing: make hash! []
		
		;--------------------------
		;-         reset-timing()
		;--------------------------
		; purpose:  reset all accumulated timing information in funcl-timing block
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
		reset-timing: func [
			/local blk
		][
			blk: funcl-timing
			until [
				change next blk  [ 10:00:00    0:00:00    0 ]
				blk: skip blk 4
				tail? blk
			]
			blk: none
		]
		
		
		
		;--------------------------
		;-         stats()
		;--------------------------
		stats: func [
			/limit count "Limits the display to the top (or least) count things, in each category."
			/reset
			/local blk tmp
		][
		
			if reset [
				reset-timing
				return
			]
		
			print "====================="
			print " SLIM DEBUGGER STATS "
			print "====================="
			print ["funcl count: " to-integer ( (length? slim-debugger/profiler/funcl-timing) / 4) ]
			print ""
			print "+------------------------------+"
			print "|  Profiler results - fastest  |"
			print "+------------------------------+"
			probe new-line/skip ( 
				tmp: sort/skip/compare ( blk: to-block slim-debugger/profiler/funcl-timing ) 4 2 
				if limit [
					tmp: copy/part tmp (count * 4)
				]
				tmp
			) true 4
			
			print ""
			print "+------------------------------+"
			print "|  Profiler results - slowest  |"
			print "+------------------------------+"
			probe new-line/skip (
				tmp: sort/skip/reverse/compare ( blk ) 4 3 
				if limit [
					tmp: copy/part tmp (count * 4)
				]
				tmp
			) true 4
			
			print ""
			print "+------------------------------+"
			print "|   Profiler results - usage   |"
			print "+------------------------------+"
			probe new-line/skip (
				tmp: sort/skip/reverse/compare ( blk ) 4 4 
				if limit [
					tmp: copy/part tmp (count * 4)
				]
				tmp
			) true 4
			
			blk: tmp: none
		]
	]
]






;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- GLOBAL CONTEXT FUNCTIONS
;
;-----------------------------------------------------------------------------------------------------------
;--------------------------
;-     funcl()
;--------------------------
funcl: :function

;--------------------------
;-     zpad()
;--------------------------
; purpose:  left fills a value with 0, allows any input
;
; returns:  string!
;
; notes:    does not truncate if value is larger than length.
;
; to do:    tests
;
; tests:    
;--------------------------
zpad: funcl [
	value
	length [integer!]
][
	value: form value
	pad/left/with value length #"0"
]

;--------------------------
;-     as-tuple()
;--------------------------
; purpose:  convert some obvious types to tuple!
;
; inputs:   
;
; returns:  
;
; notes:    we do no sanity checks on input to prove if the value is within range of tuple (0-256) or a valid string
;
; to do:    
;
; tests:    
;--------------------------
as-tuple: funcl [
	val [integer! float! string! tuple!]
][
	vin "as-tuple()"
	tuple: switch type?/word val [
		integer! [
			make tuple reduce [ val 0 0 ]
		]
		float! [
			make tuple! reduce [
				to-integer val
				to-integer next next to-string (modulo val 1.0)  
				0
			]
		]
		tuple! [
			val
		]
		string! [
			to-tuple string!
		]
	]
	vout
	tuple
]


;--------------------
;-     merge()
;
; note:  - we manage the data in-place
;        - copy if you want to preserve container as a spec
;--------------------
at*: :at
skip*: :skip
merge: function [
	container [series!] "series to insert into" 
	data "data to insert within, single value or series, a single value will be repeated as needed to reach end of container."
	/between "Do not add item at end, only in-between container items."
	/zero "insert data before first element of container"
	/skip step [integer!] "skip container records when merging" 
	/every n [integer!]   "view the data as fixed-sized records, first being always inserted. (ex: 2= 1 3 5 7)"
	/amount a [integer!]  "insert this many elements from data at a time, if every is specified, this amount cannot be larger than it."
	/at ata [integer! none!] "start merge at this offset within container, use none value to follow skip size"
	/only "treat series data as single values (repeating the series in container till the end).  Note that data is not copied."
	;/local repeat
][
	; usefull copy to end use of merge
	if any [
		not series? data
		only
	][data: head insert/only tail copy [] data repeat: true]
	
	either skip [step: step + 1][step: 1]
	unless every [n: 1]
	unless amount [a: 1]
	unless zero [container: at* container 2]
	if at [
		if none? ata [ata: step]
		container: skip* container ata
	]
	
	; change amount functionality based on if every is specified.
	if every [
		either n >= a [n: n - a + 1][to-error "merge: amount cannot be larger than every"]
	]
	
	until [
		loop a [
			unless any [
				tail? data
				all [
					between 
					tail? at* container step
				]
			][
				container: insert/only container first data
				unless repeat [
					data: at* data 2 ; skip to next item in data
				]
			]
		]
		
		;stop merging past container
		if tail? container [
			data: tail data
		]

		container: at* container step + 1
		unless repeat [
			data: at* data n
		]

		any [
			tail? data
			all [
				between 
				tail? at* container step
			]
		]
	]
	first reduce [ head container container: none data: none ]
]


;--------------------------
;-     extract-set-words()
;--------------------------
; purpose:  finds set-words within a block of code, hierarchically if required.
;
; inputs:   block!
;
; returns:  the list of words in set or normal word notation
;
; notes:    none-transparent
;
; tests:    [  
;				probe extract-set-words/only [ t: rr x: 5]  
;			]
;--------------------------
extract-set-words: func [
	blk [block! none!]
	/only "returns values as set-words, not ordinary words.  Useful for creating object specs."
	/ignore iblk [block!] "don't extract these words."
	/deep "find set-words in sub-blocks too"
	/local words rule word =rule= =deep-rules=
][
	;vin "extract-set-words()"
	words: make block! 12
	iblk: any [iblk []]
	=deep-rule=: [skip]
	
	=rule=: [
		any [
			set word set-word! (
				unless find iblk to-word :word [
					append words either only [ word ][to-word word]
				]
			)
			| hash! 
			| list!
			| =deep-rule=
			| skip
		]
	]
	
	if deep [
		=deep-rule=: [ into =rule= ]
	]
	
	parse blk =rule= 
	
	;vprobe words
	;vout
	words
]


;--------------------------
;-     enum()
;--------------------------
; purpose:  make an enumerated value context for use with external libraries
;
; inputs:   a prefix to use on each word (added as a alternate spelling of the value)
;           an enum dialect where you can set values directly, or just add words, which are then 
;           auto-incremented by adding 1 to the previous "current" value.
;
;           use the /flags refinement to build binary flag sets (using the enum-flags function below)
;
; returns:  a context with numeric values in given words.
;
; notes:    - you can use option '=  word to make your enums similar to C code.
;           - you can use set-words or normal words.
;           - we use underscore rather than dash to separate prefix, because we follow the C token semantics
;
; tests:    
;--------------------------
enum-ctx: context [
	bit: func [
		offset [integer!]
	][
		; we use 1 based index (so you use bits 1 - 32,  as opposed to 0 - 31)
		offset: offset - 1
		shift/left 1 offset
	]
	value: -1
]

enum: funcl [
	[catch]
	prefix    [word!]  "what is the prefix for this enum"
	enum-list [block!] "enumeration dialect: [each word is equal to previous word +1  OR  following integer, if any."
	/flags "Use alternate flag mode flag-enum() function."
][

	(if flags ([
		return flag-enum prefix enum-list
	]))

	ctx-spec: copy []
	value: -1
	
	prefix: append to-string prefix "_"
	
	;=eq-word=: to-word "="
	parse enum-list [
		some [
			[
				[
					[
						;----
						; field name
						[
							set word set-word!
							
							| [
								set word word! 
								'=
							]
						]

						;----
						; value
						copy enum-val [
							integer!
							| paren!
							| 'bit [ paren! | integer! ]
							| [
								;----
								; manual setup 
								[
									word! 
									any [
										[ 'OR  |  '| ]
										word! 
									]
								]
							]
						]
						( 
							replace/all enum-val '| 'OR 
							;?? enum-val
							;----
							; evaluate the extracted value so we can auto-increment it later.
							;bind value enum-ctx
							
							;?? enum-val
							enum-val: head insert enum-val [value: ]
							
							enum-val: to-paren enum-val
							;probe :enum-val
							enum-val: append/only copy [] :enum-val
							;?? :enum-val
						)
					]
					| [
						set word word!  (
							enum-val: [(value: value + 1)]
						)
					]
				]
				(
					append ctx-spec to-set-word word
					;?? enum-val
					append ctx-spec enum-val
					
					;append ctx-spec to-set-word join prefix to-string word <SMC> To Red
					append ctx-spec to-set-word rejoin [prefix to-string word]
					append ctx-spec [value]
				)
			]
			
			| skip (
				throw make error! compose [ user message "invalid enum spec" ]
				;throw to-error "invalid enum spec"
			)
		]
	]
	
	bind ctx-spec enum-ctx
	enum-ctx/value: -1
	
	;?? enum-list
	;?? ctx-spec
	
	;print "=============================================="
	ctx: context ctx-spec
	;print "=============================================="
	;probe ctx
	
	ctx-spec: none
	value: none
	ctx
]


;--------------------------
;-     flag-enum()
;--------------------------
; purpose:  generates 
;
; inputs:   
;
; returns:  
;
; notes:    Using set-words expects you to supply words to assign as list of flags to merge.
;
; to do:    
;
; tests:    
;--------------------------
flag-enum: funcl [
	[catch]
	prefix    [word!]  "what is the prefix for this enum"
	enum-list [block!] "enumeration dialect: [each word is equal to previous word +1  OR  following integer, if any."
][
;	vin "flag-enum()"
	
	ctx-spec: copy []
	current-value: 1
	prefix: append to-string prefix "_"
	.mrg-block.:  .word.:  .hex-str.:  none
	current-bit: 0
	
	parse enum-list [
		some [
			[
				[
					[
						;----
						; label
						[
							  [ set .word.  set-word! ]
							| [ set .word.  word!  '=    ]
						]
						( .word.: to-set-word .word. )
;						( vprobe .word.)
						
						;----
						; operation
						[
							[
								;----
								; manual setup 
								copy .mrg-block.  [
									word! 
									any [
										[ 'OR  |  '| ]
										word! 
									]
								]
								( replace/all .mrg-block. '| 'OR )
								(current-value: .mrg-block.)
;								( vprint "found manual operation")
;								( vprobe .mrg-block.)
							]
							
							| [
								;----
								; assign bit number
								set current-value integer! 
;								( vprint ["found bit number: " current-value]	)
								(
									current-bit:   current-value + 1
									current-value: to-integer power 2 current-value
								)
;								( v?? current-value )
							]
							
							|  [
								;----
								; assign hex value
								set .hex-str. issue!
;								( vprint ["found HEX value: " current-value]	)
								( current-value: to-integer load rejoin [ "#{"  ( to-string .hex-str. ) "}" ]  )
;								(  v?? current-value )
							]						
						]				
					]
					| [
						set .word. word!  (
							current-value: to-integer power 2 current-bit
							current-bit: current-bit + 1
						)
						(.word.: to-set-word .word. )
;						( vprobe .word. )
;						(  v?? current-value )
					]
				]
				(
					append ctx-spec reduce [  .word. ] 
					append ctx-spec current-value 
					
					;append ctx-spec reduce [ to-set-word join prefix to-string .word. ] <SMC> To Red
					append ctx-spec reduce [ to-set-word rejoin [prefix to-string .word.] ] 
					append ctx-spec current-value 
				)
			]
;			(vprint "")
			| skip (
				throw make error! compose [ user message "invalid enum spec" ]
			)
		]
	]
	
;	v?? ctx-spec
	
	ctx: context ctx-spec
	ctx-spec: none
	current-value: none
;	vout
	
	ctx
]

	
;--------------------------
;-     platform-name()
;--------------------------
; purpose:  returns the name of the platform this rebol was compiled for
;
; returns:  word! or none if platform is unknown
;
; notes:    
;
; tests:    
;   switch platform-name  [
;       OSX []
;
;       WIN32 []    
;
;       LINUX []
;   ]
;--------------------------
;platform-name: does [
;	select [
;		1 AMIGA
;		2 OSX
;		3 WIN32
;		4 LINUX ; (32 bits)
;	] system/version/4 
;]

platform-name: does [
	select [
		'Windows	WIN32
		;'Syllable
		'MacOS		OSX
		'Linux		LINUX
	] system/platform
]





;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- REBOL 2 GLOBAL CTX MEZZANINES
;
;-----------------------------------------------------------------------------------------------------------

;--------------------------
;-     join()
;--------------------------
unless value? 'join [
	; return a COPY of path + filename
	;----
	join: func [
	    "Concatenates values."
	    value "Base value"
	    rest "Value or block of values"
	][
	    value: either series? :value [copy value][form :value]
	    repend value :rest
	]
]

;--------------------------
;-     to-error()
;--------------------------
unless value? 'to-error [
	to-error: func [
		msg [string! block!]
	][
		make error! msg
	]
]

;--------------------------
;-     disarm()
;--------------------------
unless value? 'disarm [
	disarm: func [e [error!]][
		context [
		    code:  e/code
		    type:  e/type
		    id:    e/id
		    arg1:  e/arg1
		    arg2:  e/arg2
		    arg3:  e/arg3
		    near:  e/near
		    where: e/where
		    stack: e/stack
		]
	]
]

;--------------------------
;-     dt()
;--------------------------
unless value? 'dt [
	dt: funcl [
	    {Delta-time - returns the time it takes to evaluate the block.}
	    block [block!] 
	][
	    start: now/precise
	    do block
	    difference now/precise start
	]
]

;--------------------------
;-     true?()
;--------------------------
unless value? 'true? [
	true?: func [
	    "Returns true/false if an expression can be used as a truthy value in conditional."
	    val
	][not not :val]
]



;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- SYSTEM-WIDE GLOBALS
;
;-----------------------------------------------------------------------------------------------------------

;--------------------------
;-     R3?:
;--------------------------
R3?: true? in system 'contexts

;--------------------------
;-     RED?:
;--------------------------
RED?: true? in system 'reactivity

;--------------------------
;-     R2?:
;--------------------------
R2?: not any [R3? RED?]



;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- R2-BACKWARDS
;
;-----------------------------------------------------------------------------------------------------------
r2-backwards-ctx: context [
	;--------------------------
	;-     true?()
	;
	;--------------------------
	true?: function [val][not not :val]

	;--------------------------
	;-     parse()
	;
	;--------------------------
	parse: funcl [
		input	[binary! any-block! any-string!]
		rules	[block! string!]
		/case	"Uses case-sensitive comparison"
		/part	length		[number! series!] "Limit to a length or position"
		/trace	callback	[function!]
		/all	"In Red, parse/all = parse => ignore refinement"
	][
		val: case [
			all [string? rules ]	[split input rules ]
			all [ case part trace ]	[parse/case/part/trace input rules length callback ]
			all [ case part ]		[parse/case/part input rules length ]
			all [ case trace ]		[parse/case/trace input rules callback ]
			all [ trace part ]		[parse/part/trace input rules length callback ]
			all [ part ]			[parse/part input rules length ]
			all [ trace ]			[parse/trace input rules callback ]
			all [ case ]			[parse/case input rules ]
			
			; no refinements!
			parse input rules
		]
		val
	]

	;--------------------------
	;-     remove-each()
	;
	;--------------------------
	remove-each: funcl [
		'word	[word! block!]	"Word or block of words to set each time."
		data	[series!]		"The series to traverse (modified)."
		body	[block!]		"Block to evaluate (return TRUE to remove)."
	][
	
		;print ">>"
		remove-each word data body
		;print "<<"
		data
	]

	;--------------------------
	;-     funct()
	;
	;--------------------------
	funct: :function ; <TODO>
]


;-                                                                                                         .
;-----------------------------------------------------------------------------------------------------------
;
;- ALIASES
;
; use these to allow slim modules to use core words without preventing their overwrite within a slim lib.
;-----------------------------------------------------------------------------------------------------------

;--------------------------
;-     get*:
;--------------------------
get*: :get

; should not be needed, as we do not use open directly
;if value? 'open [
;	open*: :open
;]




;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- SLIM CONTEXT
;
;-----------------------------------------------------------------------------------------------------------
SLiM: context [
	;--------------------------
	;-     linked-slim-version:
	;
	; when slim-linked, this is the version of the original slim library used.
	;
	; this on only used by slink, NEVER set this value.
	;--------------------------
	linked-slim-version: none
	
	;--------------------------
	;-     path:
	;
	; v1.2.2 declared, so that the 'PATH word remains local to slim.
	;--------------------------
	path: none 

	;--------------------------
	;-     default-lib-extensions:
	;
	; setup the expected library extension for use by the current setup.
	;
	; each extension also has a file type after it which handles 3 different 
	; aspects of the library:
	;   - Expected construct Keyword (Red, Slim or REBOL)
	;   - encoding (Windows-1252 or utf-8)
	;   - Rebol dialect: Rebol2 or Red
	;--------------------------
	default-lib-extensions: [
		".slred"	Slim	; Slim, 	utf-8,			Native Red
		".red" 		Red		; Red,		utf-8,			Native Red
		".slr2" 	slr2	; Slr2,		utf-8,			Red with Rebol2 backwards binding
		".r"		rebol	; Rebol,	Windows-1252,	Native Rebol2
	]
	
	;--------------------------
	;-     library-index:
	;
	; in-memory version of all accumulated package catalogues.
	;
	; will also usually include a run-time generated index of packages
	; without an explicit catalogue file (like the applicatio/libs/ path).
	;--------------------------
	library-index: none
	
	;--------------------------
	;-     application-path:
	;
	; this is a special value which is modified later, when the application
	; opens a library, this value (which is late set to a function) will
	; store a static reference to the application's working directory.
	;--------------------------
	application-path: none
	
	;--------------------------
	;-     slim-path:
	;
	;  path of the slim manager itself (directory up to %slim.r)
	;--------------------------
	slim-path-parts: split (clean-path what-dir) #"/" 
	if empty? last slim-path-parts [ 
		take/last slim-path-parts
	]
	slim-path: to-file merge/only (copy slim-path-parts) "/"
	?? slim-path
		
	;--------------------------
	;-     slim-package-root:
	;
	; we assume libs will never been in the Root of a disk
	; 
	; we expect slim.r to be within a directory called /slim-libs/
	;--------------------------
	if %slim = last slim-path-parts [
		take/last slim-path-parts 
		slim-package-root: to-file merge/only (copy slim-path-parts) "/"
	]
	
	;--------------------------
	;-     slim-packages:
	;
	; list of sub directories installed in the root of slim libs.
	;
	; these are only discovered at slim load time.
	;
	; path discovery is *not* re-attempted later.
	;--------------------------
	slim-packages: read slim-package-root
	remove-each path slim-packages [
		#"/" <> last path
	]
	until [
		if path: pick slim-packages 1 [
			;change slim-packages join slim-package-root path <SMC> To Red
			change slim-packages rejoin [slim-package-root path]
		]
		empty? slim-packages: next slim-packages
	]
	slim-packages: head slim-packages
	new-line/all slim-packages true
	
	?? slim-packages
	?? slim-package-root
	
	;--------------------------
	;-     libs:
	;
	; each time a library is opened, its name version and object pointer get dumped here.
	; this allows us to share the same object for all calls
	;
	; changes:
	;     v2.0.0 - converted to hash! to improve lookup speed
	;            - format now supports multiple lib versions in memory. e.g. [ libname [version1 lib-ctx1   version2 lib-ctx2 ... ] ... ]
	;            - lib versions are stored highest to lowest so we always find the highest matching lib possible.
	;--------------------------
	libs: make hash! []

	;--------------------------
	;-     paths:
	;
	; a list of paths which describe where you place your libs
	; the last spec is the cache dir (so if you have only one dir,
	; then its both a library path and cache path.)
	;--------------------------
	paths: []

	;--------------------------
	;-     linked-libs:
	;
	; if this is set to false, then all open calls use the paths dir and use find-path and do.
	; otherwise it will only do libs directly from the link-cache variable instead.
	;
	; catalogue will have to reflect the value of linked libs, and may still allow 
	; run-time linking for things like plugins.
	;
	; <TODO> support run-time link even if statically linked.
	;--------------------------
	linked-libs: none

	;--------------------------
	;-     open-version:
	;
	; use this to store the version of currently opening module. is used by validate, afterwards.
	;--------------------------
	open-version: 0.0.0     

	;--------------------------
	;-     opening-lib-name:
	;
	; we try to store the library name which is attempting to load...
	;
	; the goal is to be able to re-use it within SLIM-ERROR()
	;--------------------------
	opening-lib-name: none

	;--------------------------
	;-     quiet?:
	;
	; do we raise slim loading/creation errors, or simply ignore them?
	;--------------------------
	quiet?: false
	
	;--------------------------
	;-     manager-version:
	;
	; sets the slim version for use by the run time.
	;
	; it will switch between the linked or run-time value, based on startup.
	;--------------------------
	manager-version: any [ linked-slim-version  slim-header/version]
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     VERBOSITY CONTROL
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     verbose?:
	;
	;--------------------------
	verbose?:    false   ; display console messages
	
	;--------------------------
	;-     vlogging?:
	;
	;--------------------------
	vlogging?:  false   ; display messages in log file.
	
	;--------------------------
	;-     vtabs:
	; stores the indent text 
	;--------------------------
	vtabs: []
	
	;--------------------------
	;-     vtags:
	;
	; when set to a block with some tags, will only allow traces which are tagged within code.
	; when empty, all traces are allowed.
	; 
	; this allows you to select specific functions or groups of functions even within
	; a library, to trace rather than the whole library or application code.
	;
	; note that tags are global and are set for ALL uses of vprint. you cannot just set some tags 
	; localy for a single lib... yet.
	;
	; <TODO>  support lib-local vtags to refine per library traces.
	;--------------------------
	vtags: #[none]          
	
	;--------------------------
	;-     ntags:
	;
	; this is the complement to vtags, which PREVENT a trace when matched.
	; 
	; everything that applies to vtags also applies to ntags, with the exception of previous line.
	;
	; note that if both ntags AND vtags are setup, they are both considered, 
	; so a trace will have to pass both tests.
	;
	; <TODO>  support lib-local vtags to refine per library traces.
	;--------------------------
	ntags: #[none]          

	;--------------------------
	;-     vconsole:
	; when set, the CONSOLE traces are put in this list instead of printed out in the console.
	; this MUCH faster, but also adds the burden of asynchronicity, so your code and its traces
	; become disconnected, which may not be acceptible.
	;
	; one advantage is that you can easily probe and search the block after for some 
	; run-time inspection (things like IDE might like this).
	;--------------------------
	vconsole: none          
	
	;--------------------------
	;-     vlogfile:
	; when set to a filename, we can store traces to disk.
	;
	; we must still activate logging via vlog-on.
	;
	; logs are subject to the same tags and ntagdl
	;--------------------------
	vlogfile: none
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- VPRINT FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     qualify-tags()
	;--------------------------
	; purpose:  makes sure given tags comply to given template.
	;
	; returns:  true or false
	;
	; tests:    
	;		test-group  [ slim  ]
	;			[ slim/qualify-tags none none ]
	;			[ slim/qualify-tags none  [ n ] ]
	;			[ slim/qualify-tags [ n ] [ n ] ]
	;			[ slim/qualify-tags [ n n2 ] [ n ] ]
	;			[ slim/qualify-tags [ n n2 ] [ n2 ] ]
	;			[ slim/qualify-tags [ n n2 ] [ n n2 ] ]
	;			[ slim/qualify-tags [ n n2 ] [ i n2 ] ]
	;			[ false = slim/qualify-tags [ n ] [ i ] ]
	;			[ false = slim/qualify-tags [ n n2] [ i ] ]
	;			[ false = slim/qualify-tags [ n ] none ]
	;			[ false = slim/qualify-tags [ n n2] none ]
	;		end-group
	;
	;		test #305 [ slim/qualify-tags 'n [ i ] ]
	;		test #305 [ slim/qualify-tags [ n ] 'i  ]
	;
	;--------------------------
	qualify-tags: funcl [
		"return true if the specified tags match an expected template"
		template [block! none!] "when none! tags are not verified, all is good."
		tags     [block! none!] "if none! and there is a template, we always return false"
	][
		print "^/qualify-tags()"
		?? template
		probe type? template
		probe not block? template
		
		rval: any [
			not block? template ; given filter isn't active
			all [
				; at this point we know template is a block
				block? tags
				not empty? intersect template tags
			]
		]
		?? rval
		
		rval
	]

	;--------------------------
	;-     print?()
	;--------------------------
	; purpose:  detects if the print should occur based on setup and tags
	;
	; inputs:   tags may be ignored (we show all) if the library hasn't setup tags to match.
	;
	; returns:  true or false
	;
	; tests:    
	;--------------------------
	print?: func [
		always [logic! none!]
		tags [block! none!] "A block of tags to compare to currently active ones.  None for all tags."
	][
		print "^/print?()"
		?? tags
		?? always
		?? vtags
		?? ntags
		?? verbose?
		
		any [
			always
			all [
				verbose?
				any [
					not ntags
					not qualify-tags ntags tags
				]
				qualify-tags vtags tags
			]
		]
	]
	
	;--------------------------
	;-     log?()
	;--------------------------
	; purpose:  decide if we should write to log or not
	;
	; inputs:   tags may be ignored (we show all) if the library hasn't setup tags to match.
	;
	; returns:  true or false
	;
	; tests:    
	;--------------------------
	log?: func [
		always
		tags [block! none!] "A block of tags to compare to currently active ones."
	][
		all [
			file? vlogfile
			any [
				always
				all [
					vlogging?
					not qualify-tags ntags tags
					    qualify-tags vtags tags
				]
			]
		]
	]

	;--------------------------
	;-     filter-tags()
	;--------------------------
	; purpose:  Setup the tag filters, 
	;
	; inputs:   
	;
	; returns:  unset!
	;
	; notes:    - can be called directly to manipulate them run-time (no need to use 'VON/'VOFF)
	;           - this function can be called twice and it will allow both positive (on) and negative (off)
	;             taga. the algorithm is then to apply both filters, using the most restrictive of 
	;             both rules (like an AND operation).
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	filter-vtags: funcl [
		tags [block! none!]
		/on
		/off
		/only "do not modify the opposite filter (e.g. with /on, do not erase the negative tags and vice-versa)."
		
		/extern ntags vtags
	][
		vin "filter-tags()"
		;---
		; make sure refinements are not invalid
		unless any [on off][
			to-error "slim/filter-tags() requires one of /ON or /OFF to be set"
		]
		if all [on off][
			to-error "slim/filter-tags() Can only use one of /ON or /OFF at a time."
		]
		
		case [
			on [
				; adjust positive tags
				vtags: unique union vtags tags
				unless only [
					ntags: none!
				]
			]
			
			off [
				; adjuts negative tags
				ntags: unique union vtags tags
				unless only [
					vtags: none!
				]
			]
		]
		vout
	]

	;--------------------------
	;-     push-in()
	;--------------------------
	; purpose:  adds indentation to following prints & logs
	;--------------------------
	push-in: funcl [][
		insert vtabs "    "
	]
	
	;--------------------------
	;-     pull-out()
	;--------------------------
	; purpose:  removes indentation to following prints & logs
	;--------------------------
	pull-out: funcl [][
		remove vtabs
	]

	;--------------------------
	;-     data-to-vstring()
	;--------------------------
	; purpose:  the standard function which converts any data to what vprint will dump.
	;
	; inputs:   any normal data (not unset! or error!)
	;
	; returns:  string!
	;
	; notes:    logic and none values are molded to reduce mis-interpretation
	;
	; to do:    add some tests 
	;
	; tests:    
	;--------------------------
	data-to-vstring: funcl [
		data
	][
		switch/default (type?/word :data) [
			object! [mold first data]
			block! [rejoin data]
			string! char! tag! [data]
			none! logic! [mold/all data]
		][	
			mold reduce data
		]
	]


	;--------------------------
	;-     indented-print()
	;--------------------------
	; purpose:  low-level line-printing function used by all others
	;
	; returns:  unset!
	;
	; notes:    - prints to console (if enabled) AND writes to log (if enabled)
	;           - logs prefix data/time at head of line before their traces
	;
	; tests:    
	;--------------------------
	indented-print: funcl [
		data "something to output to console or log file."
		always [logic! none!] "always print, ignores tags and verbose? setup.  still indents as usual"
		tags   [block! none!] "set of tags to compare with global vtags setup. still requires verbose to be on."
	][
		tabs: rejoin vtabs
		?? tabs
		
		datetime: rejoin ["" now/year "-" zpad now/month 2 "-"  zpad now/day 2 " " pad/with now/time/precise 12 #"0"  " - "]
		?? datetime
		
		line: rejoin [ datetime tabs data-to-vstring data ]
		line: replace/all line "^/" rejoin [ "^/" datetime tabs ]
		?? line
		
		if log? always tags [
			write/append vlogfile rejoin [line "^/"] ; we must add the trailing new-line
		]
		
		?: print? always tags
		?? ?
		
		if print? always tags [
			either vconsole [
				append/only vconsole rejoin [line "^/"]
			][
				print line
			]
		]
	]
	
	;--------------------------
	;-     indented-prin()
	;--------------------------
	; purpose:  low-level printing function used by all others
	;
	; returns:  unset!
	;
	; notes:    - prints to console (if enabled) AND writes to log (if enabled)
	;           - DOES NOT CAUSE NEWLINE, NOR DOES IT PRINT INDENTS!
	;
	; tests:    
	;--------------------------
	indented-prin: funcl [
		data
		always [logic! none!] "always print, ignores tags and verbose? setup.  still indents as usual"
		tags   [block! none!]   "set of tags to compare with global vtags setup."
	][
		line: rejoin ["" data-to-vstring data]
		line: replace/all line "^/" rejoin [ "^/" rejoin vtabs ]
		if log? always tags [
			write/append vlogfile line  ; this can be weird in a log file... careful
		]
		if print? always tags [
			either vconsole [
				append/only vconsole line 
			][
				prin line
			]
		]
	]
	
	;--------------------------
	;-     vreset()
	;--------------------------
	; purpose:  reset the indentation so we are again at root of console.
	;
	; notes:    useful when we recover from some errors.
	;--------------------------
	vreset: funcl [
		/extern vtabs
	][
		vtabs: copy []
	]
	
	;--------------------------
	;-     vlog()
	;--------------------------
	; purpose:  set the log file to use 
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    - the same file is used for ALL libraries (it is a slim function).
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	vlog: funcl [
		filepath [file!] "filepath of log.  Must be a File, e.g. path must not end with /"
		/on "Also enable logging right now (calls 'VLOG-ON)."
		/extern vlogfile
	][
		either dir? filepath [
			to-error "slim/vlog() invalid path given, requires a FILE path"
		][
			;vlogging?: true
			vlogfile: filepath
		]
	]

	;--------------------------
	;-     von()
	;--------------------------
	; purpose:  Enable vprinting
	;
	; inputs:   /tags also allows you to change tags in a single call.
	;
	; returns:  
	;
	; notes:    - if tags is not given, we leave them alone (so we keep memory of last tags)
	;           - if tags are given, the negative tags are cleared.
	;           - if there are negative tags setup and /tags is not used, then they still apply.
	;--------------------------
	von: funcl [
		/tags filter-tags [block! none!] "Given tags must be specified for display to occur. none! will reset the complete tag setup for positive tags."
		/only "do not manipulate negative filter"
		/extern verbose?
	][
		verbose?: on
		if tags [
			either only [
				filter-vtags/on/only ignore-tags
			][
				filter-vtags/on ignore-tags
			]
		]
	]
	
	;--------------------------
	;-     voff()
	;--------------------------
	; purpose:  stop tracing in console, or set negative tags which, when matched will be ignored.
	;
	; inputs:   when tags are none, we totally reset the negative tags.
	;
	; returns:  
	;
	; notes:    -if there are currently negative tags and we do not call /tags, they stay in setup.
	;            and this only stops ALL verbose
	;--------------------------
	voff: func [
		/tags ignore-tags [block! none!] "will specifically ignore these tags.  Trace all the rest"
		/only "do not manipulate positive filter"
		/extern verbose?
	][
		either tags [
			verbose?: on
			either only [
				filter-vtags/off/only ignore-tags
			][
				filter-vtags/off ignore-tags
			]
		][
			verbose?: off
		]
	]



	;--------------------------
	;-     vlog-off()
	;--------------------------
	; purpose:  SAME AS VOFF but for disk logging.  
	;
	; returns:  unset!
	;
	; notes:    voff and vlog share the same vtags setup.
	;
	; to do:    tests
	;
	; tests:    
	;--------------------------
	vlog-off: func [
		/tags ignore-tags [block! none!] "will specifically ignore these tags.  Trace all the rest"
		/only "do not manipulate positive filter"
		/extern vlogging?
	][
		either tags [
			vlogging?: on
			either only [
				filter-vtags/off/only ignore-tags
			][
				filter-vtags/off ignore-tags
			]
		][
			vlogging?: off
		]
		exit
	]
	
	
	;--------------------------
	;-     vlog-on()
	;--------------------------
	; purpose:  SAME AS VON but for disk logging.  
	;
	; notes:    von and vlog share the same vtags setup.
	;
	; returns:  unset!
	;
	; to do:    <todo> tests
	;
	; tests:    
	;--------------------------
	vlog-on: funcl [
		/tags filter-tags [block! none!] "Given tags must be specified for display to occur. none! will reset the complete tag setup for positive tags."
		/only "do not manipulate negative filter"
		/extern vlogging?
	][
		vlogging?: on
		if tags [
			either only [
				filter-vtags/on/only ignore-tags
			][
				filter-vtags/on ignore-tags
			]
		]
		exit
	]

	;----------------
	;-    vindent()
	; simply prins the leading indents 
	;----
	vindent: func [
		/always
		/tags ftags
	][
		if print? always ftags [
			prin vtabs
		]
		if log? always ftags [
			indented-prin/log to-string ltabs in out
		]
	]
	
	;--------------------------
	;-     vin()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    allow "sticky" tags, which modify the tags setup until the next balanced call to vout.
	;
	; tests:    
	;--------------------------
	vin: func [
		txt
		/always
		/tags taglist [block!]
	][
		indented-print rejoin [txt " ["] always taglist
		push-in
	]
	
	;----------------
	;-    vout()
	;----
	vout: func [
		/always
		/tags ftags
		/return rdata ; use the supplied data as our return data, allows vout to be placed at end of a 
					  ; function and print itself outside inner content event if return value is a function.
	][
		if print? always ftags [
			indented-print "]" no yes
		]
		
		if log? always ftags [
			indented-print/log "]" no yes
		]
		
		; this mimics print's functionality where not supplying return value will return unset!, causing an error in a func which expects a return value.
		either return [
			rdata
		][] ; generates an unset! value (a faster way to do an 'EXIT).
	]
	
	;----------------
	;-    vprint()
	;----
	vprint: func [
		"verbose print"
		data
		/in "indents after printing"
		/out "un indents before printing. Use none so that nothing is printed"
		/always "always print, even if verbose is off"
		/tags ftags "only effective if one of the specified tags exist in vtags"
	][
		;print ["--------------->" data]
		if print? always ftags [
			indented-print data in out
		]
		if log? always ftags [
			indented-print/log data in out
		]
	]
	
	
	;----------------
	;-    vprin()
	;----
	vprin: func [
		"verbose print"
		data
		/in "causes indentation but doesn't prefix the print with the tabs"
		/always "always print, even if verbose is off"
		/tags ftags "only effective if one of the specified tags exist in vtags"
	][
		either in [
			if print? always ftags [
				;probe rejoin ["=================>" data]
				indented-prin/in data
			]
			if log? always ftags [
				indented-prin/log/in data
			]
		][
			if print? always ftags [
				;probe rejoin ["=================>" data]
				indented-prin data
			]
			if log? always ftags [
				indented-prin/log data
			]
		]
	]
	
	
	;----------------
	;-    vprobe()
	;----
	vprobe: func [
		"verbose probe"
		data
		/in "indents after probing"
		/out "un indents before probing"
		/always "always print, even if verbose is off"
		/tags ftags "only effective if one of the specified tags exist in vtags"
		/part amount [integer!] "how much object do we want to display, should eventually support block of words"
		/local line molded?
	][
		;probe rejoin [">>>>>>>>>>>>" data]
		unless part [
			amount: 5000
		]
		
		
		if print? always ftags [
			;probe rejoin ["++++++++++>" data]
			switch/default (type?/word :data) [
				object! [
					line: rejoin [ mold first data "^/>>>" copy/part mold/all data amount "<<<"]
				] 
			][
				line: mold/all :data ; serialised values are explicit (better probe precision).
			]
			
			molded?: true
			
			indented-print line in out  ; part of indented-print
		]
				
		if log? always ftags [
		
			unless molded? [
				switch/default (type?/word :data) [
					object! [
						line: rejoin [ mold first data "^/>>>" copy/part mold/all data amount "<<<"]
					] 
				][
					line: mold/all :data ; serialised values are explicit (better probe precision).
				]
			]
		
			;probe rejoin ["++++++++++>" data]
			indented-print/log line in out  ; part of indented-print
		]
				
		:data
	]
	
	
	;----------------
	;-    v??()
	;----
	v??: funcl [
		{Prints a variable name followed by its molded value. (for debugging) - (replaces REBOL mezzanine)}
		'name
		/always "always print, even if verbose is off"
		/tags ftags "only effective if one of the specified tags exist in vtags"
	][
		label: switch/default tp: type?/word :name [
			word! [
				rejoin [ form name ": " any [attempt [mold/all rval: get* :name ]  rejoin [NAME ": !!! unable to mold value... too large or cyclical"]]]
			]
			path! [
				rejoin [ form :name ": " mold/all rval: do :name ]
			]
			block! [
				blk: reduce :name
				rval: last blk
				rejoin [mold/only :name " : "  mold/all/only :blk]
			]
		][
			rejoin [ "" tp " : " mold/all rval: :name ]
		]
			
		if print? always ftags [
			indented-print label false false  ; in out
		]
		if log? always ftags [
			indented-print/log label false false  ; in out
		]
			
		:rval
	]
		
	
	;----------------
	;-    vdump()
	;----
	;
	; 
	;----
	vdump: funcl [
		"prints a block of information about any value (recursive)."
		data [any-type!]
		/always "always dump, ignore verbose flags."
		/ignore ignore-data [word! block! datatype!] "list of attributes or datatypes to ignore"
		
		/threshold tr-len
		/part display-len
		/acc accumulator [hash!] ; we force a hash! since we may do thousands of searches in a long list.
		/no-indent
	][
		; return right away if we shoudn't print.
		unless print? always none [ exit ]
		
		; handle unset values directly.
		if unset? get*/any 'data [vprin "#[unset!]" vprint "" exit]
		
		ignore-data: switch/default type?/word ignore-data [
			word! datatype! block! [ compose [(ignore-data)]]
		][
			clear []
		]
		
		;?? ignore-data 
	
		; uniformitize inputs (allows easy chaining of recursive calls).
		tr-len: any [tr-len 256]  ; what length triggers reduced series output
		display-len: any [display-len 50] ; how much of reduced series do we report
		
		;vindent
		;vprin rejoin ["#[" mold type? :data  "]:   "]
		
		;-----
		; this variable accumulates all blocks and objects, to make sure cyclical references are not followed.
		;
		; when a value is already in the accumulator, we do not traverse it... 
		; instead we write a comment with an ID, so it can be traced.
		;---
		accumulator: any [ accumulator make hash! [] ]
		
		
		
		reference: head accumulator
		until [
			any [
;				all [
;					object? :data ; objects are found by reference already, so it's fast.
;					find reference data
;				]
				not reference: find/only reference :data
				same? first reference :data
				tail? reference: next reference
			]
			
		]
		
		
		either reference [
			vprin [ "#[" type? :data  ":" index? reference  "]" ]
			vprint ""
		][
		
			unless all [
				acc ; do not filter top-most data
				any [
					find ignore-data type?/word :data
					find ignore-data :data
				]
			][ 
				unless no-indent [
					vindent
				]
				switch/default type?/word :data [
					object! [
						append accumulator data
						vprin/in ["#[object:" length? accumulator   "(" length? words-of data ")"  ]
						vprint ""
						foreach item words-of data [
							;vprint "------------------"
							set/any 'data-value get*/any in data item
							if unset? get*/any 'data-value [
								data-value: UNSET! ; simple hack to fix any internals with an unset value.
							]
							unless any [
								find ignore-data type?/word :data-value
								find ignore-data item
							][
								vindent
								vprin rejoin [ uppercase to-string item ": "]
								vdump/acc/ignore/no-indent :data-value  accumulator ignore-data
							]
						]
						vout
					]
					
					string! binary! image! [
						tdata: copy data
						if string? data [tdata: to-binary data]
						if image? data [tdata: mold/all data]
						either (length? data) > tr-len [
							tdata: copy/part tdata display-len
							tdata: head insert back tail tdata rejoin [" ... (length?: " length? data ")"] ; indicate that the series was longer than its printout
							vprin tdata
						][
							vprin mold/all data
						]
						vprint ""
					]
					
					
					datatype! [
						vprin data
						vprint ""
					]
					
					
					block! [
						append/only accumulator data
						vprin/in ["#[block:" length? accumulator "(" length? data ")" ]
						;vprin/in [" [ <block:#" length? accumulator  >" ]
	
						if (length? data) > 50 [
							vprin " (showing first 50 items of block) "
							data: copy/part data 50
						]
						
						vprint ""
						foreach item data [
							vdump/acc/ignore (get*/any 'item) accumulator ignore-data
						]
						vout
					]
					
					function! [
						vprin ["#[function] "]
						vprint ""
					]
					
				][
					vprin mold/all :data
					vprint ""
				]
			]
		]
		unless acc [
			; when the accumulator was not provided manually, we should clear it, or else the whole
			; dataset will be stuck in the GC
			clear accumulator
		]
	
	]
	
	
	;----------------
	;-    vhelp()
	;
	; this is the SAME basic code as the core HELP, but it uses vprinting
	;----
	vhelp: func [
		"Prints information about words and values."
		'word [any-type!]
		/local value args item type-name refmode types attrs rtype
	][
		if unset? get*/any 'word [
			vprint trim/auto {
	^-^-^-To use HELP, supply a word or value as its
	^-^-^-argument:
	^-^-^-
	^-^-^-^-help insert
	^-^-^-^-help system
	^-^-^-^-help system/script
	
	^-^-^-To view all words that match a pattern use a
	^-^-^-string or partial word:
	
	^-^-^-^-help "path"
	^-^-^-^-help to-
	
	^-^-^-To see words with values of a specific datatype:
	
	^-^-^-^-help native!
	^-^-^-^-help datatype!
	
	^-^-^-Word completion:
	
	^-^-^-^-The command line can perform word
	^-^-^-^-completion. Type a few chars and press TAB
	^-^-^-^-to complete the word. If nothing happens,
	^-^-^-^-there may be more than one word that
	^-^-^-^-matches. Press TAB again to see choices.
	
	^-^-^-^-Local filenames can also be completed.
	^-^-^-^-Begin the filename with a %.
	
	^-^-^-Other useful functions:
	
	^-^-^-^-about - see general product info
	^-^-^-^-usage - view program options
	^-^-^-^-license - show terms of user license
	^-^-^-^-source func - view source of a function
	^-^-^-^-upgrade - updates your copy of REBOL
	^-^-^-
	^-^-^-More information: http://www.rebol.com/docs.html
	^-^-}
			exit
		]
		if all [word? :word not value? :word][word: mold :word]
		if any [string? :word all [word? :word datatype? get* :word]][
			types: dump-obj/match system/words :word
			sort types
			if not empty? types [
				vprint ["Found these words:" newline types]
				exit
			]
			vprint ["No information on" word "(word has no value)"]
			exit
		]
		type-name: func [value][
			value: mold type? :value
			clear back tail value
			;join either find "aeiou" first value ["an "] ["a "] value <SMC> To Red
			rejoin [either find "aeiou" first value ["an "]["a "] value]
		]
		if not any [word? :word path? :word][
			vprint [mold :word "is" type-name :word]
			exit
		]
		value: either path? :word [first reduce reduce [word]] [get* :word]
		switch/default type?/word :word [
			object! block! binary! [
				vdump :word
			]
			
			; these continue to next steps
			function! native! action! []
			
		][
			vprint mold/all :word
			exit
		]
	;    if not any-function? :value [
	;        vprin [uppercase mold word "is" type-name :value "of value: "]
	;        vprint either object? value [vprint "" vdump value] [mold :value]
	;        exit
	;    ]
		args: third :value
		vprin "USAGE:^/^-"
		if not op? :value [vprin append uppercase mold word " "]
		while [not tail? args][
			item: first args
			if :item = /local [break]
			if any [all [any-word? :item not set-word? :item] refinement? :item][
				vprin append mold :item " "
				if op? :value [vprin append uppercase mold word " " value: none]
			]
			args: next args
		]
		vprint ""
		args: head args
		value: get* word
		vprint "^/DESCRIPTION:"
		either string? pick args 1 [
			vprint [tab first args]
			args: next args
		][
			vprint "^-(undocumented)"
		]
		vprint [tab uppercase mold word "is" type-name :value "value."]
		if block? pick args 1 [
			attrs: first args
			args: next args
		]
		if tail? args [exit]
		while [not tail? args][
			item: first args
			args: next args
			if :item = /local [break]
			either not refinement? :item [
				all [set-word? :item :item = to-set-word 'return block? first args rtype: first args]
				if none? refmode [
					vprint "^/ARGUMENTS:"
					refmode: 'args
				]
			][
				if refmode <> 'refs [
					vprint "^/REFINEMENTS:"
					refmode: 'refs
				]
			]
			either refinement? :item [
				vprin [tab mold item]
				if string? pick args 1 [vprin [" --" first args] args: next args]
				vprint ""
			][
				if all [any-word? :item not set-word? :item][
					if refmode = 'refs [vprin tab]
					vprin [tab :item "-- "]
					types: if block? pick args 1 [args: next args first back args]
					if string? pick args 1 [vprin [first args ""] args: next args]
					if not types [types: 'any]
					vprin rejoin ["(Type: " types ")"]
					vprint ""
				]
			]
		]
		if rtype [vprint ["^/RETURNS:^/^-" rtype]]
		if attrs [
			vprint "^/(SPECIAL ATTRIBUTES)"
			while [not tail? attrs][
				value: first attrs
				attrs: next attrs
				if any-word? value [
					vprin [tab value]
					if string? pick attrs 1 [
						vprin [" -- " first attrs]
						attrs: next attrs
					]
					vprint ""
				]
			]
		]
		exit
	]
	
	
	;----------------
	;-    vlog-reset()
	;----
	vlog-reset: func [][
		if all [file? vlogfile exists? vlogfile][
			;-----
			; more effective than a delete, cause if the file is being traced or read by another tool,
			; a lock will be effective on the file.  In this case, files cannot be deleted or renamed.
			; but changing its content is still possible. So by clearing it we effectively remove the disk space and
			; reset it even if a file opened lock exists.
			;
			; the above may not hold for all platforms though.
			;-----
			write vlogfile ""
		]
	]
	
	
	;----------------
	;-    vflush()
	;----
	vflush: func [
		/disk logfile [file!]
	][
		if block? vconsole [
			forall head vconsole [
				append first vconsole "^/"
			]
			either disk [
				write logfile rejoin head vconsole
			][
				print head vconsole
			]
			clear head vconsole
		]
	]
	

	;--------------------------
	;-         	vask()
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
	vask: funcl [
		question
	][
		if print?  false none [
			ask question
		]
	]


	;--------------------------
	;-         	vimport()
	;--------------------------
	; purpose:  imports all vprinting function within global context.
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
	vimport: does [
		set in system/words 'von :von
		set in system/words 'voff :voff
		set in system/words 'vprint :vprint
		set in system/words 'vprin :vprin
		set in system/words 'vprobe :vprobe
		set in system/words 'vout :vout
		set in system/words 'vin :vin
		set in system/words 'vflush :vflush
		set in system/words 'vask :vask
		set in system/words 'v?? :v??
		set in system/words 'vhelp :vhelp
		set in system/words 'vdump :vdump
		set in system/words 'vreset :vreset
		set in system/words 'vlog :vlog
		set in system/words 'vlog-on :vlog-on
		set in system/words 'vlog-off :vlog-off
		set in system/words 'vlog-reset :vlog-reset
	]


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     SLIM LIB LOADING
	;
	;-----------------------------------------------------------------------------------------------------------


	;----------------
	;-    open()
	;----
	OPEN: funcl [
		"Open a library module.  If it is already loaded from disk, then it returns the memory cached version instead."
		lib-name [word! string! file!] "The name of the library module you wish to open.  This is the name of the file on disk.  Also, the name in its header, must match. when using a direct file type, lib name is irrelevant, but version must still be qualified."
		version [integer! float! tuple! none! word!] "minimal version of the library which you need, all versions should be backwards compatible."
		/within path [file!] "supply an explicit paths dir to use.  ONLY this path is used, libs, slim path and current-dir are ignored."
		/extension ext [string! word! file!] "what extension do we expect. Overrides default-extensions. with or without dot"
		/new "Re-load the module from disk, even if one exists in cache."
		/import imp-words [block!] "expose words from the lib after its loaded and bound, be mindfull that words are either local or bound to local context, if they have been declared before the call to open."
		/expose exp-words [block!] "DEPRECATED expose words from the lib after its loaded and bound, be mindfull that words are either local or bound to local context, if they have been declared before the call to open."
		/prefix pfx-word [word! string! none!] "use this prefix instead of the default setup in the lib as a prefix to exposed words"
		/quiet "Don't raise error when a lib isn't found.  This is sticky, once set all further opens are also quiet.   NOTE:  THIS MUST NEVER BE USED WITHIN LIBRARIES, ONLY ROOT SCRIPTS."
		/silent "Eradicate vprint functionality in the library (cannot be undone)"
		/platform "This is a platform specific library, we expect the file (and slim name) to be prefixed with the platform name (but not in your code)."
		;/local lib lib-file lib-hdr
		;-----------------
		; before v1.0.0 
		; /expose exp-words [word! block!] "expose words from the lib after its loaded and bound, be mindfull that words are either local or bound to local context, if they have been declared before the call to open."
		;-----------------
	][
	
		version-mode: none
	
		;---
		; numbered version docs
		;
		; +1.0.0 must be ANY version at or beyond 1.0.0
		; -1.0.0 must be AT or below  1.0.0
		; =1.0.0 exactly 1.0.0 and nothing else
		;  1.0.0 must be ANY version at or beyond 1.0.0 AND has to be the SAME major version (so anything at or beyond 2.0.0 will fail)
		;---
		
		
	
		;--------------------------
		; Standardize arguments:
		;--------------------------
		; Make sure lib-name is a word
		lib-name: attempt [
			any [
				all [word? lib-name   lib-name]
				all [
					word? temp: load to-string lib-name
					temp
				]
				to-error rejoin ["Slim/open() Invalid lib name: " lib-name]
			]
		]

		if platform [
			lib-name: to-word rejoin [ "" lib-name  "-"  platform-name ]
		]

		; Prefix extension with #"."
		if ext [
			ext: to-string ext
			unless #"." = first ext [insert ext #"."]
		]
		
		; Futureproof interface
		; any word you want to use for version will disable explicit version needs
		version-mode:  case [
			(word? version) [
				verstr: to-string version
				switch version/1 [
					#"=" [
						version: as-tuple next version
						'exact
					]
					#"-" [
						version: as-tuple next version
						'at-most
					]
					#"+" [
						version: as-tuple next version
						'at-least
					]
				][
					to-error rejoin ["slim/open() invalid version mode '" version/1]
				]
			]
			
			(any [
				integer? version
				float? version
				tuple? version
			]) [
				version: as-tuple version
				'at-least-capped
			]
			
			'default [
				to-error rejoin ["slim/open() invalid version : " mold :version ]
			]
		]
		
		v?? version-mode
		v?? version
		
		;-----
		; Initial opening trace 
		prev-opening-lib: self/opening-lib-name
		vprint/in ["SLiM/Open( " uppercase to-string lib-name " " either version [ rejoin [" version " version-mode  version] ][ " any version"  ]  " ) ["]
		if new [
			vprint "Loading a NEW INSTANCE of the library in RAM"
		]
		
		either all [
			quiet
			self/opening-lib-name
		][
			to-error "Can not use /quiet within Slim libraries."
		][
			if quiet [quiet?: true]
		]
		
		
		self/opening-lib-name: lib-name
		
		
		vprint ["MEM: " (stats / 1'000'000) "MB"]
		;ask "======"
		
		;probe "--------"
		;probe self/paths
		
		;probe type? linked-libs
		;ask "@"
		;possible-exts
		either none? linked-libs [
;			<SMC> Always a word here so this check seems useless
;			either file? lib-name [
;				lib-file: lib-name
;			][
;				lib-file: either within [
;					 rejoin [dirize path lib-name ext]
;				][
;					self/find-path to-file rejoin [lib-name ext]
;				]
;			]

			; Find absolute path of the library to open
			; Possible refinements combinations
			;	1. within and extension => no lookup -> absolute path
			;	2. within only => look for default extensions in provided path
			;	3. extension only => look in default paths for specific extension
			;	4. nothing => look for all possible extensions in all possible paths
			lib-file: none
			either within [
				either ext [
					; no lookup -> absolute path
					lib-file: rejoin [dirize path lib-name ext]
				][
					; Look for lib-name with default-lib-extensions in path
					foreach ext-i default-lib-extensions [
						filepath: rejoin [dirize path lib-name ext-i]
						if exists? filepath [
							lib-file: filepath
							break
						]
					]
				]
			][
				either ext [
					; look in default paths for specific extension
					lib-file: self/find-path to-file rejoin [lib-name ext]
				][
					; look for all possible extensions in all possible paths
					foreach ext-i default-lib-extensions [
						lib-file: self/find-path to-file rejoin [lib-name ext-i]
						if lib-file [break]
					]
				]
			]
		][
			lib-file: select linked-libs lib-name
		]
		
		
;		if none? version [version: 0.0]
		self/open-version: version  ; store requested version for validate(), which is called in register.
		
		;-----------------------------------------------------------
		; check for existence of library in cache
		lib: self/cached? lib-name
		
		either all [
			lib 
			not new
		][
			vprint [ {SLiM/open() reusing "} lib-name {"  module} ]
		][
			vprint [ {SLiM/open() loading "} lib-file {"  module} ]
			either lib-file [
				do lib-file
				
				;--
				; we reset the name, since a sub-module may have already replaced it.
				self/opening-lib-name: lib-name

				lib: self/cached? lib-name
			][
				either quiet [
					vprint ["SLiM/open() " lib-name " library not found (paths: " SEARCH-PATHS ")"]
				][
					to-error rejoin ["SLiM/open() " lib-name " library not found (paths: " SEARCH-PATHS ")"]
				]
			]
		]
		
		v?? type? lib
		
		; in any case, check if user wanted to expose new words
		if all [
			lib
			expose
		][
			either prefix [
				if string? pfx-word [pfx-word: to-word pfx-word]
				slim/expose/prefix lib exp-words pfx-word
			][
				slim/expose lib exp-words
			]
		]
		
		
		;--
		; note, if silenced by one lib opener, it is silenced for all.
		if silent [
			silence-lib lib
		]
		
		; clean exit
		lib-name: none
		version: none
		lib-file: none
		lib-hdr: none
		exp-words: none
		pfx-word: none
		
		v?? [type? lib]
		self/opening-lib-name: prev-opening-lib
		vout 
		first reduce [ lib lib: none ]
	]

	
	;----------------
	;-    flush()
	;
	; reset one or all loaded libs so that new calls to slim/open will reload them from disk.
	;
	; note that using this function without a refinement causes an error.
	;----------------
	FLUSH: func [
		/all
		/lib name [word!]
		/local blk
	][
		; <TODO> update for new multi-version format of self/libs

		case [
			all [
				libs: copy []
			]
			lib [
				if blk: find libs name [
					remove/part blk 2
				]
			]
			'default [
				to-error "slim/flush() requires one of /lib or /all refinements to be specified."
			]
		]
		
	]
	

	;--------------------------
	;-    silence-lib()
	;--------------------------
	; purpose:  disable the vprinting funcs for a library, usually in order for it to run faster.
	;
	; inputs:   slim library to silence
	;
	; notes:    probably dangerous to use... a quick temporary hack.
	;--------------------------
	silence-lib: funcl [
		lib
	][
		;print "@"
		lib/vprint: none
		lib/vprobe: func [val][val]
		lib/vin: none
		lib/vout: none
		lib/v??: none
		lib/vflush: none
	]
	
	
	;--------------------------
	;-    silence-all()
	;--------------------------
	; purpose:  silence all loaded libraries.
	;
	; notes:    as above, possibly dangerous to use
	;
	; todo:     
	;--------------------------
	silence-all: funcl [][
		vin "silence-all()"
		lib: none
		ctx: none
		
		; <TODO> update for new multi-version format of self/libs
		
		foreach [lib ctx] libs [
			silence-lib ctx
		]
		vout
	]
	
	
	;----------------
	;-    register()
	;
	; notes:    /silent is a hack and will crash more advanced uses of vprinting (specifically, any use of refinements on any vprinting function.)
	;----
	REGISTER: func [
		blk
		/silent "reset all vprints to no-ops... makes it faster than simply using von voff"
		/header "reserved, private" ; private... do not use.  only to be used by slim linker.
			hdrblk [string! block!]
		/unsafe "use this to prevent the collection of all words in order to make them local.  This should be a temporary measure for backwards compatibility, if the new version breaks old libs." 
		/local lib-spec pre-io post-io block -*&*_&_*&*- success words item item-str expose-block? list lib
	][
		vprint/in ["SLiM/REGISTER() ["]
		
		;--------------------------------------------------
		; these are the words which will be added to any slim module
		;
		; taken from slim context but bound to the library.
		;
		; any words which the functions refer to which aren't in the slim library,
		; will still be bound to slim.
		;
		; so some things, like vprint tabs will be shared with slim, while othe things
		; like the verbose? flag will be local to the module.
		;--------------------------------------------------
		slim-localized-funcs: [ von voff vprint vprin vindent vprobe vin vout v?? vhelp vdump vask print? log? vlog-on vlog-off]
		
		; temporarily set '-*&*_&_*&*- to self it is later set to the new library
		-*&*_&_*&*-: self
		
		;--------------
		; initialize default library spec
		lib-spec: copy []
		append lib-spec blk

		;--------------
		; link header data when loading library module
		either none? header [
			hdrblk: system/script/header ; <SMC> This was set manually by loading the script
		][
			if string? hdrblk [
				hdrblk: load hdrblk
			]
			hdrblk: make object! hdrblk
		]
		
		;--------------
		;-        -declare local words
		;
		; new in v1.0.0
		;
		; automatically add all set-words to the library as local words, 
		; ensuring that any defined words become local to the library
		;
		; we also add all sub words used within slim/open/expose calls.
		;
		; this means a module no longer really has access to globals unless all of its references
		; to the global are via the 'SET word (or uses system/words/xxx).   the moment it uses   word:   any attempt to use that word
		; will be local to the module (even using 'SET).
		;
		; if this new feature breaks some code, you may use the /unsafe keyword to prevent it.
		;--------------
		unless unsafe [
			words: extract-set-words/only/ignore lib-spec [header self verbose? vlogging? rsrc-path dir-path ]
			
			foreach item lib-spec [
				;probe mold :item
				;vprobe type? :item
				case [
					;-----------
					; detect slim library calls which expose words
					;-----------
					all [
						path? :item
						find item-str: mold :item "slim/open"
						find item-str "expose"
					][
						; activate the expose browsing, so that the next block encountered is added to local words.
						expose-block?: true
					]
					
					
					;-----------
					; trap the exposed words
					;-----------
					all [
						expose-block?
						block? :item
					][
						if find item-str "prefix" [
							print "Slim WARNING:  leaking of words outside slim library occuring.^/^/Safe mode is activated (by default), but it doesn't support prefixed word exposing in sub modules.  ^/Use register/unsafe (and manually declare all exposed words in your module) or don't prefix sub-module words, to remove this message."
						]
						list: build-expose-list item none
						append words extract list 2
						;vprobe list
						expose-block?: false
					]
				]
			]
			
			words: unique words
			
			insert lib-spec #[none]
			insert lib-spec words
		]
		
		
		
		;--------------
		; make sure library meets all requirements
		either self/validate-lib-header (hdrblk) [  
			;--------------
			; compile library specification
			
			;print "================================"
			;foreach word join slim-localized-funcs [ 'vtags 'ntags 'log-vtags 'log-ntags ][
			foreach word append slim-localized-funcs [ 'vtags 'ntags 'log-vtags 'log-ntags ][
				;?? word
				insert lib-spec reduce [to-set-word word #[none]
				]
			]
			
			
			
			lib-spec: head insert lib-spec compose [
				header: (hdrblk)
				;just allocate object space
;				rsrc-path: (:copy) what-dir
				dir-path: (:copy) what-dir
				
;				read-resource: #[none]
;				write-resource: #[none]
;				load-resource: #[none]
;				save-resource: #[none]
				
				;--------------
				;-         setup library vprinting
				; temporarily set these to the slim print tools... 
				; once the object is built, they will be bound to that object
				verbose?: false
				vlogging?: false
				
				
;				vprint: (:get*) (:in) -*&*_&_*&*- 'vprint
;				vprin: (:get*) (:in) -*&*_&_*&*- 'vprin
;				vprobe: (:get*) (:in) -*&*_&_*&*- 'vprobe
;				v??: (:get*) (:in) -*&*_&_*&*- 'v??
;				vhelp: (:get*) (:in) -*&*_&_*&*- 'vhelp
;				vdump: (:get*) (:in) -*&*_&_*&*- 'vdump
;				
;				
;				
;				vin: (:get*) (:in) -*&*_&_*&*- 'vin
;				vout: (:get*) (:in) -*&*_&_*&*- 'vout
;				
;				von: (:get*) (:in) -*&*_&_*&*- 'von
;				voff: (:get*) (:in) -*&*_&_*&*- 'voff
;				
;				
;				print?: (:get*) (:in) -*&*_&_*&*- 'print?
;				log?: (:get*) (:in) -*&*_&_*&*- 'log?
				
								
;				vflush: (:get*) (:in) -*&*_&_*&*- 'vflush
;				vconsole: #[none]
				
;				vtags: #[none]
;				ntags: #[none]		; setting this to a block of tags to ignore, prevents vtags to function, making console messages very selective.
;				log-vtags: #[none]     ; selective logging selection
;				log-ntags: #[none]     ; selective logging ignoring.
			]


			
			;vprint "LIBRARY TO LOAD:"
			;vprobe lib-spec
			;ask "go >"
			
			;--------------
			; create library        
			lib:  make object! lib-spec
			


			
			; set resource-dir local to library
;			vprint ["setting  resource path for lib " hdrblk/title]
;			vprint ["what-dir: " what-dir]
;			vprint ["slim name: " mold lib/header/slim-name]
;			if not (exists? lib/rsrc-path:  to-file append copy what-dir rejoin ["rsrc-" lib/header/slim-name "/"]) [
;				lib/rsrc-path: none
;			]
			
	
			;--------------
			;-         extend I/O ('read/'write/'load/'save)
;			pre-io: compose/deep [
;				 if (bind 'rsrc-path in lib 'header) [tmp: what-dir change-dir (bind 'rsrc-path in lib 'header)]
;			]
;			post-io: compose/deep [
;				if  (bind 'rsrc-path in lib 'header) [change-dir tmp]
;			]
;			lib/read-resource: encompass/args/pre/post 'read [ /local tmp] pre-io post-io           
;			lib/write-resource: encompass/silent/args/pre/post 'write [/local tmp] pre-io post-io
;			lib/load-resource: encompass/args/pre/post 'load [ /local tmp] pre-io post-io
;			lib/save-resource: encompass/silent/args/pre/post 'save [/local tmp] pre-io post-io

			
			
			;--------------
			; setup verbose? print
			; note that each library uses its own verbose? value, so you can print only messages
			; from a specific library and ignore ALL other printouts.
			;------------
			foreach word slim-localized-funcs [
				set in lib word func (spec-of get* (in self word)) (bind/copy body-of get* (in self word) in lib 'self)
			]
			


			;--------------
			; auto-init feature of library if it needs dynamic data (like files to load or opening network ports)...
			; or simply copy blocks
			;
			; note that loading inter-dependent slim libs within the --init-- is safe
			either (in lib '--init--) [
				success: lib/--init--
			][
				success: true
			]
			

			;--------------
			; a verification that given lib is valid.        
			lib? lib

			
			either success [
				;--------------
				; cache library
				; this causes the open library to be able to return the library to the 
				; application which opened the library.  open (after do'ing the library file) will then
				; call cached? to get the library ptr and return it to the user.
				SLiM/cache lib
				
				
				; silent is really a hack, it crashes when refinements are used on vprint functions.
				if silent [
					silence-lib lib
				]
				
				
			][
				slim/cache/remove lib
				slim-error ["SLiM/REGISTER() initialisation of module: " lib/header/slim-name " failed!"]
				lib: none
			]
		][
			slim-error ["SLiM/REGISTER() validation of library: " hdrblk/slim-name"  failed!"]
		]
		vprint/out "]"
		lib
	]
	
	
	;--------------------------
	;-    slim-error()
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
	slim-error: funcl [
		msg
	][
		vin "SLIM-ERROR !!! : "
		if self/opening-lib-name [
			if block? msg [
				msg: rejoin msg
			]
			msg: rejoin [""  msg " (lib: '" self/opening-lib-name ")"]
		]
		either quiet? [
			vprint msg
		][
			to-error msg
		]
		vout
		; help to short circuit a any/all block
		none
	]
	
	
	;----------------
	;-    lib?()
	;----
	lib?: funcl [
		"returns true if you supply a valid library module object, else otherwise."
		lib
	][
		all [
			any [
				object? :lib
				slim-error "SLiM/lib?(): ERROR!! supplied data is not an object!"
			]
			any [
				in lib 'verbose?
				slim-error "SLiM/lib?(): ERROR!! registered lib doesn't contain verbose? attribute!?"
			]
			any [
				in lib 'header
				slim-error "SLiM/lib?(): ERROR!! supplied lib file has no header!"
			]
			any [
				in lib/header 'slim-name
				slim-error "SLiM/lib?(): ERROR!! lib file must specify a 'slim-name: in its header"
			]
		]
	]
	
	
	;----------------
	;-    cache
	;----
	cache: func [
{
copy the new library in the libs list.
NOTE that the current library will be replaced if one is already present. but
any library pointing to the old version still points to it.
}
		lib "Library module to cache."
		/remove "Removes the lib from cache"
		/local ptr
	][

		; <TODO> update for new multi-version format of self/libs

		vin "slim/cache()"
		;either lib? lib [
			;vprobe to-string lib/header
			either remove [
				if ( cached? lib/header/slim-name )[
					system/words/remove/part find libs lib/header/slim-name 2
				]
			][
				if ( cached? lib/header/slim-name )[
					vprint rejoin [{SLiM/cache()  replacing module: "} uppercase to-string lib/header/slim-name {"} ]
					; if the library was cached, then remove it from libs block
					system/words/remove/part find libs lib/header/slim-name 2
				]
				;---
				; actually add the library in the list...
				vprint rejoin [{SLiM/cache() registering module: "} uppercase to-string lib/header/slim-name {"} ]
				insert tail libs lib/header/slim-name
				insert tail libs lib
			]
		;][
		;	vout
		;	slim-error "SLiM/cache(): ERROR!! supplied argument is not a library object!"
		;]
		vprint "slim/cache done!"
		vout
	]


	;----------------
	;-    cached?
	;----
	; find the pointer to an already opened library object 
	;  a return of none, means that a library of that name was not yet registered...
	;
	; file! type added to support file-based lib-name
	;
	; changes:
	;    v2.0.0 - added version matching to allow multiple versions in memory.
	;           - removed /list refinement, cannot find a single use in code after a decade.
	;           - remove file! type support for lib names in all of slim
	;----
	cached?: funcl [
		libname 	[ word! ] 
		version		[ tuple! float! integer! string! ]
		mode 		[ word! ]
		;/list
		;/version mode ver
	][
		lib: none
		vin "slim/cached?()"
;		either list [
;			libs: copy []
;			foreach [lib libctx] self/libs [
;				append libs lib
;			]
;			libs
;		][
;			lib: select self/libs libname
;		]

		if libs: select self/libs libname [
			; we rely on Red's Foreach not re-binding loop body
			foreach [lib-ver lib] libs [
				if qualify-version lib-ver mode version [
					break
				]
			]
		]
		
		v?? [object? lib]
		
		;vprint [{SLiM/cached? '} uppercase to-string libname {... } either lib [ true][false]]
		;return lib
		vout
		lib
	]

	
	;--------------------------
	;-    qualify-version()
	;--------------------------
	; purpose:  determines if a version is a valid match given a mode and reference version to compare.
	;
	; inputs:   two versions and a 	qualify mode
	;
	; returns:  true/false
	;
	; notes:    uses the same modes as defined in open ()
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	qualify-version: funcl [
		version				[ tuple! float! integer! string! ]
		mode 				[ word! ]
		reference-version	[ tuple! float! integer! string! ]
	][
		vin "qualify-version()"
		;---
		; modes:
		;
		; 'at-least
		; +1.0.0 must be ANY version at or beyond 1.0.0
		;
		; 'at-most
		; -1.0.0 must be AT or below  1.0.0
		;
		; 'exact
		; =1.0.0 exactly 1.0.0 and nothing else
		;
		; 'at-least-capped
		;  1.0.0 must be ANY version at or beyond 1.0.0 AND has to be the SAME major version (so anything at or beyond 2.0.0 will fail)
		;---
		
		; make sure the inputs are tuples
		version: as-tuple version
		reference-version: as-tuple reference-version
		
		vprint [ ""  version " " mode " " reference-version ]
				
		match?: switch mode [
			at-least [
				version >= reference-version
			]
			at-most [
				version <= reference-version
			]
			exact [
				version = reference-version
			]
			at-least-capped [
				all [
					version >= reference-version
					version/1 = reference-version/1
					any [ 
						reference-version/2 = 0
						version/2 = reference-version/2
					]
				]
			]
		]
		v?? match?
		vout
		match?
	]




	;-----------------
	;-    application-path()
	;
	; notes:  this is a self-modifying function, which will replace itself with a static file! path.
	;-----------------
	application-path: funcl [/extern application-path][
		vin "application-path()"
;		vprobe what-dir
;		vprobe words-of system/script
;		help system/script
;		vprobe words-of system/script/parent
;		
;		parent: system/script
;		until [
;			script: parent
;			parent: script/parent
;			any [
;				none? parent
;			;	none? parent/header
;			]
;		]
		vout
;		get in script 'path
		
		application-path: what-dir
	]
	
	
	;--------------------------
	;-    add-path()
	;--------------------------
	; purpose:  add library search paths
	;
	; inputs:   a list of folders to search (in order)
	;
	; notes:    these paths take precedence over internal paths.
	;
	; tests:    
	;--------------------------
	add-path: funcl [
		dir [file! block!]
	][
		vin "add-path()"
		dirs: compose [(dir)]
		foreach dir reverse copy dirs [
			insert paths clean-path dir
		]
		vout
	]
	
	
	;--------------------------
	;-    search-paths()
	;--------------------------
	; purpose:  dynamically builds the list of paths currently accessible by slim
	;
	; returns:  block of file! path
	;
	; notes:    includes all logical paths like app relative and slim.r relative.
	;			new as of v1.2.2
	;
	; tests:    
	;
	;      test [ search-paths slim.r ][   not empty? slim/search-paths   ]
	;--------------------------
	search-paths: funcl [
		"Dynamically builds the list of paths currently accessible by slim"
	][
		vin "search-paths()"
		;----
		; ordering of library search:
		;----
		app-path: application-path
		paths: compose [
			(copy app-path)				; 1) current directory
			(rejoin [app-path %libs/])	; 2) libs subdir within current directory
			(self/paths)				; 3) manual search path setup
			(self/slim-packages)		; 4) list of subdirs in slim path
		]
		new-line/all paths true
		v?? paths
		vout
		paths
	]
	

	;----------------
	;-    find-path()
	;----
	; finds the first occurence of file in all paths.
	;----
	find-path: funcl [
		file	[file!]
		/lib
		;/
		;/local path item paths disk-paths p
	][
		vin ["SLiM/find-path(" file ")"]

		paths: search-paths  ; v1.2.2 change
		
		foreach path paths [
			vprint path
			if file? path [
				filepath: join path file
				either exists? filepath [
					either lib [
						data: load/header/all lib-file
						;probe first first data
						either (in data 'slim-name ) [
							break
						][
							filepath: none
						]
					][
						break
					]
				][
					filepath: none
				]
			]
		]
		
		vprint filepath
		vout
		return filepath
	]
	
	
	;----------------
	;-    validate-lib-header()
	;----
	; make sure a given library header is valid for an application's requirements.
	;----
	validate-lib-header: funcl [
		header
	][
		vin "SLiM/validate-lib-header()"
		success: false
		ver: system/version
		
		;probe ver
		;probe self/open-version
		;------------------
		; verify if slim version is recent enough for this library.
		;---
		;<TODO><SMC> We should log the path of the loaded library (local, libs or slim)
		all [
			any [
				lib-ver: in header 'slim-version
				slim-error "SLiM/lib?(): ERROR!! lib file must specify a 'slim-version:"
			]
			any [
				tuple? lib-ver: get lib-ver
				slim-error "SLiM/lib?(): ERROR!! slim-version: must be a tuple! value"
			]
			;probe self/opening-lib-name
			;?? lib-ver
			any [
				manager-version >= lib-ver 
				slim-error ["SLiM/lib?(): ERROR!! required version of slim (v" lib-ver ") is higher than installed version. (v" manager-version ")"  ]
			]
			any [
				lib-name: in header 'slim-name
				slim-error "SLiM/lib?(): ERROR!! lib file must specify a 'slim-name:"
			]
			any [
				word? lib-name: get lib-name
				slim-error "SLiM/lib?(): ERROR!! library header's slim-name must be a word!"
			]
			any [
				lib-name = self/opening-lib-name
				slim-error "SLiM/lib?(): ERROR!! library header's slim-name must match the disk filename of the library"
			]
		]
		
		;strip OS related version
		ver: to-tuple reduce [ver/1 ver/2 ver/3]
		; make sure the lib is sufficiently recent enough
		either(version-check header/version self/open-version "+") [
			;print "."
			; make sure rebol is sufficient
			either all [(in header 'slim-requires) header/slim-requires ][
				pkg-blk: first next find header/slim-requires 'package
				either pkg-blk [
					foreach [package version] pkg-blk [
						package: to-string package
						;probe package
						if find package to-string system/product [
							;print "library validation was successfull"
							success: version-check ver version package
							package-success: true
							break
						]
					]
					if not success [
						either package-success [
							vprint "SLiM/validate-lib-header() rebol version mismatch"
						][
							vprint "SLiM/validate-lib-header() rebol package mismatch"
						]
					]
				][
					; library does not impose rebol version requisites
					; it should thus work with ALL rebol versions.
					success: true
				]
			][
				success: true
			]
		][
			;----
			; this is not an error, we might continue, until we find the proper message
			vprint ["SLiM/validate-lib-header() LIBRARY VERSION mismatch... needs v" self/open-version "   Found: v"header/version]
		]
		vout
		success
	]
	
	
	;-------------------
	;-    as-tuple()
	;-------------------
	; enforces any integer or decimal as a 3 digit tuple value (extra digits are ignored... to facilitate rebol version matching)
	; now also allows you to truncate the number of digits in a tuple value... usefull to compare major versions,
	; or removing platform part of rebol version.
	;----
	as-tuple: func [
		value
		/digits dcount
		/local yval i
	][
		value: switch type?/word value [
			none! [0.0.0]
			integer! [to-tuple reduce [value 0 0]]
			float! [
				yVal: to-string remainder value 1
				either (length? yVal) > 2 [
					yVal: to-integer at yVal 3
				][
					yVal: 0
				]
				
				to-tuple reduce [(to-integer value)   yVal   0 ]
			]
			tuple! [
				if digits [
					if (length? value) > dcount [
						digits: copy "" ; just reusing mem space... ugly
						repeat i dcount [
							append digits reduce [to-string pick value i "."]
						]
						digits: head remove back tail digits
						value: to-tuple digits
					]
				]
				value
			]
		]
		value
	]
	
	
	;----------------
	;-    version-check()
	;
	; mode's last character determines validitiy of match.
	;
	; deprecated, replaced by qualify-version()
	;----
	version-check: funcl [
		supplied required mode
	][
		supplied: as-tuple supplied
		required: as-tuple required
		
		;vprobe supplied
		;vprobe required
		
		any [
			all [(#"=" = (last mode)) (supplied = required)]
			all [(#"-" = (last mode)) ( supplied <= required)]
			all [(#"_" = (last mode)) ( supplied < required)]
			all [supplied >= required]
			;all [(#"+" = (last mode)) ( supplied >= required)]
		]
	]


	;--------------------------
	;-    build-expose-list()
	;--------------------------
	; purpose:  generate the list of words which must be exposed and the list of how they will be named.
	;
	; inputs:   library expose spec and a prefix ( #[none] or 'none meaning no prefix )
	;
	; returns:  a flat block of word pairs (easily used with 'EXTRACT and /skip refinements).
	;
	; notes:    
	;
	; tests:    [ 
	;				build-expose-list   [ fubar [x: y]] 'doh-    ; results in  [  doh-fubar  fubar     doh-x  y   ] 
	;			]
	;--------------------------
	build-expose-list: funcl [
		spec [block!]
		prefix [word! none!]
		;/local from to sw w
	][
		vin "slim/build-expose-list()"
		v?? spec
		
		list: copy []
		
		
		; clear the prefix if it was given as none.
		prefix: to-string any [
			prefix
			""
		]
		
		
		parse spec [
			some [
				
				['self ] ; do nothing, these would cause errors.
				
				;---
				; simply expose one word
				| [
					set w word!  (
						append list reduce [ ( to-set-word rejoin [ prefix w ] )   w  ]
					)
				]
				
				;---
				; using set-words is the new prefered method
				| [
					set sw set-word! 
					set w word! (
						append list reduce [ ( to-set-word rejoin [ prefix sw ] )   w  ] 
					)
				]
			
				;---
				; a block spec of word renames (deprecated, but still supported)
				|  set blk into  [
					here: 
					
					some [
						set sw [word! | set-word!]   ; using set-words is the new prefered method
						set w word! (
							append list reduce [ ( to-set-word rejoin [ prefix sw ] )   w  ] 
						)
						| skip
					]
				]
				
				| skip
			]
		]
		
;		vprint "========"
;		vprobe list
;		vprint "========"
		
		
;			;----------------------------
;			;----- BUILD EXPOSE LIST
;			;----------------------------
;			; create base expose list based on rename words list
;			either not rwords [
;				rwords: copy []
;			][
;				if odd? (length? rwords) [
;					vprint/always ",--------------------------------------------------------."
;					vprint/always "|  SLiM/EXPOSE() ERROR!!:                                |"
;					vprint/always "|                                                        |"
;					vprint/always head change at "|                                                        |"  7 (rejoin ["module: "lib/header/slim-name ])
;					vprint/always "|     invalid rename block has an odd number of entries  |"
;					vprint/always "|     Rename block will be ignored                       |"
;					vprint/always "`--------------------------------------------------------'"
;					rwords: copy []
;				]
;			]
			
			
		vout
		
		list
	]


	;----------------
	;-    expose()
	;----
	; expose words in the calling namespace, so that you do not have to use a lib ptr.
	; context is left untouched, so method internals continue to use library object's
	; properties.
	;----------------
	expose: funcl [
		;lib [word! string! object!]
		lib [object!]
		words [word! block! none!]
		/prefix pword
		;/local reserved-words word rwords rsource rdest blk to from bind-reference
	][
		vprint/in "SLiM/EXPOSE() ["

		;----
		; handle alternate lib argument datatypes
		if string? lib [lib: to-word lib]
		if word? lib [lib: cached? lib]
		
		;----
		; get a word in the list to get its binding
		; we can't supply an empty words block.
		if block? bind-reference: first words [
			bind-reference: first bind-reference
		]
		
		
		;----
		; make sure we have a lib object at this point
		if lib [
			reserved-words: [
				--init-- 
				;load save read write 
				self 
				rsrc-path 
				header 
				--private--
			]
			
			
			if in lib '--private-- [
				;vprint "ADDING PRIVATE WORDS"
				reserved-words: append copy reserved-words lib/--private--
			]


			words: build-expose-list words pword
			
			;----------------------------
			;----- REMOVE ANY RESERVED WORDS FROM LIST!
			;----------------------------
			remove-each [to from] words [
				find reserved-words from
			]
			
			
			;print ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
			hdr: first bind reduce copy ['header] bind-reference
			
			either object? get/any hdr [
				libname: get in get hdr 'slim-name
				;probe get hdr
			][
				libname: "application"
			]
			;print "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
			
			
			unless empty? words [
				until [
					;v?? words
					from: second words
					to:   first  words
					
					
					; this is a complex binding operation!
					; we are binding to the word contained in bind-reference, 
					; not bind-reference itself.
					to: first bind reduce [to] bind-reference
					
					all [
						not quiet?
						not in lib from
						;probe :from
						
						;probe lib/header/slim-name
						;probe words-of lib/header
						
						slim-error rejoin ["Module '" Libname "' Is trying to expose '" uppercase to-string from " which isn't part of library: " lib/header/slim-name]
					]
					set to get* in lib from
					
					;vprint [ "exposing: " from " as " to ]
					tail? words: next next words
				]
			]
		]
		vprint/out "]"
	]
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     CATALOG MANAGEMENT
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-         update-index()
	;--------------------------
	; purpose:  using all search-paths() read every catalogue file
	;            you find and add them into the in-memory index
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
	update-index: funcl [
	][
		vin "update-index()"
		
		vout
	]
	
	;--------------------------
	;-         update-catalog()
	;--------------------------
	; purpose:  updates the disk catalogue file for a package folder
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    will update catalog file on disk.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	update-catalog: funcl [
		dir [file!] "A disk directory (usually a package from search-paths() )"
	][
		vin "update-catalog()"
	
		vout
	]
	
	
	;--------------------------
	;-         build-catalog()
	;--------------------------
	; purpose:  creates a catalog dataset given a package directory
	;
	; inputs:   
	;
	; returns:  a catalog dataset
	;
	; notes:    does not WRITE any thing to disk.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	build-catalog: funcl [
		dir [file!]
	][
		vin "build-catalog()"
	
		vout
	]
	
	;--------------------------
	;-         get-catalog()
	;--------------------------
	; purpose:  returns a catalog for a given package
	;
	; inputs:   
	;
	; returns:  catalogue format data
	;
	; notes:    - there may be no physical catalog on disk!
	;             in such a case we read all files and generate one run-time.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	get-catalog: funcl [
		file [file!] "open a catalogue file, given an ABSOLUTE path"
	][
		vin "get-catalog()"
	
		vout
	]
	
	;--------------------------
	;-         index-catalog()
	;--------------------------
	; purpose:  adds a catalog file to in-memory index
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
	index-catalog: funcl [
		catalog [block!]
	][
		vin "index-catalog()"
		
		vout
	]


	;--------------------------
	;-         find-indexed-path()
	;--------------------------
	; purpose:  searches the memory index for a versioned library.
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
	find-indexed-path: funcl [
		lib-name [word!]
		version [tuple!]
		mode [word!]
	][
		vin "find-indexed-path()"
		root: %/s/dev/projects/git/slim-libs/
		foreach folder read root [
			dir: join root folder
			vin dir
			foreach file read dir [
				if any [
					;find file ".red"
					find file ".slred"
					find file ".slr2"
					find file ".r"
				][
					path: join dir file
					v?? file
				]
			]
			vout
		]
		vout
	]
		
	
		
	;;----------------
	;;-    encompass()
	;;----
	;; deprecated functionality, we now have APPLY, as part of the official R2 distro.
	;encompass: function [
	;	func-name [word!]
	;	/args opt-args [block!]
	;	/pre pre-process
	;	/post post-process
	;	/silent
	;][
	;	blk dt func-args func-ptr func-body last-ref item params-blk refinements word arguments args-blk
	;][
	;	func-ptr: get in system/contexts/user func-name
	;	if not any-function? :func-ptr [vprint/always "  error... funcptr is not a function value or word" return none]
	;	arguments: third :func-ptr 
	;	func-args: copy []
	;	last-ref: none
	;	args-blk: copy compose [([('system)])([('words)])(to paren! to-lit-word func-name)]
	;	params-blk: copy [] ; stores all info about the params
	;	FOREACH item arguments [
	;		SWITCH/default TYPE?/word item [
	;			block! [
	;				blk: copy []
	;				FOREACH dt item [
	;					word: MOLD dt
	;					APPEND blk TO-WORD word
	;				]
	;				APPEND/only func-args blk
	;			]
	;			refinement! [
	;				last-ref: item
	;				if last-ref <> /local [
	;					APPEND func-args item
	;					append/only args-blk to paren! compose/deep [either (to-word item) [(to-lit-word item)][]]
	;				]
	;			]
	;			word! [
	;				either last-ref [
	;					if last-ref <> /local [
	;						append/only params-blk to paren! copy compose/deep [either (to-word last-ref) [(item)][]]
	;						append func-args item
	;					]
	;				][
	;					append/only params-blk to paren! item
	;					append func-args item
	;				]
	;			]
	;		][append/only func-args item]
	;	]
	;	
	;	blk: append append/only copy [] to paren! compose/deep [ to-path compose [(args-blk)]] params-blk
	;	func-body: append copy [] compose [
	;		(either pre [pre-process][])
	;		enclosed-func: compose (append/only copy [] blk)
	;		(either silent [[
	;			if error? (set/any 'encompass-err try [do enclosed-func]) [return :encompass-err]]
	;		][
	;			[if error? (set/any 'encompass-err try [set/any 'rval do enclosed-func]) [return :encompass-err]]
	;		])
	;		
	;		(either post [post-process][])
	;		return rval
	;	]
	;	;print "------------ slim/encompass debug --------------"
	;	;probe func-body
	;	;print "------------------------------------------------^/^/"
	;	if args [
	;		refinements: find func-args refinement!
	;		either refinements[
	;			func-args: refinements
	;		][
	;			func-args: tail func-args
	;		]
	;		insert func-args opt-args
	;	]
	;	append func-args [/rval /encompass-err]
	;	func-args: head func-args
	;	return func func-args func-body
	;]
]


;- SLIM / END





;-                                                                                                         .
;--------------------------
;- funcl()
;--------------------------
; purpose: an alternative form for the 'FUNCT function builder.  using func spec semantics (/extern instead of /local)
;
; inputs:  a spec  and body which mimics 'FUNC but uses /EXTERN to define non-locals.
;
; returns: a new function
;
; notes:   /extern MUST be the last refinement of the func spec.
;
; why?:    using funct/extern is very cumbersome.
;          It forces us to define the list of externs AFTER the function body, far away from the function's spec.
;
;          /extern MUST be the last refinement of the function.
;          /local shoudn't be used... its undefined and unsupported behavior. (just put a set-word! in the func body (word: none) , if you need the extra local)
;--------------------------
if value? 'SLIM-DEBUG-PROFILE-FUNCL [

context [
	slim-debug-set*: :set
	slim-debug-get*: :get
	slim-debug-do*: :do
	slim-debug-all*: :all
	slim-debug-change*: :change
	slim-debug-first*: :first
	slim-debug-find*: :find
	slim-debug-next*: :next
	slim-debug-if*: :if
	slim-debug-difference*: :difference
	slim-debug-now*: :now
	
	slim-debug-get-tick: slim-debug-tick-lapse: none
	
	slim-debug-chrono-lib: slim/open/expose/platform 'chrono none [  slim-debug-get-tick: get-tick  slim-debug-tick-lapse: tick-lapse]
	
	;--------------------------------
	; add profiling code to funcl generated functions
	;--------------------------------
	; just set the SLIM-DEBUG-PROFILE-FUNCL word to something before opening slim and all funcl functions will
	; be profiled and their timing stored.
	;
	; you can look at timing withing slim/profiler/funcl
	;-----
	set 'funcl func [
		[catch]
		spec [block!] 
		body [block!] 
		/pure "do not use debugging on this function"
		/local ext funcname outer-body
	][
		throw-on-error[
			either pure [
				either ext: find spec /extern [
					funct/extern copy/part spec ext body next ext
				][
					funct spec body
				]
			][
				parse body [
					'vin set funcname [string! | block!] (
						if block? funcname [
							;----
							; generate a stable name, which we can search in the code.
							funcname: mold funcname
						]
						;probe funcname
						
						append slim-debugger/profiler/funcl-timing reduce [
							funcname   ; function string
							10:00:00   ; fastest time
							0:0:0      ; slowest time
							0          ; call count
						] ; 
					)
				]
				outer-body: compose/only/deep [
					slim-debugger-result: #[none]
					slim-debugger-start: slim-debug-get-tick ; temporary, will replace with system tick counter
					
					;---
					; execute function
					slim-debug-set*/any 'slim-debugger-result slim-debug-do* ( body   ) ; we insert the body in the outer body, so funct can do its magic.
					
					;---
					; update timing information in profile stats
					slim-debugger-delay: slim-debug-tick-lapse slim-debugger-start
					
					slim-debug-if* slim-debugger-blk: slim-debug-find*/tail slim-debugger/profiler/funcl-timing (funcname) [
						;---
						; check and update fastest time
						slim-debug-all* [
							slim-debugger-delay < slim-debug-first* slim-debugger-blk
							slim-debug-change* slim-debugger-blk slim-debugger-delay
						]
						
						;---
						; check and update slowest time
						slim-debugger-blk: slim-debug-next* slim-debugger-blk
						slim-debug-all* [
							slim-debugger-delay > slim-debug-first* slim-debugger-blk
							slim-debug-change* slim-debugger-blk slim-debugger-delay
						]
						
						;---
						; update call counter
						slim-debugger-blk: slim-debug-next* slim-debugger-blk
						slim-debug-change* slim-debugger-blk   1 + slim-debug-first* slim-debugger-blk
					]
					
					;---
					; return any result generated by inner-body.
					;
					; unset! values are returned without error.
					slim-debug-get*/any 'slim-debugger-result
				]
				
				;probe outer-body
				either ext: find spec /extern [
					funct/extern copy/part spec ext outer-body next ext
				][
					funct spec outer-body
				]
			]
		]
	]
]  ; end funcl

]


;----------
; Always return SLIM itself, necessary since we added the debug FUNC above
;----------
slim

