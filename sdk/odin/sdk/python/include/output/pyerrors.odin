package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Error handling definitions */
	PyErr_SetNone             :: proc() ---
	PyErr_SetObject           :: proc() ---
	PyErr_SetString           :: proc(exception: ^PyObject, _string: cstring) ---
	PyErr_Occurred            :: proc() -> ^PyObject ---
	PyErr_Clear               :: proc() ---
	PyErr_Fetch               :: proc() ---
	PyErr_Restore             :: proc() ---
	PyErr_GetRaisedException  :: proc() -> ^PyObject ---
	PyErr_SetRaisedException  :: proc() ---
	PyErr_GetHandledException :: proc() -> ^PyObject ---
	PyErr_SetHandledException :: proc() ---
	PyErr_GetExcInfo          :: proc() ---
	PyErr_SetExcInfo          :: proc() ---

	/* Defined in Python/pylifecycle.c
	
	The Py_FatalError() function is replaced with a macro which logs
	automatically the name of the current function, unless the Py_LIMITED_API
	macro is defined. */
	Py_FatalError :: proc(message: cstring) ---

	/* Error testing and normalization */
	PyErr_GivenExceptionMatches :: proc() -> i32 ---
	PyErr_ExceptionMatches      :: proc() -> i32 ---
	PyErr_NormalizeException    :: proc() ---

	/* Traceback manipulation (PEP 3134) */
	PyException_SetTraceback :: proc() -> i32 ---
	PyException_GetTraceback :: proc() -> ^PyObject ---

	/* Cause manipulation (PEP 3134) */
	PyException_GetCause :: proc() -> ^PyObject ---
	PyException_SetCause :: proc() ---

	/* Context manipulation (PEP 3134) */
	PyException_GetContext :: proc() -> ^PyObject ---
	PyException_SetContext :: proc() ---
	PyException_GetArgs    :: proc() -> ^PyObject ---
	PyException_SetArgs    :: proc() ---
	PyExceptionClass_Name  :: proc() -> cstring ---

	/* Convenience functions */
	PyErr_BadArgument                             :: proc() -> i32 ---
	PyErr_NoMemory                                :: proc() -> ^PyObject ---
	PyErr_SetFromErrno                            :: proc() -> ^PyObject ---
	PyErr_SetFromErrnoWithFilenameObject          :: proc() -> ^PyObject ---
	PyErr_SetFromErrnoWithFilenameObjects         :: proc() -> ^PyObject ---
	PyErr_SetFromErrnoWithFilename                :: proc(exc: ^PyObject, filename: cstring) -> ^PyObject ---
	PyErr_Format                                  :: proc(exception: ^PyObject, format: cstring) -> ^PyObject ---
	PyErr_FormatV                                 :: proc(exception: ^PyObject, format: cstring, vargs: ^c.va_list) -> ^PyObject ---
	PyErr_SetFromWindowsErrWithFilename           :: proc(ierr: i32, filename: cstring) -> ^PyObject ---
	PyErr_SetFromWindowsErr                       :: proc() -> ^PyObject ---
	PyErr_SetExcFromWindowsErrWithFilenameObject  :: proc() -> ^PyObject ---
	PyErr_SetExcFromWindowsErrWithFilenameObjects :: proc() -> ^PyObject ---
	PyErr_SetExcFromWindowsErrWithFilename        :: proc(exc: ^PyObject, ierr: i32, filename: cstring) -> ^PyObject ---
	PyErr_SetExcFromWindowsErr                    :: proc() -> ^PyObject ---
	PyErr_SetImportErrorSubclass                  :: proc() -> ^PyObject ---
	PyErr_SetImportError                          :: proc() -> ^PyObject ---

	/* Export the old function so that the existing API remains available: */
	PyErr_BadInternalCall  :: proc() ---
	PyErr_BadInternalCall :: proc(filename: cstring, lineno: i32) ---

	/* Function to create a new exception */
	PyErr_NewException        :: proc(name: cstring, base: ^PyObject, dict: ^PyObject) -> ^PyObject ---
	PyErr_NewExceptionWithDoc :: proc(name: cstring, doc: cstring, base: ^PyObject, dict: ^PyObject) -> ^PyObject ---
	PyErr_WriteUnraisable     :: proc() ---

	/* In signalmodule.c */
	PyErr_CheckSignals   :: proc() -> i32 ---
	PyErr_SetInterrupt   :: proc() ---
	PyErr_SetInterruptEx :: proc(signum: i32) -> i32 ---

	/* Support for adding program text to SyntaxErrors */
	PyErr_SyntaxLocation   :: proc(filename: cstring, lineno: i32) ---
	PyErr_SyntaxLocationEx :: proc(filename: cstring, lineno: i32, col_offset: i32) ---
	PyErr_ProgramText      :: proc(filename: cstring, lineno: i32) -> ^PyObject ---

	/* create a UnicodeDecodeError object */
	PyUnicodeDecodeError_Create :: proc(encoding: cstring, object: cstring, length: Py_ssize_t, start: Py_ssize_t, end: Py_ssize_t, reason: cstring) -> ^PyObject ---

	/* get the encoding attribute */
	PyUnicodeEncodeError_GetEncoding :: proc() -> ^PyObject ---
	PyUnicodeDecodeError_GetEncoding :: proc() -> ^PyObject ---

	/* get the object attribute */
	PyUnicodeEncodeError_GetObject    :: proc() -> ^PyObject ---
	PyUnicodeDecodeError_GetObject    :: proc() -> ^PyObject ---
	PyUnicodeTranslateError_GetObject :: proc() -> ^PyObject ---

	/* get the value of the start attribute (the int * may not be NULL)
	return 0 on success, -1 on failure */
	PyUnicodeEncodeError_GetStart    :: proc() -> i32 ---
	PyUnicodeDecodeError_GetStart    :: proc() -> i32 ---
	PyUnicodeTranslateError_GetStart :: proc() -> i32 ---

	/* assign a new value to the start attribute
	return 0 on success, -1 on failure */
	PyUnicodeEncodeError_SetStart    :: proc() -> i32 ---
	PyUnicodeDecodeError_SetStart    :: proc() -> i32 ---
	PyUnicodeTranslateError_SetStart :: proc() -> i32 ---

	/* get the value of the end attribute (the int *may not be NULL)
	return 0 on success, -1 on failure */
	PyUnicodeEncodeError_GetEnd    :: proc() -> i32 ---
	PyUnicodeDecodeError_GetEnd    :: proc() -> i32 ---
	PyUnicodeTranslateError_GetEnd :: proc() -> i32 ---

	/* assign a new value to the end attribute
	return 0 on success, -1 on failure */
	PyUnicodeEncodeError_SetEnd    :: proc() -> i32 ---
	PyUnicodeDecodeError_SetEnd    :: proc() -> i32 ---
	PyUnicodeTranslateError_SetEnd :: proc() -> i32 ---

	/* get the value of the reason attribute */
	PyUnicodeEncodeError_GetReason    :: proc() -> ^PyObject ---
	PyUnicodeDecodeError_GetReason    :: proc() -> ^PyObject ---
	PyUnicodeTranslateError_GetReason :: proc() -> ^PyObject ---

	/* assign a new value to the reason attribute
	return 0 on success, -1 on failure */
	PyUnicodeEncodeError_SetReason    :: proc(exc: ^PyObject, reason: cstring) -> i32 ---
	PyUnicodeDecodeError_SetReason    :: proc(exc: ^PyObject, reason: cstring) -> i32 ---
	PyUnicodeTranslateError_SetReason :: proc(exc: ^PyObject, reason: cstring) -> i32 ---
	PyOS_snprintf                     :: proc(str: cstring, size: uint, format: cstring) -> i32 ---
	PyOS_vsnprintf                    :: proc(str: cstring, size: uint, format: cstring, va: ^c.va_list) -> i32 ---
}
