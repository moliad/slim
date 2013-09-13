Slim libraries
======

This repository contains the core module and application control code to load, manipulate and link slim format libraries.

Just DO the slim.r file and then you have access to all the modules which are relative to it, and your application, as well as any %<application current-dir>/libs/ subfolder.

Also note that as of v1.2.1 of slim, when the slim.r file is directly within a folder called %slim/ it will change its current dir and load as if it when in the folder above, allowing it to load any module packages which are at the same level as the %slim/ folder. This makes it very easy to mix and match packages within other projects.

Note that slim is an integral part of all of my other projects and is (along with other lib packages) often included as a submodule of these.



Documentation
-------

current documentation can be found in the wiki here:

https://github.com/moliad/slim-libs/wiki

