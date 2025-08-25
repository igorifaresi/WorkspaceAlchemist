/* Abstract Object Interface (many thanks to Jim Fulton) */
package pkg

import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	/* Call a callable Python object without any arguments */
	PyObject_CallNoArgs :: proc(func: ^PyObject) -> ^PyObject ---

	/* Call a callable Python object 'callable' with arguments given by the
	tuple 'args' and keywords arguments given by the dictionary 'kwargs'.
	
	'args' must not be NULL, use an empty tuple if no arguments are
	needed. If no named arguments are needed, 'kwargs' can be NULL.
	
	This is the equivalent of the Python expression:
	callable(*args, **kwargs). */
	PyObject_Call :: proc(callable: ^PyObject, args: ^PyObject, kwargs: ^PyObject) -> ^PyObject ---

	/* Call a callable Python object 'callable', with arguments given by the
	tuple 'args'.  If no arguments are needed, then 'args' can be NULL.
	
	Returns the result of the call on success, or NULL on failure.
	
	This is the equivalent of the Python expression:
	callable(*args). */
	PyObject_CallObject :: proc(callable: ^PyObject, args: ^PyObject) -> ^PyObject ---

	/* Call a callable Python object, callable, with a variable number of C
	arguments. The C arguments are described using a mkvalue-style format
	string.
	
	The format may be NULL, indicating that no arguments are provided.
	
	Returns the result of the call on success, or NULL on failure.
	
	This is the equivalent of the Python expression:
	callable(arg1, arg2, ...). */
	PyObject_CallFunction :: proc(callable: ^PyObject, format: cstring) -> ^PyObject ---

	/* Call the method named 'name' of object 'obj' with a variable number of
	C arguments.  The C arguments are described by a mkvalue format string.
	
	The format can be NULL, indicating that no arguments are provided.
	
	Returns the result of the call on success, or NULL on failure.
	
	This is the equivalent of the Python expression:
	obj.name(arg1, arg2, ...). */
	PyObject_CallMethod          :: proc(obj: ^PyObject, name: cstring, format: cstring) -> ^PyObject ---
	PyObject_CallFunction_SizeT :: proc(callable: ^PyObject, format: cstring) -> ^PyObject ---
	PyObject_CallMethod_SizeT   :: proc(obj: ^PyObject, name: cstring, format: cstring) -> ^PyObject ---

	/* Call a callable Python object 'callable' with a variable number of C
	arguments. The C arguments are provided as PyObject* values, terminated
	by a NULL.
	
	Returns the result of the call on success, or NULL on failure.
	
	This is the equivalent of the Python expression:
	callable(arg1, arg2, ...). */
	PyObject_CallFunctionObjArgs :: proc(callable: ^PyObject) -> ^PyObject ---

	/* Call the method named 'name' of object 'obj' with a variable number of
	C arguments.  The C arguments are provided as PyObject* values, terminated
	by NULL.
	
	Returns the result of the call on success, or NULL on failure.
	
	This is the equivalent of the Python expression: obj.name(*args). */
	PyObject_CallMethodObjArgs :: proc(obj: ^PyObject, name: ^PyObject) -> ^PyObject ---

	/* Given a vectorcall nargsf argument, return the actual number of arguments.
	* (For use outside the limited API, this is re-defined as a static inline
	* function in cpython/abstract.h)
	*/
	PyVectorcall_NARGS :: proc(nargsf: uint) -> Py_ssize_t ---

	/* Call "callable" (which must support vectorcall) with positional arguments
	"tuple" and keyword arguments "dict". "dict" may also be NULL */
	PyVectorcall_Call :: proc(callable: ^PyObject, tuple: ^PyObject, dict: ^PyObject) -> ^PyObject ---

	/* Perform a PEP 590-style vector call on 'callable' */
	PyObject_Vectorcall :: proc(callable: ^PyObject, args: ^^PyObject, nargsf: uint, kwnames: ^PyObject) -> ^PyObject ---

	/* Call the method 'name' on args[0] with arguments in args[1..nargsf-1]. */
	PyObject_VectorcallMethod :: proc(name: ^PyObject, args: ^^PyObject, nargsf: uint, kwnames: ^PyObject) -> ^PyObject ---

	/* Get the type of an object.
	
	On success, returns a type object corresponding to the object type of object
	'o'. On failure, returns NULL.
	
	This is equivalent to the Python expression: type(o) */
	PyObject_Type :: proc(o: ^PyObject) -> ^PyObject ---

	/* Return the size of object 'o'.  If the object 'o' provides both sequence and
	mapping protocols, the sequence size is returned.
	
	On error, -1 is returned.
	
	This is the equivalent to the Python expression: len(o) */
	PyObject_Size   :: proc(o: ^PyObject) -> Py_ssize_t ---
	PyObject_Length :: proc(o: ^PyObject) -> Py_ssize_t ---

	/* Return element of 'o' corresponding to the object 'key'. Return NULL
	on failure.
	
	This is the equivalent of the Python expression: o[key] */
	PyObject_GetItem :: proc(o: ^PyObject, key: ^PyObject) -> ^PyObject ---

	/* Map the object 'key' to the value 'v' into 'o'.
	
	Raise an exception and return -1 on failure; return 0 on success.
	
	This is the equivalent of the Python statement: o[key]=v. */
	PyObject_SetItem :: proc(o: ^PyObject, key: ^PyObject, v: ^PyObject) -> i32 ---

	/* Remove the mapping for the string 'key' from the object 'o'.
	Returns -1 on failure.
	
	This is equivalent to the Python statement: del o[key]. */
	PyObject_DelItemString :: proc(o: ^PyObject, key: cstring) -> i32 ---

	/* Delete the mapping for the object 'key' from the object 'o'.
	Returns -1 on failure.
	
	This is the equivalent of the Python statement: del o[key]. */
	PyObject_DelItem :: proc(o: ^PyObject, key: ^PyObject) -> i32 ---

	/* Takes an arbitrary object which must support the (character, single segment)
	buffer interface and returns a pointer to a read-only memory location
	usable as character based input for subsequent processing.
	
	Return 0 on success.  buffer and buffer_len are only set in case no error
	occurs. Otherwise, -1 is returned and an exception set. */
	PyObject_AsCharBuffer :: proc(obj: ^PyObject, buffer: ^^u8, buffer_len: ^Py_ssize_t) -> i32 ---

	/* Checks whether an arbitrary object supports the (character, single segment)
	buffer interface.
	
	Returns 1 on success, 0 on failure. */
	PyObject_CheckReadBuffer :: proc(obj: ^PyObject) -> i32 ---

	/* Same as PyObject_AsCharBuffer() except that this API expects (readable,
	single segment) buffer interface and returns a pointer to a read-only memory
	location which can contain arbitrary data.
	
	0 is returned on success.  buffer and buffer_len are only set in case no
	error occurs.  Otherwise, -1 is returned and an exception set. */
	PyObject_AsReadBuffer :: proc(obj: ^PyObject, buffer: ^rawptr, buffer_len: ^Py_ssize_t) -> i32 ---

	/* Takes an arbitrary object which must support the (writable, single segment)
	buffer interface and returns a pointer to a writable memory location in
	buffer of size 'buffer_len'.
	
	Return 0 on success.  buffer and buffer_len are only set in case no error
	occurs. Otherwise, -1 is returned and an exception set. */
	PyObject_AsWriteBuffer :: proc(obj: ^PyObject, buffer: ^rawptr, buffer_len: ^Py_ssize_t) -> i32 ---

	/* Takes an arbitrary object and returns the result of calling
	obj.__format__(format_spec). */
	PyObject_Format :: proc(obj: ^PyObject, format_spec: ^PyObject) -> ^PyObject ---

	/* Takes an object and returns an iterator for it.
	This is typically a new iterator but if the argument is an iterator, this
	returns itself. */
	PyObject_GetIter :: proc() -> ^PyObject ---

	/* Takes an AsyncIterable object and returns an AsyncIterator for it.
	This is typically a new iterator but if the argument is an AsyncIterator,
	this returns itself. */
	PyObject_GetAIter :: proc() -> ^PyObject ---

	/* Returns non-zero if the object 'obj' provides iterator protocols, and 0 otherwise.
	
	This function always succeeds. */
	PyIter_Check :: proc() -> i32 ---

	/* Returns non-zero if the object 'obj' provides AsyncIterator protocols, and 0 otherwise.
	
	This function always succeeds. */
	PyAIter_Check :: proc() -> i32 ---

	/* Takes an iterator object and calls its tp_iternext slot,
	returning the next value.
	
	If the iterator is exhausted, this returns NULL without setting an
	exception.
	
	NULL with an exception means an error occurred. */
	PyIter_Next :: proc() -> ^PyObject ---

	/* Takes generator, coroutine or iterator object and sends the value into it.
	Returns:
	- PYGEN_RETURN (0) if generator has returned.
	'result' parameter is filled with return value
	- PYGEN_ERROR (-1) if exception was raised.
	'result' parameter is NULL
	- PYGEN_NEXT (1) if generator has yielded.
	'result' parameter is filled with yielded value. */
	PyIter_Send :: proc() -> PySendResult ---

	/* Returns 1 if the object 'o' provides numeric protocols, and 0 otherwise.
	
	This function always succeeds. */
	PyNumber_Check :: proc(o: ^PyObject) -> i32 ---

	/* Returns the result of adding o1 and o2, or NULL on failure.
	
	This is the equivalent of the Python expression: o1 + o2. */
	PyNumber_Add :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of subtracting o2 from o1, or NULL on failure.
	
	This is the equivalent of the Python expression: o1 - o2. */
	PyNumber_Subtract :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of multiplying o1 and o2, or NULL on failure.
	
	This is the equivalent of the Python expression: o1 * o2. */
	PyNumber_Multiply :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* This is the equivalent of the Python expression: o1 @ o2. */
	PyNumber_MatrixMultiply :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of dividing o1 by o2 giving an integral result,
	or NULL on failure.
	
	This is the equivalent of the Python expression: o1 // o2. */
	PyNumber_FloorDivide :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of dividing o1 by o2 giving a float result, or NULL on
	failure.
	
	This is the equivalent of the Python expression: o1 / o2. */
	PyNumber_TrueDivide :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the remainder of dividing o1 by o2, or NULL on failure.
	
	This is the equivalent of the Python expression: o1 % o2. */
	PyNumber_Remainder :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* See the built-in function divmod.
	
	Returns NULL on failure.
	
	This is the equivalent of the Python expression: divmod(o1, o2). */
	PyNumber_Divmod :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* See the built-in function pow. Returns NULL on failure.
	
	This is the equivalent of the Python expression: pow(o1, o2, o3),
	where o3 is optional. */
	PyNumber_Power :: proc(o1: ^PyObject, o2: ^PyObject, o3: ^PyObject) -> ^PyObject ---

	/* Returns the negation of o on success, or NULL on failure.
	
	This is the equivalent of the Python expression: -o. */
	PyNumber_Negative :: proc(o: ^PyObject) -> ^PyObject ---

	/* Returns the positive of o on success, or NULL on failure.
	
	This is the equivalent of the Python expression: +o. */
	PyNumber_Positive :: proc(o: ^PyObject) -> ^PyObject ---

	/* Returns the absolute value of 'o', or NULL on failure.
	
	This is the equivalent of the Python expression: abs(o). */
	PyNumber_Absolute :: proc(o: ^PyObject) -> ^PyObject ---

	/* Returns the bitwise negation of 'o' on success, or NULL on failure.
	
	This is the equivalent of the Python expression: ~o. */
	PyNumber_Invert :: proc(o: ^PyObject) -> ^PyObject ---

	/* Returns the result of left shifting o1 by o2 on success, or NULL on failure.
	
	This is the equivalent of the Python expression: o1 << o2. */
	PyNumber_Lshift :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of right shifting o1 by o2 on success, or NULL on
	failure.
	
	This is the equivalent of the Python expression: o1 >> o2. */
	PyNumber_Rshift :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of bitwise and of o1 and o2 on success, or NULL on
	failure.
	
	This is the equivalent of the Python expression: o1 & o2. */
	PyNumber_And :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the bitwise exclusive or of o1 by o2 on success, or NULL on failure.
	
	This is the equivalent of the Python expression: o1 ^ o2. */
	PyNumber_Xor :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of bitwise or on o1 and o2 on success, or NULL on
	failure.
	
	This is the equivalent of the Python expression: o1 | o2. */
	PyNumber_Or :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns 1 if obj is an index integer (has the nb_index slot of the
	tp_as_number structure filled in), and 0 otherwise. */
	PyIndex_Check :: proc() -> i32 ---

	/* Returns the object 'o' converted to a Python int, or NULL with an exception
	raised on failure. */
	PyNumber_Index :: proc(o: ^PyObject) -> ^PyObject ---

	/* Returns the object 'o' converted to Py_ssize_t by going through
	PyNumber_Index() first.
	
	If an overflow error occurs while converting the int to Py_ssize_t, then the
	second argument 'exc' is the error-type to return.  If it is NULL, then the
	overflow error is cleared and the value is clipped. */
	PyNumber_AsSsize_t :: proc(o: ^PyObject, exc: ^PyObject) -> Py_ssize_t ---

	/* Returns the object 'o' converted to an integer object on success, or NULL
	on failure.
	
	This is the equivalent of the Python expression: int(o). */
	PyNumber_Long :: proc(o: ^PyObject) -> ^PyObject ---

	/* Returns the object 'o' converted to a float object on success, or NULL
	on failure.
	
	This is the equivalent of the Python expression: float(o). */
	PyNumber_Float :: proc(o: ^PyObject) -> ^PyObject ---

	/* Returns the result of adding o2 to o1, possibly in-place, or NULL
	on failure.
	
	This is the equivalent of the Python expression: o1 += o2. */
	PyNumber_InPlaceAdd :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of subtracting o2 from o1, possibly in-place or
	NULL on failure.
	
	This is the equivalent of the Python expression: o1 -= o2. */
	PyNumber_InPlaceSubtract :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of multiplying o1 by o2, possibly in-place, or NULL on
	failure.
	
	This is the equivalent of the Python expression: o1 *= o2. */
	PyNumber_InPlaceMultiply :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* This is the equivalent of the Python expression: o1 @= o2. */
	PyNumber_InPlaceMatrixMultiply :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of dividing o1 by o2 giving an integral result, possibly
	in-place, or NULL on failure.
	
	This is the equivalent of the Python expression: o1 /= o2. */
	PyNumber_InPlaceFloorDivide :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of dividing o1 by o2 giving a float result, possibly
	in-place, or null on failure.
	
	This is the equivalent of the Python expression: o1 /= o2. */
	PyNumber_InPlaceTrueDivide :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the remainder of dividing o1 by o2, possibly in-place, or NULL on
	failure.
	
	This is the equivalent of the Python expression: o1 %= o2. */
	PyNumber_InPlaceRemainder :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of raising o1 to the power of o2, possibly in-place,
	or NULL on failure.
	
	This is the equivalent of the Python expression: o1 **= o2,
	or o1 = pow(o1, o2, o3) if o3 is present. */
	PyNumber_InPlacePower :: proc(o1: ^PyObject, o2: ^PyObject, o3: ^PyObject) -> ^PyObject ---

	/* Returns the result of left shifting o1 by o2, possibly in-place, or NULL
	on failure.
	
	This is the equivalent of the Python expression: o1 <<= o2. */
	PyNumber_InPlaceLshift :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of right shifting o1 by o2, possibly in-place or NULL
	on failure.
	
	This is the equivalent of the Python expression: o1 >>= o2. */
	PyNumber_InPlaceRshift :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of bitwise and of o1 and o2, possibly in-place, or NULL
	on failure.
	
	This is the equivalent of the Python expression: o1 &= o2. */
	PyNumber_InPlaceAnd :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the bitwise exclusive or of o1 by o2, possibly in-place, or NULL
	on failure.
	
	This is the equivalent of the Python expression: o1 ^= o2. */
	PyNumber_InPlaceXor :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the result of bitwise or of o1 and o2, possibly in-place,
	or NULL on failure.
	
	This is the equivalent of the Python expression: o1 |= o2. */
	PyNumber_InPlaceOr :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Returns the integer n converted to a string with a base, with a base
	marker of 0b, 0o or 0x prefixed if applicable.
	
	If n is not an int object, it is converted with PyNumber_Index first. */
	PyNumber_ToBase :: proc(n: ^PyObject, base: i32) -> ^PyObject ---

	/* Return 1 if the object provides sequence protocol, and zero
	otherwise.
	
	This function always succeeds. */
	PySequence_Check :: proc(o: ^PyObject) -> i32 ---

	/* Return the size of sequence object o, or -1 on failure. */
	PySequence_Size   :: proc(o: ^PyObject) -> Py_ssize_t ---
	PySequence_Length :: proc(o: ^PyObject) -> Py_ssize_t ---

	/* Return the concatenation of o1 and o2 on success, and NULL on failure.
	
	This is the equivalent of the Python expression: o1 + o2. */
	PySequence_Concat :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Return the result of repeating sequence object 'o' 'count' times,
	or NULL on failure.
	
	This is the equivalent of the Python expression: o * count. */
	PySequence_Repeat :: proc(o: ^PyObject, count: Py_ssize_t) -> ^PyObject ---

	/* Return the ith element of o, or NULL on failure.
	
	This is the equivalent of the Python expression: o[i]. */
	PySequence_GetItem :: proc(o: ^PyObject, i: Py_ssize_t) -> ^PyObject ---

	/* Return the slice of sequence object o between i1 and i2, or NULL on failure.
	
	This is the equivalent of the Python expression: o[i1:i2]. */
	PySequence_GetSlice :: proc(o: ^PyObject, i1: Py_ssize_t, i2: Py_ssize_t) -> ^PyObject ---

	/* Assign object 'v' to the ith element of the sequence 'o'. Raise an exception
	and return -1 on failure; return 0 on success.
	
	This is the equivalent of the Python statement o[i] = v. */
	PySequence_SetItem :: proc(o: ^PyObject, i: Py_ssize_t, v: ^PyObject) -> i32 ---

	/* Delete the 'i'-th element of the sequence 'v'. Returns -1 on failure.
	
	This is the equivalent of the Python statement: del o[i]. */
	PySequence_DelItem :: proc(o: ^PyObject, i: Py_ssize_t) -> i32 ---

	/* Assign the sequence object 'v' to the slice in sequence object 'o',
	from 'i1' to 'i2'. Returns -1 on failure.
	
	This is the equivalent of the Python statement: o[i1:i2] = v. */
	PySequence_SetSlice :: proc(o: ^PyObject, i1: Py_ssize_t, i2: Py_ssize_t, v: ^PyObject) -> i32 ---

	/* Delete the slice in sequence object 'o' from 'i1' to 'i2'.
	Returns -1 on failure.
	
	This is the equivalent of the Python statement: del o[i1:i2]. */
	PySequence_DelSlice :: proc(o: ^PyObject, i1: Py_ssize_t, i2: Py_ssize_t) -> i32 ---

	/* Returns the sequence 'o' as a tuple on success, and NULL on failure.
	
	This is equivalent to the Python expression: tuple(o). */
	PySequence_Tuple :: proc(o: ^PyObject) -> ^PyObject ---

	/* Returns the sequence 'o' as a list on success, and NULL on failure.
	This is equivalent to the Python expression: list(o) */
	PySequence_List :: proc(o: ^PyObject) -> ^PyObject ---

	/* Return the sequence 'o' as a list, unless it's already a tuple or list.
	
	Use PySequence_Fast_GET_ITEM to access the members of this list, and
	PySequence_Fast_GET_SIZE to get its length.
	
	Returns NULL on failure.  If the object does not support iteration, raises a
	TypeError exception with 'm' as the message text. */
	PySequence_Fast :: proc(o: ^PyObject, m: cstring) -> ^PyObject ---

	/* Return the number of occurrences on value on 'o', that is, return
	the number of keys for which o[key] == value.
	
	On failure, return -1.  This is equivalent to the Python expression:
	o.count(value). */
	PySequence_Count :: proc(o: ^PyObject, value: ^PyObject) -> Py_ssize_t ---

	/* Return 1 if 'ob' is in the sequence 'seq'; 0 if 'ob' is not in the sequence
	'seq'; -1 on error.
	
	Use __contains__ if possible, else _PySequence_IterSearch(). */
	PySequence_Contains :: proc(seq: ^PyObject, ob: ^PyObject) -> i32 ---

	/* Determine if the sequence 'o' contains 'value'. If an item in 'o' is equal
	to 'value', return 1, otherwise return 0. On error, return -1.
	
	This is equivalent to the Python expression: value in o. */
	PySequence_In :: proc(o: ^PyObject, value: ^PyObject) -> i32 ---

	/* Return the first index for which o[i] == value.
	On error, return -1.
	
	This is equivalent to the Python expression: o.index(value). */
	PySequence_Index :: proc(o: ^PyObject, value: ^PyObject) -> Py_ssize_t ---

	/* Append sequence 'o2' to sequence 'o1', in-place when possible. Return the
	resulting object, which could be 'o1', or NULL on failure.
	
	This is the equivalent of the Python expression: o1 += o2. */
	PySequence_InPlaceConcat :: proc(o1: ^PyObject, o2: ^PyObject) -> ^PyObject ---

	/* Repeat sequence 'o' by 'count', in-place when possible. Return the resulting
	object, which could be 'o', or NULL on failure.
	
	This is the equivalent of the Python expression: o1 *= count.  */
	PySequence_InPlaceRepeat :: proc(o: ^PyObject, count: Py_ssize_t) -> ^PyObject ---

	/* Return 1 if the object provides mapping protocol, and 0 otherwise.
	
	This function always succeeds. */
	PyMapping_Check :: proc(o: ^PyObject) -> i32 ---

	/* Returns the number of keys in mapping object 'o' on success, and -1 on
	failure. This is equivalent to the Python expression: len(o). */
	PyMapping_Size   :: proc(o: ^PyObject) -> Py_ssize_t ---
	PyMapping_Length :: proc(o: ^PyObject) -> Py_ssize_t ---

	/* On success, return 1 if the mapping object 'o' has the key 'key',
	and 0 otherwise.
	
	This is equivalent to the Python expression: key in o.
	
	This function always succeeds. */
	PyMapping_HasKeyString :: proc(o: ^PyObject, key: cstring) -> i32 ---

	/* Return 1 if the mapping object has the key 'key', and 0 otherwise.
	
	This is equivalent to the Python expression: key in o.
	
	This function always succeeds. */
	PyMapping_HasKey :: proc(o: ^PyObject, key: ^PyObject) -> i32 ---

	/* On success, return a list or tuple of the keys in mapping object 'o'.
	On failure, return NULL. */
	PyMapping_Keys :: proc(o: ^PyObject) -> ^PyObject ---

	/* On success, return a list or tuple of the values in mapping object 'o'.
	On failure, return NULL. */
	PyMapping_Values :: proc(o: ^PyObject) -> ^PyObject ---

	/* On success, return a list or tuple of the items in mapping object 'o',
	where each item is a tuple containing a key-value pair. On failure, return
	NULL. */
	PyMapping_Items :: proc(o: ^PyObject) -> ^PyObject ---

	/* Return element of 'o' corresponding to the string 'key' or NULL on failure.
	
	This is the equivalent of the Python expression: o[key]. */
	PyMapping_GetItemString :: proc(o: ^PyObject, key: cstring) -> ^PyObject ---

	/* Map the string 'key' to the value 'v' in the mapping 'o'.
	Returns -1 on failure.
	
	This is the equivalent of the Python statement: o[key]=v. */
	PyMapping_SetItemString :: proc(o: ^PyObject, key: cstring, value: ^PyObject) -> i32 ---

	/* isinstance(object, typeorclass) */
	PyObject_IsInstance :: proc(object: ^PyObject, typeorclass: ^PyObject) -> i32 ---

	/* issubclass(object, typeorclass) */
	PyObject_IsSubclass :: proc(object: ^PyObject, typeorclass: ^PyObject) -> i32 ---
}
