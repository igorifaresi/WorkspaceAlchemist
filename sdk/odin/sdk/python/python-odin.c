#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PROCEDURES_PER_MODULE 1024

typedef struct {
    PyMethodDef methods[MAX_PROCEDURES_PER_MODULE];
    PyModuleDef py_module;
    int methods_qnt;
    const char *name;
} ModuleDefinition;

ModuleDefinition *
pyodin_create_module_definition(const char *name)
{
    ModuleDefinition *def = (ModuleDefinition *)calloc(1, sizeof(ModuleDefinition));
    def->py_module = (PyModuleDef){
        PyModuleDef_HEAD_INIT, name, NULL, 0, def->methods,
        NULL, NULL, NULL, NULL
    };
    def->name = name;

    return def;
}

void
pyodin_append_method(ModuleDefinition *def, PyCFunction callback, const char *name)
{
    def->methods[def->methods_qnt] = (PyMethodDef){name, callback, METH_VARARGS, "No description"};
    def->methods_qnt += 1;
}

void
pyodin_setup_module(ModuleDefinition *def, PyObject *(*initfunc)(void))
{
    PyImport_AppendInittab(def->name, initfunc);
}

PyModuleDef *
pyodin_get_py_module_ptr(ModuleDefinition *def)
{
    return &def->py_module;
}

void
pyodin_init()
{
    Py_Initialize();
}

int
pyodin_acquire_gil()
{
    PyGILState_STATE gstate;
    gstate = PyGILState_Ensure();
    return gstate;
}

void
pyodin_release_gil(int gstate)
{
    PyGILState_Release(gstate);
}

PyObject *
pyodin_import_code(const char *module_name, const char *code)
{
    PyObject *module = Py_CompileString(code, module_name, Py_file_input);

    if (module == NULL) {
        PyErr_Print();
        return NULL;
    }

    PyObject *module_obj = PyImport_ExecCodeModule(module_name, module);

    if (module_obj == NULL) {
        PyErr_Print();
        return NULL;
    }

    return module_obj;
}

PyObject *
pyodin_get_procedure(PyObject *module, const char *procedure_name)
{
    PyObject *procedure_obj = PyObject_GetAttrString(module, procedure_name);

    if (!procedure_obj) {
        return NULL;
    }

    return procedure_obj;
}

PyObject *
pyodin_call_procedure(PyObject *procedure_obj)
{
    PyObject *return_obj = PyObject_CallObject(procedure_obj, NULL);

    if (PyErr_Occurred()) {
        return NULL;
    }

    return return_obj;
}

PyInterpreterState *
pyodin_get_interpreter(PyThreadState *state)
{
    return state->interp;
}

void
pyodin_create_interpreter(PyThreadState **state)
{
    PyInterpreterConfig config = (PyInterpreterConfig){
        .use_main_obmalloc = 0,
        .allow_fork = 0,
        .allow_exec = 0,
        .allow_threads = 1,
        .allow_daemon_threads = 0,
        .check_multi_interp_extensions = 1,
        .gil = PyInterpreterConfig_OWN_GIL,
    };
    Py_NewInterpreterFromConfig(state, &config);
}
