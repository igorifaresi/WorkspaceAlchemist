del builder.exe
odin build builder.odin -file -collection:sdk=sdk/odin -custom-attribute:plugin_callable && builder.exe %*
del builder.exe