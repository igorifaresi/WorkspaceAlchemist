@echo off
clang-cl /c python-odin.c /Iinclude
llvm-lib /out:python-odin.lib python-odin.obj
