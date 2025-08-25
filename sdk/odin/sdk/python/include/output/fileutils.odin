package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	Py_DecodeLocale :: proc(arg: cstring, size: ^uint) -> ^wchar_t ---
	Py_EncodeLocale :: proc(text: ^wchar_t, error_pos: ^uint) -> cstring ---
}
