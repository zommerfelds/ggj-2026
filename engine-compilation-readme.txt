The optimized release uses minimized HTML templates, built from the Godot source
and placed in the html_templates directory. Basic steps to build it:

$ DIR=/path/to/ggj-2026

$ mkdir -p "${DIR}/html_templates"

$ cd /path/to/godot_source/

# Math the commit of the Godot release you use:
$ git switch --detach 4.6-stable

$ scons \
	platform=web \
	target=template_release \
	optimize=size \
	threads=no \
	build_profile="${DIR}/engine-compilation.build"

$ cp \
	bin/godot.web.template_release.wasm32.nothreads.zip \
	${DIR}/html_templates



If the project starts using new dependencies, the JavaScript console will start
complaining about failing to load certain classes. In this case, the
engine-compilation.build needs to be updated. This can be done in Godot using the
[Project]->[Tools]->[Engine Compilation Configuration Editor], clicking
[Detect from Project]. Remember to Save, and then run the build steps above.



Full compilation docs:

https://docs.godotengine.org/en/stable/engine_details/development/compiling/index.html

