rebol [
	; -- Core Header attributes --
	title: "slim-link - steel library module linker"
	file: %slim-link.r
	version: 1.0.1
	date: 2013-9-9
	author: "Maxim Olivier-Adlhoch"
	purpose: {link apps which have references to slim modules inside.}
	web: http://www.revault.org/modules/slim-link.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'slim-link
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/slim-link.r

	; -- Licensing details  --
	copyright: "Copyright © 2013 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2013 Maxim Olivier-Adlhoch

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
		v0.1 - 2004-04-22
			- first release
			- NO NEED FOR ANY KIND OF MAKE FILES.
			- is capable of finding slim/open calls in a file and generate a stand-alone application out of it.
			- repack.r was used to confirm that it works (this includes glayout and lds-local available at rebol.org).
			- does NOT support nested library calls yet.
			- /link allows file! string! and block! datatypes... make it very flexible
			- script-header returns only the header part of an application
			- script-body returns only the body (code) part of an application
			- ALL comments are kept, in both libraries and code.
			
		v0.1.1 - 2004-08-01
			-fixed little issues in /link where it had retained some internal (author related) debug code...

		v0.1.1 - 2008-03-26/21:46:27 (max)
			-linked files now have version data in comments,
			-better console printing report.
			-now uses vprint internally
			-license change to MIT
			
		v1.0.0 - 2010-01-04 (MOA)
			-recursive algorithm now extracts modules used by modules and links them in dependency order.
			-new PARSE-based module detection engine is twice as fast as previous code.
			-new PNG filepath replacement mechanism, allows automatic convertion of LOAD %image.png into #{26308630464306} binary image data
			 you must specify a special attribute in the rebol header (slim-link-load-png: true) of the file, if you wish this feature to be 
			 activated for that file.
			 this makes it easy to build a module which reads images dynamically on your local system, but stores images directly, once encapped.

		v1.0.1 - 9-Sep-2013
			-license change to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {        
		Using the !config class, you can dynamically setup a configuration
		which can be loaded and saved from disk at any moment.

		When you setup the config, you give it default values which will automatically 
		be used, and saved.  if you application is updated and new fields are added or
		old one removed, the previous config file can be used and it will automatically
		update and clean itself up.   
		
		
		any missing fields will use the new defaults.
		
		you can also setup some function based attributes in the config file, which allows you
		to generate new values everytime you ask for that config.  this can be very useful when
		you wish to provide forward or backward compatibility.
		
		Also, when the config file is loaded, it is verified for data integrity including type and 
		static only datatypes (one cannot set and run a function within the config file)
		
		As an added feature, the output file will include any documentation you added 
		to your config setup so that your users know what the configuration values mean.
		
		There are also a few nifty functionalities like automatically replacing occurences of any
		!config values within a given string (all at once).  This allows you to use the system for
		more things including project specification and templating with very little coding required
		on your part.
		}
	;-  \ documentation
]





;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'slim-link
;
;--------------------------------------

