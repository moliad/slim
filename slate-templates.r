rebol [
	; -- Core Header attributes --
	title: "slate templates"
	file: %slate-templates.r
	version: 0.0.1
	date: 2018-10-4
	author: "Maxim Olivier-Adlhoch"
	purpose: "templates used by slate, slim's autodoc engine."
	web: http://www.revault.org/modules/slate-templates.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'slate-templates
	slim-version: 1.3.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/slate-templates.r

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
		v0.0.1 - 2018-10-04
			-lib created
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
; test-enter-slim 'slate-templates
;
;--------------------------------------

slim/register [
	;--------------------------
	;-     templates:
	;
	; stores all templates setup by client app.
	;
	; there are a few defined by default, but these can easily be replaced with the 
	; 'SETUP-TEMPLATE function
	;
	; note that some documentation setups can even allow you to use different, new
	; template names explicitely.
	;--------------------------
	templates: [	

		source-file 	{<!DOCTYPE html>
<html>
	<head>
		<title>##TITLE##</title>
	</head>

	<body>
	##site-menu##
	<h1>Welcome to slate documentation!</h1>
	<h2>Source file function dictionary</h2>
	##DICT-MENU##
	</body>

</html>
}

		 function {<!DOCTYPE html>
<html>
	<head>
		<title>##TITLE##</title>
	</head>

	<body>
	##site-menu##
	<h1>##FUNC-NAME##</h1>
	<h2>Source file function dictionary</h2>
	##DICT-MENU##
	</body>

</html>
}

		site-menu {<h5 class="site-menu">Slate-Generated automatic documentation</h5>}


		; refinement  {^-^-^-^-<h4 class="refinement-name">/##ARG-NAME##</h4>^/^-^-^-^-<p class="arg-description"> ##ARG-DOC## </p>^/}
		; argument    {^-^-^-^-<h4 class="##ARG-STYLE##">##ARG-NAME##  ##ARG-TYPES##</h4>^/^-^-^-^-<p class="arg-description"> ##ARG-DOC## </p>^/}
		; ##ARG-TYPES##
		;refinement  {^-^-^-^-<TR><h4 class="refinement-name">/##ARG-NAME##</h4>^/^-^-^-^-<p class="arg-description"> ##ARG-DOC## </p></TR>^/}
		;argument    {^-^-^-^-<TR><TD class="##CELL-ARG-STYLE##"><h4 class="##ARG-STYLE##">##ARG-NAME##</h4></TD><TD><p class="arg-description"> ##ARG-DOC## </p></TD></TR>^/}

		;refinement      {^-^-^-^-<TR><TD class="refinement-cell"><h4 class="refinement-name">/##REFINEMENT##</h4></TD><TD><p class="arg-description"> ##ARG-DOC## </p></TD></TR>^/}
		;refinement-arg  {^-^-^-^-<TR><TD class="refinement-cell"></TD><TD><p class="arg-description"> ##ARG-DOC## </p></TD></TR>^/}
		 
		;----
		; a required argument, simple and direct.
		;----
		argument
{<TR>
	<TD class="required-arg-cell"><h4 class="required-arg">##ARG-NAME##</h4></TD>
	<TD><p class="ref-docstring">##ARG-DOC## <br><span class="arg-types">(datatype allowed: ##ARG-TYPES## )</span></p></TD>
</TR>
}
		;----
		; this is used when the refinement has a doc string (with or without further args)
		;----
		refinement-doc
{<TR>
	<TD class="refinement-cell"><h4 class="refinement-name">/##REFINEMENT##</h4></TD>
	<TD><p class="ref-docstring">##REFINEMENT-DOC##</p></TD>
</TR>
}
		;----
		; this is used when the refinement DOES NOT HAVE a doc string with at least one arg
		; 
		; it is ALSO used on further lines, in this case the #REFINEMENT## value is empty.
		;----
		refinement-arg
{<TR>
	<TD class="refinement-cell"><h4 class="refinement-name">/##REFINEMENT##</h4></TD>
	<TD><p class="arg-description"><span class="refinement-arg">##ARG-NAME## : </span> ##ARG-DOC## <br><span class="arg-types">(datatype allowed: ##ARG-TYPES## )</span></p></TD>
</TR>
}






	]
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;-     FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-         get-template()
	;--------------------------
	; purpose:  retrieve a template from our list.
	;
	; inputs:   Name of template
	;
	; returns:  a string with preset string or none! if named template is not yet set.
	;
	; notes:    we always return a copy of the template, so you don't need to copy it again.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	get-template: funcl [
		name [word!] "Name of template"
	][
		vin "get-template()"
		tmplt: copy select templates name
		vout
		tmplt
	]

	;--------------------------
	;-         setup-template()
	;--------------------------
	; purpose:  modifies or adds a template to our list.
	;
	; inputs:   name and string data
	;
	; returns:  the data of the template
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	setup-template: funcl [
		name [word!] "tag name of the template, one of: [ index | site-menu | file-index | func-page]"
		data [string!] "string of text to use as the template"
	][
		vin "setup-template()"
		either select templates name [
			templates/(name): data
		][
			append templates reduce [name data]
		]
		vout
		data
	]
	
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------


