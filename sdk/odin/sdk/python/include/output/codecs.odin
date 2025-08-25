package pkg





@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Register a new codec search function.
	
	As side effect, this tries to load the encodings package, if not
	yet done, to make sure that it is always first in the list of
	search functions.
	
	The search_function's refcount is incremented by this function. */
	PyCodec_Register :: proc(search_function: ^PyObject) -> i32 ---

	/* Unregister a codec search function and clear the registry's cache.
	If the search function is not registered, do nothing.
	Return 0 on success. Raise an exception and return -1 on error. */
	PyCodec_Unregister :: proc(search_function: ^PyObject) -> i32 ---
	PyCodec_Lookup    :: proc(encoding: cstring) -> ^PyObject ---
	PyCodec_Forget    :: proc(encoding: cstring) -> i32 ---

	/* Codec registry encoding check API.
	
	Returns 1/0 depending on whether there is a registered codec for
	the given encoding.
	
	*/
	PyCodec_KnownEncoding :: proc(encoding: cstring) -> i32 ---

	/* Generic codec based encoding API.
	
	object is passed through the encoder function found for the given
	encoding using the error handling method defined by errors. errors
	may be NULL to use the default method defined for the codec.
	
	Raises a LookupError in case no encoder can be found.
	
	*/
	PyCodec_Encode :: proc(object: ^PyObject, encoding: cstring, errors: cstring) -> ^PyObject ---

	/* Generic codec based decoding API.
	
	object is passed through the decoder function found for the given
	encoding using the error handling method defined by errors. errors
	may be NULL to use the default method defined for the codec.
	
	Raises a LookupError in case no encoder can be found.
	
	*/
	PyCodec_Decode :: proc(object: ^PyObject, encoding: cstring, errors: cstring) -> ^PyObject ---

	/* Text codec specific encoding and decoding API.
	
	Checks the encoding against a list of codecs which do not
	implement a str<->bytes encoding before attempting the
	operation.
	
	Please note that these APIs are internal and should not
	be used in Python C extensions.
	
	XXX (ncoghlan): should we make these, or something like them, public
	in Python 3.5+?
	
	*/
	PyCodec_LookupTextEncoding :: proc(encoding: cstring, alternate_command: cstring) -> ^PyObject ---
	PyCodec_EncodeText         :: proc(object: ^PyObject, encoding: cstring, errors: cstring) -> ^PyObject ---
	PyCodec_DecodeText         :: proc(object: ^PyObject, encoding: cstring, errors: cstring) -> ^PyObject ---

	/* These two aren't actually text encoding specific, but _io.TextIOWrapper
	* is the only current API consumer.
	*/
	PyCodecInfo_GetIncrementalDecoder :: proc(codec_info: ^PyObject, errors: cstring) -> ^PyObject ---
	PyCodecInfo_GetIncrementalEncoder :: proc(codec_info: ^PyObject, errors: cstring) -> ^PyObject ---

	/* Get an encoder function for the given encoding. */
	PyCodec_Encoder :: proc(encoding: cstring) -> ^PyObject ---

	/* Get a decoder function for the given encoding. */
	PyCodec_Decoder :: proc(encoding: cstring) -> ^PyObject ---

	/* Get an IncrementalEncoder object for the given encoding. */
	PyCodec_IncrementalEncoder :: proc(encoding: cstring, errors: cstring) -> ^PyObject ---

	/* Get an IncrementalDecoder object function for the given encoding. */
	PyCodec_IncrementalDecoder :: proc(encoding: cstring, errors: cstring) -> ^PyObject ---

	/* Get a StreamReader factory function for the given encoding. */
	PyCodec_StreamReader :: proc(encoding: cstring, stream: ^PyObject, errors: cstring) -> ^PyObject ---

	/* Get a StreamWriter factory function for the given encoding. */
	PyCodec_StreamWriter :: proc(encoding: cstring, stream: ^PyObject, errors: cstring) -> ^PyObject ---

	/* Register the error handling callback function error under the given
	name. This function will be called by the codec when it encounters
	unencodable characters/undecodable bytes and doesn't know the
	callback name, when name is specified as the error parameter
	in the call to the encode/decode function.
	Return 0 on success, -1 on error */
	PyCodec_RegisterError :: proc(name: cstring, error: ^PyObject) -> i32 ---

	/* Lookup the error handling callback function registered under the given
	name. As a special case NULL can be passed, in which case
	the error handling callback for "strict" will be returned. */
	PyCodec_LookupError :: proc(name: cstring) -> ^PyObject ---

	/* raise exc as an exception */
	PyCodec_StrictErrors :: proc(exc: ^PyObject) -> ^PyObject ---

	/* ignore the unicode error, skipping the faulty input */
	PyCodec_IgnoreErrors :: proc(exc: ^PyObject) -> ^PyObject ---

	/* replace the unicode encode error with ? or U+FFFD */
	PyCodec_ReplaceErrors :: proc(exc: ^PyObject) -> ^PyObject ---

	/* replace the unicode encode error with XML character references */
	PyCodec_XMLCharRefReplaceErrors :: proc(exc: ^PyObject) -> ^PyObject ---

	/* replace the unicode encode error with backslash escapes (\x, \u and \U) */
	PyCodec_BackslashReplaceErrors :: proc(exc: ^PyObject) -> ^PyObject ---

	/* replace the unicode encode error with backslash escapes (\N, \x, \u and \U) */
	PyCodec_NameReplaceErrors :: proc(exc: ^PyObject) -> ^PyObject ---
}
