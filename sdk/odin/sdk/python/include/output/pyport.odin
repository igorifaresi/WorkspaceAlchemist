package pkg

import "core:c"

_ :: c



/* uintptr_t is the C9X name for an unsigned integral type such that a
* legitimate void* can be cast to uintptr_t and then back to void* again
* without loss of information.  Similarly for intptr_t, wrt a signed
* integral type.
*/
Py_uintptr_t :: uintptr

Py_intptr_t :: intptr_t

Py_hash_t :: Py_ssize_t

Py_uhash_t :: uint

/* Now PY_SSIZE_T_CLEAN is mandatory. This is just for backward compatibility. */
Py_ssize_clean_t :: Py_ssize_t

