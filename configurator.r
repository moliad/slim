rebol [
	; -- Core Header attributes --
	title: "SLIM | Application Configuration system"
	file: %configurator.r
	version: 1.0.3
	date: 2015-06-24
	author: "Maxim Olivier-Adlhoch"
	purpose: {Easy, Safe, Extensible, Auto-documenting, File-based, configuration management.}
	web: http://www.revault.org/modules/configurator.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'configurator
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/configurator.r

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
		0.1.0 - 2008-09-11 - MOA
			-created
			-basic set(), get(), apply() methods
			-added space-filled
			-clone(), copy()
			-added protection
			-probe()
			-added concealment
			-added docs
			-help()
			-specific version adapted to QuickShot...
		
		DOZENS OF VERSIONS GO BY... MANY FEATURES ADDED  ( without history ':-/ )
		
		v1.0.0 - 2012-02-17 - MOA
			-added the configure stub  which takes a spec and returns a !config object.
			
		v1.0.1 - 2012-02-27 - MOA
			-added /required to from-disk() function
			-wrapped from-disk within a try block and added /ignore-failed to suppress errors if we don't really care if the file is valid.
			-added a default storage-path value.
	
		v1.0.2 - 2013-09-12
			-changed license to Apache v2

		v1.0.3 - 2015-06-24
			-added resolve-path()  now all disk i/o is mapped and fixed to application path.
	}
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
; test-enter-slim 'configurator
;
;--------------------------------------

slim/register [
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	 
	slim/open/expose 'utils-files none [ as-file  filename-of  directory-of   absolute-path?]
	slim/open/expose 'utils-strings none [ fill ]
	slim/open/expose 'utils-script none  [ get-application-path ]
	 
	*copy: get in system/words 'copy
	*mold: get in system/words 'mold
	*get: get in system/words 'get
	*probe: get in system/words 'probe
	
	whitespace: charset "^/^- "

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-    default-store-path:
	;
	; unless manually set, this path will be used the first time any file-io is attempted on
	; a !config instance.
	;
	; the way this is setup, you should now always get the proper path from the script which
	; launched rebol, or a relative path, when rebol isn't launched from a script.
	;
	; since this is statically set when the module is first loaded, it will be the same across
	; all calls to configure, even when it is called from a script loaded from another script.
	;--------------------------
	default-store-path: join ( any [ get-application-path  %./ ] ) %app-config.cfg
	
	


	;- !CONFIG [...]
	; note that tags surrounded by '--' (--tag--) aren't meant to be substituted within the apply command.
	!config: context [
		!config?: true 
	
		;- INTERNALS
		
		;-    store-path:
		; we the default-store-path when left to none just to make it uber easy for those who don't care
		; (this is useful when evaluation for example)
		store-path: none

		;-    app-label:
		; use this in output related strings like when storing to disk
		app-label: none
		
		;-------------------------------
		;-    -- object-based internals
		;-------------------------------
		
		;-----------------
		;-    tags:
		; a context of values 
		;-----------------
		tags: none
		
		;-----------------
		;-    save-point:
		; a save point of tags which can be restored later
		; NOTE: saves only the tags (on purpose).
		;-----------------
		save-point: none
		
		;-----------------
		;-    dynamic:
		; this is a list of tags which are only use when apply is called, they are in fact driven
		; by a function, cannot be set, but can be get.  are not part of any other aspect of configurator
		; like disk, copy, backup, etc.
		;
		; clone will duplicate the dynamic tags to the new !config
		;-----------------
		dynamic: none
		
		;-----------------
		;-    defaults:
		; a save point which can only every be set once, includes concealed tags.
		; use snapshot-defaults() to set defaults.
		; use reset() to go back to these values
		;
		; NOTE: saves only the tags (on purpose).
		;-----------------
		defaults: none
		
		;-----------------
		;-    docs:
		; any tags in this list can be called upon for documentation
		;
		; various functions may include these help strings (mold, probe, etc)
		;-----------------
		docs: none
		
		;-----------------
		;-    types:
		; some tags might require to be bound to specific datatypes.
		; this is useful for storage and reloading... enforcing integrity of disk-loaded configs.
		;
		; <TO DO> still work in progress.
		;-----------------
		types: none
		
		;-------------------------------
		;-    -- block-based internals
		;-    protected:
		; tags which cannot be overidden.
		;-----------------
		protected: none
		
		;-----------------
		;-    concealed:
		; tags which aren't probed, saved or loaded
		;-----------------
		concealed: none
		
		;-----------------
		;-    space-filled:
		; tags which cannot *EVER* contain whitespaces.
		;-----------------
		space-filled: none
		
		
		;-                                                                                                       .
		;-----------------------------------------------------------------------------------------------------------
		;
		;- FIELD RELATED METHODS
		;
		;-----------------------------------------------------------------------------------------------------------
		
		;-----------------
		;-    protect()
		;-----------------
		protect: func [
			tags [word! block!]
			/local tag
		][
			vin [{!config/protect()}]
			
			tags: compose [(tags)]
			foreach tag tags [
				vprint join "protecting: " tag
				; only append if its not already there
				any [
					find protected tag
					append protected tag
				]
			]
			tags: tag: none
			vout
		]
		
		
		;-----------------
		;-    protected?()
		;-----------------
		protected?: func [
			tag [word!]
		][
			vin [{!config/protected?()}]
			vprobe tag
			vout/return
			vprobe found? find protected tag
		]
		
		
		;-----------------
		;-    conceal()
		;-----------------
		conceal: func [
			tags [word! block!]
			/local tag
		][
			vin [{!config/conceal()}]
			
			tags: compose [(tags)]
			foreach tag tags [
				vprint rejoin ["concealing: " tag]
				; only append if its not already there
				any [
					find concealed tag
					append concealed tag
				]
			]
			tags: tag: none
			vout
		]
		
		
		;-----------------
		;-    concealed?()
		;-----------------
		concealed?: func [
			tag [word!]
		][
			vin [{!config/concealed?()}]
			vprobe tag
			vout/return
			vprobe found? find self/concealed tag
		]
		
		
		;-----------------
		;-    cast()
		;-----------------
		; force !config to fit tags within specific datatype
		;-----------------
		cast: func [
			tag [word!]
			type [word! block!] "note these are pseudo types, starting with the ! (ex !state) not actual datatype! "
		][
			vin [{!config/cast()}]
			unless set? tag [
				to-error rejoin ["!config/cast(): tag '" tag " doesn't exist in config, cannot cast it to a datatype"]
			]
			type: compose [(type)]
			types: make types reduce [to-lit-word tag type]
			vout
		]
		
		
		
		;-----------------
		;-    typed?()
		;-----------------
		; is this tag currently type cast?
		;-----------------
		typed?: func [
			tag [word!]
		][
			;vin [{!config/typed?()}]
			found? in types tag
			;vout
		]
		
		
		;-----------------
		;-    proper-type?()
		;-----------------
		; if tag currently typed?, verify it.  Otherwise return none.
		;-----------------
		proper-type?: func [
			tag [word!]
			/value val
		][
			;vin [{!config/proper-type?()}]
			val: either value [val][get tag]
			any [
				all [typed? tag find types type?/word val ]
				true
			]
			;vout
		]
		
		
		
		
		;-----------------
		;-    fill-spaces()
		;-----------------
		; prevent this tag from ever containing any whitespaces.
		;-----------------
		fill-spaces: func [
			tag [word!]
		][
			vin [{!config/fill-spaces()}]
			unless find space-filled tag [
				append space-filled tag
				; its possible to call this before even adding tag to config
				if set? tag [
					set tag get tag ; this will enforce fill-space right now
				]
			]
			vout
		]
		
		;-----------------
		;-    space-filled?()
		;-----------------
		space-filled?: func [
			tag [word!]
		][
			vin [{!config/space-filled?()}]
			vprint tag
			vprobe tag: found? find space-filled tag
			vout
			tag
		]
		
		
		
		
		;--------------------------
		;-    increment()
		;--------------------------
		; purpose:  
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    -fastest safe method to increment a value.  
		;           -currently bypasses the data-hiding interface.
		;
		; tests:    
		;--------------------------
		increment: funcl [
			tag [word!]
		][
			vin "!config/increment()"
			unless attempt [
				set in tags tag (1 + any [(get in tags tag) 0 ])
			][
				to-error rejoin ["!config/increment(): tag '" tag " cannot be incremented (invalid tag or value)."]
			]
			vout
		]
		
		
		
		;-----------------
		;-    set()
		;
		; set a tag value, add the tag if its not yet there.
		;
		; ignored if the tag is protected.
		;-----------------
		set: func [
			tag [word!]
			value
			/type types [word! block!] "immediately cast the tag to some type"
			/doc docstr [string!] "immediately set the help for this tag"
			/overide "ignores protection, only for use within distrobot... code using the !config should not have acces to this."
			/conceal "immediately call conceal on the tag"
			/protect "immediately call protect on the tag"
			/local here
		][
			vin [{!config/set()}]
			vprobe tag
			
			
			either all [not overide protected? tag] [
				; <TODO> REPORT ERROR
				vprint/error rejoin ["CANNOT SET CONFIG: <" tag "> IS protected"]
			][
				either function? :value [
					; this is a dynamic tag, its evaluated, not stored.
					self/dynamic: make self/dynamic reduce [to-set-word tag none ]
					self/dynamic/:tag: :value
				][
					any [
						in tags tag
						;tags: make tags reduce [load rejoin ["[ " tag ": none ]"]
						tags: make tags reduce [to-set-word tag none ]
					]
					
					; replace any whitespaces by a dash.
					if space-filled? tag [
						value: to-string value
						parse/all value [any [ [here: whitespace ( change here "-")] | skip ] ]
					]
					
					;v?? tags
					tags/:tag: :value
				]
			]
			if conceal [
				self/conceal tag
			]
			
			if protect [
				self/protect tag
			]
			
			if doc [
				document tag docstr
			]
			
			if type [
				cast tag types
			]
			
			vout
			value
		]
		
		
		;-----------------
		;-    set?()
		;-----------------
		set?: func [
			tag [word!]
		][
			vin [{!config/set?()}]
			vprobe tag
			vout
			found? in tags tag
		]
		
		
		;-----------------
		;-    document()
		;-----------------
		document: func [
			tag [word!]
			doc [string!]
		][
			vin [{!config/document()}]
			vprobe tag
			unless set? tag [
				to-error rejoin ["!config/document(): tag '" tag " doesn't exist in config, cannot set its document string"]
			]
			docs: make docs reduce [to-set-word tag doc]
			vout
		]
		
		
		;-----------------
		;-    help()
		;-----------------
		help: func [
			tag [word!]
		][
			vin [{!config/help()}]
			vprobe tag
			vout
			*get in docs tag
		]
		
		
		
		
		;-----------------
		;-    get()
		;-----------------
		get: func [
			tag [word!]
		][
			vin [{!config/get()}]
			vprobe tag
			vout
			either (in dynamic tag) [
				dynamic/:tag
			][
				*get in tags tag
			]
		]
		
		
		
		
		;-----------------
		;-    apply()
		;
		; given a source string, will replace all tags which match some config items with their config values
		; so given: "bla <tag> bla"  and a config named tag with value "poo" will become "bla poo bla"
		;
		; <TODO> make function recursive
		;-----------------
		apply: func [
			data [string! file! word!] ; eventually support other types?
			/only this [word! block!] "only apply one or a set of specific configs"
			/reduce "Applies config to some config item"
			/file "corrects applied data so that file paths are corrected"
			/local tag lbl tmp
		][
			vin [{!config/apply()}]

			; loads the tag, if reduce is specified, or uses the data directly
			data: any [all [reduce tags/:data] data]
			
			v?? data
			
			this: any [
				all [
					only 
					compose [(this)]
				]
				self/list/dynamic
			]
			
			foreach tag this [
				lbl: to-string tag
				; don't apply the tag to itself, if reduce is used!
				unless all [reduce tag = data][
					; skip internal configs
					unless all [lbl/1 = #"-" lbl/2 = #"-"] [
						tmp: get tag
						;print "#####"
						;?? tmp
						;print ""
						replace/all data rejoin ["<" lbl ">"] to-string tmp
					]
				]
			]
			vout
			if file [
				tmp: as-file *copy data
				clear head data
				append data tmp
			]
			data
		]
		
		
		;-----------------
		;-    copy()
		;-----------------
		; create or resets a tag out of another
		;-----------------
		copy: func [
			from [word!]
			to [word!]
		][
			vin [{!config/copy()}]
			set to get from
			vout
		]
		
		
		;-----------------
		;-    as-file()
		;-----------------
		; convert a tag to a rebol file! type
		;
		; OS or rebol type paths, as well as string or file are valid as current tag data.
		;-----------------
		as-file: func [
			tag [word!]
			/local value
		][
			vin [{as-file()}]
			set tag value: as-file get tag
			vout
			value
		]
		
		
		;-----------------
		;-    delete()
		; remote a tag from configs
		;-----------------
		; <TODO> also remove from other internals: protected, concealed, etc.
		; <TODO> later features might needed to be better reflected in this function
		;-----------------
		delete: func [
			tag [word!]
			/local spec
		][
			vin [{!config/delete()}]
			spec: third tags
			
			if spec: find spec to-set-word tag [
				remove/part  spec 2
				tags: context head spec
			]
			vout
		]
		
		
		;-----------------
		;-    probe()
		;-----------------
		; print a status of the config in console...usefull for debugging
		;-----------------
		probe: func [
			/unsorted
			/full "include document strings in probe"
			/local pt tag v
		][
			vin [{!config/probe()}]
			v: verbose
			verbose: no
			foreach tag any [all [unsorted next first tags] sort next first tags] [
				unless concealed? tag [ 
					either full [
						vprint/always         "+-----------------" 
						vprint/always rejoin ["| " tag ":"]
						vprint/always         "|"
						vprint/always rejoin ["|     " head replace/all any [help tag ""]  "^/" "^/|     "]
						vprint/always         "|"
						;vprint/always rejoin ["|     "  *copy/part  replace/all replace/all *mold/all tags/:tag "^/" " " "^-" " " 80]
						vprint/always rejoin ["|     "  *copy/part  replace/all replace/all *mold/all get tag "^/" " " "^-" " " 80]
						vprint/always         "+-----------------" 
					][
						vprint/always rejoin [ fill/with to-string tag 22 "_" ": " *copy/part  replace/all replace/all *mold/all get tag "^/" " " "^-" " " 80]
					]
				]
				;vprint ""
			]
			pt: form protected
			either empty? pt [
				vprint/always ["+------------------" fill/with "" (1 + (length? pt)) "-" "+"]
				vprint/always ["| No Protected tags |"]
				vprint/always ["+------------------" fill/with "" (1 + (length? pt)) "-" "+"]
			][	
				vprint/always ["+-----------------" fill/with "" (1 + (length? pt)) "-" "+"]
				vprint/always ["| Protected tags: " pt " |"]
				vprint/always ["+-----------------" fill/with "" (1 + (length? pt)) "-" "+"]
			]
			verbose: v
			vout
		]
		
		
		;-----------------
		;-    list()
		;-----------------
		; list tags reflecting options.
		;-----------------
		list: func [
			/opt options "supply folowing args using block of options"
			/safe "don't list protected"
			/visible "don't list concealed"
			/dynamic "Also list dynamic"
			/local ignore list
		][
			vin [{!config/list()}]
			
			ignore: clear [] ; reuse the same block everytime.
			
			
			options: any [options []]
			
			if any [
				visible
				find options 'visible
			][
				append ignore concealed
			]
			
			if any [
				safe
				find options 'safe
			][
				append ignore protected
			]
			
			list: words-of tags
			
			if dynamic [
				append list next first self/dynamic
			]
			
			vout
			exclude sort list ignore
		]
		
		
		;-----------------
		;-    mold()
		;-----------------
		; coverts the tags to a reloadable string, excluding any kind of evaluatable code.
		;
		; concealed tags are not part of mold
		;
		; <TODO> make invalid-type recursive in blocks and when /relax is set
		;-----------------
		mold: func [
			/relax "allow dangerous types in mold"
			/using mold-method [function!] "special mold method, we give [tag data] pair to hook, and save out returned data or ignore tag if none is returned"
			/local tag invalid-types val output
		][
			vin [{!config/mold()}]
			output: *copy ""
			invalid-types: any [
				all [relax []]
				[function! object!]
			]
			
			; we don't accumulate concealed tags
			foreach tag list/visible [
				val: get tag
				append output either using [
					vprobe tag
					vprobe mold-method tag val
				][
					
					if find invalid-types type?/word val [
						to-error "!config/mold(): Dangerous datatype not allowed in mold, use /relax if needed"
					]
					rejoin [
						";-----------------------^/"
						"; " head replace/all any [help tag ""]  "^/" "^/; "
						"^/;-----------------------^/"
						tag ": " *mold/all val "^/"
						"^/^/"
					]
				]
			]
			vout
			output
		]
		
		
		;-                                                                                                       .
		;-----------------------------------------------------------------------------------------------------------
		;
		;- FILE METHODS
		;
		;-----------------------------------------------------------------------------------------------------------


		;--------------------------
		;-    set-path()
		;--------------------------
		; purpose:  change the current file path to use for this config
		;
		; inputs:   if given a simple filename (no dir) then uses current dir or default-store-path dir.
		;
		; returns:  new path
		;
		; notes:    
		;
		; to do:    
		;
		; tests:    
		;--------------------------
		set-path: funcl [
			filepath [file!]
			/extern store-path
		][
			vin "set-path()"
			unless filename-of filepath [to-error "configurator/set-store-file() requires a filename in given filepath"]
			
			either absolute-path? filepath [
				store-path: clean-path filepath
			][
				dir: directory-of any [store-path default-store-path]
				store-path: clean-path join dir filepath
			]
			vout
			store-path
		]
		
		;--------------------------
		;-    resolve-path()
		;--------------------------
		; purpose:  given a file, resolve it to what it should be on disk, wether its local or absolute.
		;
		; inputs:   relative or absolute file! value
		;
		; returns:  an absolute file!
		;
		; notes:    like clean-path but uses application path instead
		;--------------------------
		resolve-path: funcl [
			path [file!]
		][
			vin "resolve-path()"
			v?? path
			unless absolute-path? path [
				path: join any [ get-application-path  %./ ] path
			]
			
			; removes and resolves any /./  or /../ from the path"
			path: clean-path path
			
			vout
			path
		]
		
				
		;--------------------------
		;-    on-disk?()
		;--------------------------
		; purpose:  detects if the config is currently on disk, using configurator path mechanics.
		;
		; inputs:   
		;
		; returns:  file! if the file exists, or none!.
		;
		; notes:    
		;
		; to do:    
		;
		; tests:    
		;--------------------------
		on-disk?: funcl [
			/using path [none! file!]
		][
			vin "configurator/on-disk?"
			path: any [
				path
				current-path
			]
			
			path: resolve-path path
			
			v?? path
			rval: all [
				exists? path
				path
			]
			vout
			
			rval
		]
		
		
		;--------------------------
		;-    current-path()
		;--------------------------
		; purpose:  returns dynamic current-path of the configuration, whatever the state of the config.
		;--------------------------
		current-path: funcl [
		][
			any [
				store-path
				default-store-path
			]
		]
		
		
		;--------------------------
		;-    needs-update?()
		;--------------------------
		; purpose:  does the on-disk config have the same attributes as the current config?
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    if the on disk 
		;
		; to do:    
		;
		; tests:    
		;--------------------------
		needs-update?: funcl [
			/using path [file!]
		][
			;vin "needs-update?()"
			not all [
				path: on-disk?/using path
				data: attempt [construct load path]
				list = words-of data
			]
			;vout
		]
		
		
		;-----------------
		;-    from-disk()
		;-----------------
		; note: any missing tags in disk prefs are filled-in with current values.
		;-----------------
		from-disk: func [
			/using path [file!]
			/create "Create tags comming from disk, dangerous, but useful when config is used as controlled storage."
			/required "Disk file is required, generate an error when it doesn't exist."
			/ignore-failed "If disk file wasn't readable, just ignore it without raising errors."
			/local err data
		][
			vin [{!config/from-disk()}]
			u-path: any [ path store-path ]
			
			v?? u-path
			if using [
				store-path: u-path
			]
			
			either path: on-disk?/using u-path [
				v?? path
				; silently ignore missing file
				either on-disk? [
					vprint "path exists"
					either error? err: try [
						data: construct load path
					][
						;----
						; loading failed
						err: disarm err
						unless ignore-failed [
							print err: rejoin ["------------------------^/" app-label " Error!^/------------------------^/Configuration file isn't loadable (syntax error): " to-local-file clean-path path "^/" err]
							to-error "CONFIGURATOR/from-disk()"
						]
					][
						;----
						; loading succeeded
						either create [
							restore/using/keep-unrefered/create data
						][
							restore/using/keep-unrefered data
						]
					]
				][
					vprint "File doesn't exist"
					if required [
						to-error rejoin [ "CONFIGURATOR/from-disk(): required configuration file doesn't exist:" to-local-file path]
					]
				]
			][
				vprobe "CONFIGURATOR/from-disk(): no configuration found on disk."
			]
			
			; remember filename
			vout
		]

		
		
		
		;-----------------
		;-    to-disk()
		;-----------------
		
		to-disk: func [
			/to path [file!]
			/relax
			/only hook [function!] "only save out some of the data, will apply mold-hook, relax MUST also be specified"
			/local tag
		][
			vin [{!config/to-disk()}]
			either path: any [
				path
				store-path
				default-store-path
			][
				path: resolve-path path
				app-label: any [app-label ""]
				
				data: trim rejoin [
					";---------------------------------" newline
					"; " app-label " configuration file" newline
					"; saved: " now/date newline
					"; version: " system/script/header/version newline
					";---------------------------------" newline
					newline
					any [
						all [only relax mold/relax/using :hook]
						all [relax mold/relax]
						mold
					]
				]
					
				
				;vprobe/always data
				
				;v?? path
				
				write path data
			][
				to-error "!CONFIGURATOR/to-disk(): STORE-PATH not set"
			
			]
			vout
		]
		
		

		;-                                                                                                       .
		;-----------------------------------------------------------------------------------------------------------
		;
		;- SETUP, STOREPOINTS AND CREATION
		;
		;-----------------------------------------------------------------------------------------------------------
		
				
		
		;-----------------
		;-    init()
		;-----------------
		init: func [
		][
			vin [{!config/init()}]
			tags: context []
			save-point: none
			defaults: none
			types: context []
			docs: context []
			concealed: *copy []
			protected: *copy []
			space-filled: *copy []
			dynamic: context []
			vout
		]


		;-----------------
		;-    clone()
		;-----------------
		; take a !config and create a deep copy of it
		;-----------------
		clone: func [][
			vin [{!config/clone()}]
			vout
			make self [
				tags: make tags []
				types: make types []
				docs: make docs []
				dynamic: make dynamic []
				
				if defaults [
					defaults: make defaults []
				]
				
				if save-point [
					save-point: make save-point []
				]
				
				; series copying is intrinsic to make object. 
				;  protected 
				;  error-modes
				; space-filled
			]
		]
		
		
		;-----------------
		;-    backup()
		;-----------------
		; puts a copy of current tags info in store-point.
		;-----------------
		backup: func [
		][
			vin [{!config/backup()}]
			save-point: make tags []
			vout
		]
		
		
		;-----------------
		;-    restore()
		;-----------------
		; restore the tags to an earlier or default state 
		;
		; not
		;
		; NB: -the tags are copied from the reference state... the tags object
		;      itself is NOT replaced.
		;     -if a ref-tags is used and it has new unknown tags, they are ignored
		;
		; WARNING: when called, we LOOSE current tags data
		;
		; <TODO>: enforce types?.  In the meanwhile, we silently use the ref-tags directly.
		;-----------------
		restore: func [
			/visible "do not restore concealed values."
			/safe "do not restore protected values."
			/reset "restore to defaults instead of save-point,  WARNING!!: also clears save-point."
			/using ref-tags [object!] "Manually supply a set of tags to use... mutually exclusive to /reset, this one has more strength."
			/create "new tags should be created from ref-tags."
			/keep-unrefered "Any tags which are missing in ref-tags, default or save point are not cleared."
			/local tag tag-list val ref-words
		][
			vin [{!config/restore()}]
			
			tag-list: list/opt reduce [either visible ['visible][] either safe ['safe][]]
			;v?? tag-list
			ref-tags: any [
				ref-tags
				either reset [
					save-point: none
					self/defaults
				][
					save-point ; configure function creates a save-point by default.
				]
			]
			vprint "restoring to:"
			;vprobe ref-tags
			if ref-tags [
				foreach tag any [
					all [
						create
						words-of ref-tags
					]
					tag-list
				][
					;?? tag
					if any [
						not keep-unrefered
						in ref-tags tag
						create
					][
						*get (in ref-tags tag)
						set/overide tag *get (in ref-tags tag)
					]
				]
			]
			vout
		]
		
		


		
		;-----------------
		;-    snapshot-defaults()
		;-----------------
		; captures current tags as the defaults.  
		; by default can only be called once.
		;
		; NB: series are NOT shared between tags... so you must NOT rely on config to be the 
		;     exact same? serie, but only an identical one (same value, but different reference).
		;-----------------
		snapshot-defaults: func [
			/overide "allows you to overide defaults if there are any... an unusual procedure"
		][
			vin [{snapshot-defaults()}]
			if any [
				overide
				none? defaults
			][
				defaults: make tags []
			]
			vout
		]
		
		
		;--------------------------
		;-    reset()
		;--------------------------
		; purpose:  go back to a copy of the default snapshot of your config
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    blocks may or may not be deep-copied. your snapshot should usually contain shallow datasets.
		;
		; tests:    
		;--------------------------
		reset: func [
		][
			vin "!config/reset()"
			either defaults [
				tags: make defaults []
			][
				to-error "CONFIGURATOR/reset(): no default to restore!"
			]
			vout
		]
		
	]
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- API
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-    configure()
	;--------------------------
	; purpose:  create a !config item from scratch using a simple spec, similar to objects
	;
	; inputs:   a block or none!, if you want an empty config.
	;
	; returns:  the new config.
	;
	; notes:    -raises an error if the spec is invalid.
	;           -automatically causes a snapshot-default before returning it.
	;
	; tests:    [   
	;               configure [version: 0.0.0 "current version"    date: 2012-02-20  "last changes"    private: #HHGEJJ29R88S   ]   ; note last item (private) isn't documented
	;           ]
	;--------------------------
	configure: funcl [
		spec [block! none!]
		/cfg configuration
		/no-snapshot
	][
		vin "configure()"
		cfg: any [
			configuration 
			make !config []
		]
		
		cfg/init
		
		item: none
		doc: none
		value: none
		
		if spec [
			reduce spec
			
			parse spec [
				some [
					here:
					;(print "==============================")
					;(probe copy/part here 3) 
					[
						set item set-word! 
						set value skip
						set doc opt string! 
						(
							item: to-word item
							cfg/set item value
							if doc [
								cfg/document item doc
							]
						)
					] 
				]
					
				| [
					(to-error probe {CONFIGURATOR.R/configure() invalid spec... ^/must be a flat block of  [word: value  "documentation" ...]^/    documentation is optional.})
					to end
				]
			]
			unless no-snapshot [
				cfg/snapshot-defaults
			]
		]
		
		vout
		cfg
	]
	

]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