slim/register [
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PARSE-RULES
	;
	;-----------------------------------------------------------------------------------------------------------
	=whitespace=: charset " ^/^-"
	=whitespaces?=: [ any  =whitespace=  ]
	=whitespaces=:  [ some =whitespace= ]
	=content=: complement =whitespace=

	;----------------
	;- UTILITIES
	;----

	

	;----------------
	;-    find-first()
	;----------------
	find-first: func [
		serie [series!] "the series to check"
		cases [block!] "the case which could match"
		/local case matches match tmp
	][
		matches: copy []
		forall cases [
			case: first cases
			append matches tmp: find serie case
		]
		
		match: power 2 31
		forall matches [
			if matches/1 [
				 match: min match index? matches/1
			]
		]
		matches: none ;clear memory
		either match = (power 2 31) [
			none
		][
			at head serie match
		]
	]
		




	;----------------
	;-    script-body()
	;----------------
	script-body: func [
		source [ string!] 
		/local data blk
	][
		until [
			blk: load/next source
			source: blk/2
			((pick blk 1) = ('rebol))
		]
		
		blk: load/next source
		
		blk/2
		first reduce [blk/2 blk: source: data: none]
	]
	


	;----------------
	;-    script-header()
	;----------------
	script-header: func [
		source  [ string!] 
		/local data blk hdr hdr-base
	][
		until [
			blk: load/next source
			source: blk/2
			((pick blk 1) = ('rebol))
		]
		
		blk: load/next source
		
		
		hdr: either block? blk/1 [
			; we will make the minimal required header
			hdr: construct blk/1
			
			hdr-base: context copy [
				title:
				author:
				file:
				date:
				version:
				slim-name: slim-prefix: slim-version: slim-requires: slim-id: none
			]
			
			foreach item first hdr-base [
				;print item
				if in hdr item [
					either word? get in hdr item [
						;probe item
						set in hdr-base item to-lit-word get in hdr item
					][
						set in hdr-base item get in hdr item
					
					]
					
				]
			]
			
			
			;probe "####################"
			;?? hdr-base
			;probe mold third hdr-base
			;ask "header..."
			
			;probe mold new-line/skip third hdr-base true 0
			mold new-line/skip third hdr-base true 2
			
			
			;probe blk/2
			;data: find source blk/2
			;data: copy/part source data
			;probe data
			
		][
			none
		]
		
		first reduce [hdr hdr: blk: source: hdr-base: none]
	]


	;-    get-libs()
	get-libs: func [
		path [file!]
		current-libs [block!]
		/local source code spath lib-name lib-ver slim-open-end x i
	][
		vin "get-libs()"
		
		vprint ["MEM 1:" (stats / 1'000'000) "MB"]
		
		vprint ["extracting libs from file: " path]
		
		vprint ["MEM 2: " (stats / 1'000'000) "MB"]

		either exists? path [
			source: read path
		][
			ask rejoin ["file: " path " does not exist, aborting"]
			quit
		]
		vprint ["MEM 3: " (stats / 1'000'000) "MB"]
		;ask "..."
		;source: mold load/all script-body source
		source:  script-body source
		;source: none
		vprint ["MEM 4: " (stats / 1'000'000) "MB"]
		
		i: 0
		while [ not tail? source ] [
			vprint ["MEM 5: " (stats / 1'000'000) "MB"]
			vprint path
			vprint ["--->" copy/part source 20"<---"]
			
			lib-name: none
			lib-ver: none
			
			;---
			; breakable code block
			foreach x [1] [
				parse/all source [
					
					some [
						here:
						;(prin pick here 1 )
						
						;---
						; skip commented lines
						[
							"^/"
							=whitespaces=
							#";"
							[ 
								to "^/"
								|
								to end
							]
						]
						
						| [
							;to " "
							#"s"
							"lim/open"
							any =content= ; skip refinements, if there are any
							
							=whitespaces=
							copy lib-name some =content= 
							( v?? lib-name )
							=whitespaces=
							copy lib-ver some =content=
							slim-open-end:
							(
								lib-name: load lib-name
								lib-ver: load lib-ver
								v?? lib-name
								v?? lib-ver
								
								;---
								; we found a lib, stop parsing
								break
							)
						] 
						
						| [
							;(prin " ")
							; an error occured in slim/open spec
							slim-open-end:
							skip
							slim-open-end:
							(i: i + 1   if (i > 100'000) [prin "." i: 0])
						]
					]
				]
			]
			
			source: slim-open-end
			
			
			if all [
				lib-name
				not find current-libs lib-name 
			] [
				v?? lib-name
				;code: load lib-name: form copy/part parse/all source " ^-^/" 3
	
				vprint ["MEM 6: " (stats / 1'000'000) "MB"]
				;lib-name: to-word code/2
				
				spath: slim/find-path to-file rejoin ["" lib-name ".r"]
				
				unless spath [ 
					to-error rejoin ["Unable to find lib named: " lib-name]
				]
				
				either find current-libs lib-name [
					vprint ["skipping lib: " lib-name " already in list"]
				][
					vprint ["NEW LIB: " lib-name]
					append current-libs lib-name
					append current-libs spath
					
					get-libs spath current-libs
					vprint ["MEM 7: " (stats / 1'000'000) "MB"]
				]
				;source: next source
				;ask "?"
			]
		]
		source: spath: code: here: slim-open-end: lib-name: lib-ver: current-libs: none
		vout
	]


	;----------------
	;-    LINK()
	;----
	; experimental tool, use with caution, and always verify script before sending to peers.
	;----
	link: func [
		source [string! block! file!] "Source code to link with slim modules."
		/compressed "will take final script and compress it, adding the original and a do decompress line "
		/local
			outsource ; the processed output file
			slim-call ; the text which represent each instance of a call to open/slim (to parse refinements)
			end
			tokens
			blk
			data
			slim-lib
			lib
			code
			lib-name
			slib
			spath
			lib-blk
			lib-path
			hdr
			txt-off
			png-path
			png-data
	][
		vprint ["MEM: " (stats / 1'000'000) "MB"]
		
		;-----------------
		; PARSE ARGUMENT BY TYPE
		;-----------------
		switch type?/word source [
			block! [
				source: mold/only source 
			]
			file! [
				either exists? source [
					source: read spath: source
				][
					ask rejoin ["file: " source " does not exist, aborting"]
					quit
				]
			]
;			string! [
;				source: copy source
;			]
		]


		get-libs spath lib-blk: copy []
		vprint ["MEM: " (stats / 1'000'000) "MB"]
		
		new-line/all lib-blk true
		
		;probe lib-blk

		;data: copy source
		;data: script-body data

		;probe data


		;-----------------
		; INCLUDE SLIM
		;-----------------
		;slim-lib: script-body read  slim/slim-path/slim.r
		
		vprint "creating libs codex"
		libs-txt: append ( clear "" ) rejoin [
			"^/^/^/"
			";--------------------------------------------------------------------------------^/"
			";--------------------------- LINKED WITH SLIM-LINK.r ----------------------------^/"
			";--------------------------------------------------------------------------------^/^/"
			;slim-lib
			script-body read  slim/slim-path/slim.r
			"^/^/slim/linked-libs: []"
			"^/^/^/"
		]
		
		;write %/p/rnd/applications/SLIM-LINK-TEST/SLIM-LINK-TEST.r head data	
		
		
		
		;-----------------
		; INCLUDE MODULES
		;-----------------
		;probe source
		
		;probe what-dir
		
		;write %source-a.rdata source
		
		source: script-body source 
		
		;write %source-b.rdata source
		
		vprint "adding libs to codex"
		foreach [lib-name lib-path] lib-blk [
		
			lib-dir: first split-path lib-path
			hdr: first load/next/header lib-path ;load/header spath
			
			lib-ver: if in hdr 'version [hdr/version]
			
			vprint ["Linking : " lib-name "  v" lib-ver]
			
			lib: script-body read to-file rejoin [lib-path]
			
			;---
			;-     PNG IMAGE LINKING.
			;
			; note this is not a very efficient process by far, but it works, so its enough.
			; important... -png paths MUST NOT contain spaces 
			;              -the %"path" notation isn't managed by this feature
			if in hdr 'slim-link-load-png [
				vprint "I SHOULD LINK PNG IMAGES"
				whitespace**: charset " ^-^/"
				content**: complement whitespace**
				;?? lib
				;ask "go!"
				total-compression: 0
				total-img-size: 0
				parse/all lib [
					any [
						; ignore commented lines (only supports comments at start of line, may be preceded by whitespaces)
						
						[ newline any whitespace** ";" [[to newline ] | [to end]] ]
						| [
							here: "load %"  copy png-path some content**  there:  whitespace** (
								;?? png-path
								; only handle png paths
								if ".png" = skip tail png-path -4 [
									png-path: to-file png-path
									; resolve relative paths based on lib-path
									unless #"/" = first png-path [
										png-path: clean-path join lib-dir png-path
									]
									;?? png-path
									;ask "proper-path?"
									if exists? png-path [
										png-data: load png-path
										if image? png-data [
											png-img-size: png-data/size
											;ask "ok?"
											png-data: mold/all png-data
											png-compressed: mold compress png-data
											
											; rejoin removes spaces.
											vprint rejoin ["Embedding PNG FILE: " to-local-file png-path " " png-img-size " (" round/to ((length? png-compressed) / 1000) 0.1 "/" round/to ((length? png-data) / 1000) 0.1 "kb)" ]
											
											total-compression: total-compression + (length? png-data) - (length? png-compressed)
											total-img-size: total-img-size + (length? png-compressed)
											
											png-data: join "load decompress " png-compressed 
											
											;probe copy/part png-data 40
											
											;ask "replace?"
											change/part here png-data there
											there: skip here length? png-data
											;ask "ok?"
										]
									]
								]
								;ask "Continue?"
							)
							:there
						]
						| here: skip 
					]
				]
				
				;ask "done!"
				vprint "^/--------------------------------------------------"
				vprint ["SIZE OF IMAGE DATA ADDED TO FILE: " round/to (total-img-size / 1000) 0.1 "kb"]
				vprint ["SPACE SAVED BY COMPRESSION:       " round/to (total-compression / 1000) 0.1 "kb" ]
				vprint "--------------------------------------------------^/"
			]
			
			;replace/all lib "slim/register" "slim/register/header"
			vprint ["adding lib " lib-name ]
			append libs-txt rejoin [
				";-  ^/"
				";- ----------- ^/"
				";--------------------------------------------------------------------------------^/"
				";- ---> START: " uppercase to-string lib-name "  v" lib-ver "^/"
				";--------------------------------------------------------------------------------^/^/"
				"append slim/linked-libs '" lib-name  "^/"
				"append/only slim/linked-libs [^/"
				"^/^/;--------^/;-   MODULE CODE^/"
				
				replace/all lib "slim/register" "slim/register/header"
				
				"^/^/;--------^/;-   SLIM HEADER^/"
				script-header head lib
				
				;print "###"
				
				"]^/^/"
	
	
				";--------------------------------------------------------------------------------^/"
				";- <--- END: " uppercase to-string lib-name "^/"
				";--------------------------------------------------------------------------------^/^/"
				"^/^/^/"
			]
			
			;append libs-txt 
			
		]
		
		
		vprint "###############################################################"
		vprint "###############################################################"
		vprint "###############################################################"
		
		; put the libs code between the header and code of the source
		insert source libs-txt
		
		if compressed [
			to-error "/compressed is current disabled."
;			code: script-body head data
;			
;			vprobe length? code
;			source: mold compress code
;			
;			vprobe length? source
;			
;			data: copy/part head data code
;			append data rejoin ["do decompress ^/ " source]
		]
		
		vprint "linked !"
		return head source
	]
]	



comment {

;-----------------------------------------------------------------------------------------
; The following shows how easy it is to link an application with slim libraries in it.
;

 slk: slim/open 'slim-link 0.0				; slim-link is a module itself.  This allows us to find slim.
 data: slk/link %/path/to/reblet.r			; actually create the linked file
 write %/path/to/linked/application.r data	; save it out !
 
 
 notes:
 -------
 slk/link supports file!, block!, and string! types, so you can build the 
 application code on the fly and link it dynamically...
 
 slim-link is not yet capable of tracing slim calls within libraries, so  
 if your libraries are loading libs... then the resulting app will not work.
 just add the missing libs to your main file, in any order.
 
 slim-link will make any feature available in slim available in your linked app
 including the resources directories.  The difference being that the context
 of the lib is now the application itself, so you must transport the 
 resource dirs relatively to the application.
 
}








	none

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

