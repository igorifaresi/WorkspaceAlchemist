package ipc

import win "core:sys/windows"
import "core:strings"
import "core:encoding/cbor"
import "core:fmt"

DEFAUT_BUFFER_SIZE :: 1024

Shared_Memory :: struct {
    name: string,
    data: []byte,
    handle: win.HANDLE,
}

Pipe :: win.HANDLE

Process :: struct {
    startup_info: win.STARTUPINFOW,
    process_info: win.PROCESS_INFORMATION,
}

create_shared_memory :: proc(name: string, buffer_size: int = DEFAUT_BUFFER_SIZE) -> Shared_Memory { 
    handle := win.CreateFileMappingW(
        win.INVALID_HANDLE_VALUE,
        nil,
        win.PAGE_READWRITE,
        0,
        cast(u32)buffer_size,
        win.utf8_to_wstring(name),
    )

    if handle == nil {
        panic("Cannot create file mapping")
    }

    data_ptr := win.MapViewOfFile(handle, win.FILE_MAP_ALL_ACCESS, 0, 0, cast(uint)buffer_size)

    if data_ptr == nil {
        panic("Cannot map view")
    }
    
    data := (cast([^]byte)data_ptr)[:buffer_size]

    shared := Shared_Memory{
        handle = handle,
        name = name,
        data = data,
    }

    return shared
}

open_shared_memory :: proc(name: string, buffer_size: int = DEFAUT_BUFFER_SIZE) -> Shared_Memory {
    handle := win.OpenFileMappingW(win.FILE_MAP_ALL_ACCESS, false, win.utf8_to_wstring(name))

    if handle == nil {
        panic("Cannot open file mapping")
    }

    data_ptr := win.MapViewOfFile(handle, win.FILE_MAP_ALL_ACCESS, 0, 0, cast(uint)buffer_size)

    if data_ptr == nil {
        panic("Cannot map view")
    }
    
    data := (cast([^]byte)data_ptr)[:buffer_size]

    shared := Shared_Memory{
        handle = handle,
        name = name,
        data = data,
    }

    return shared
}

create_named_pipe :: proc(name: string) -> Pipe {
    handle := win.CreateNamedPipeW(
        win.utf8_to_wstring(strings.concatenate([]string{"\\\\.\\pipe\\", name})),
        win.PIPE_ACCESS_DUPLEX,
        win.PIPE_TYPE_MESSAGE | win.PIPE_READMODE_MESSAGE | win.PIPE_WAIT,
        1,
        DEFAUT_BUFFER_SIZE,
        DEFAUT_BUFFER_SIZE,
        0,
        nil,
    )

    if handle == nil {
        panic("Unable to create named pipe")
    }

    return handle
}

open_named_pipe :: proc(name: string) -> Pipe {
    handle := win.CreateFileW(
        win.utf8_to_wstring(strings.concatenate([]string{"\\\\.\\pipe\\", name})),
        win.GENERIC_READ | win.GENERIC_WRITE,
        0,
        nil,
        win.OPEN_EXISTING,
        0,
        nil,
    )

    if handle == nil {
        panic("Unable to open named pipe")
    }

    return handle
}

wait_for_client :: proc(pipe: ^Pipe) {
    success := win.ConnectNamedPipe(pipe^, nil)

    if !success {
        panic("Error waiting to client")
    }
}

create_process :: proc(cmd: string) -> Process {
    process: Process

    ok := win.CreateProcessW(
        nil,
        win.utf8_to_wstring(cmd),
        nil,
        nil,
        false,
        0,
        nil,
        nil,
        &process.startup_info,
        &process.process_info,
    )

    if !ok {
        panic("Error creating process")
    }

    return process
}

send_object_pipe :: proc(pipe: ^Pipe, obj: any) {
    binary, err := cbor.marshal(obj, cbor.ENCODE_FULLY_DETERMINISTIC)
    if err != nil {
        fmt.println(err)
        panic("error converting to cbor")
    }

    qnt: win.DWORD
    success := win.WriteFile( 
      pipe^,
      &binary[0],
      cast(u32)len(binary),
      &qnt,
      nil,
    )

    if !success {
        panic("Error writing to pipe")
    }
}

receive_object_pipe :: proc(pipe: ^Pipe, obj: ^$T) {
    buffer: [DEFAUT_BUFFER_SIZE]byte

    qnt: win.DWORD
    success := win.ReadFile(
        pipe^,
        &buffer[0],
        DEFAUT_BUFFER_SIZE,
        &qnt,
        nil,
    )

    if !success {
        panic("Error reading from pipe")
    }

    binary := buffer[:qnt]

    err := cbor.unmarshal(string(binary), obj)
    if err != nil {
        fmt.println(err)
        panic("unable to unmarshal")
    }
}

close_process :: proc(process: ^Process) {
    win.CloseHandle(process.process_info.hProcess)
    win.CloseHandle(process.process_info.hThread)
}
