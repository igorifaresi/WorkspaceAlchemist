#+build windows
package http

import win32 "core:sys/windows"
import "core:thread"
import "core:log"
import "core:testing"
import "core:encoding/json"

body_reader :: proc(data: rawptr) {
    request := cast(^Request)data

    dwDownloaded: win32.DWORD = 0

    hRequest := cast(HINTERNET)request.handle

    for {
        dwSize: win32.DWORD = 0
        if !WinHttpQueryDataAvailable(hRequest, &dwSize) {
            request.status = .Error
            request.error_code = .Error_Quering_Data
            return
        }
 
        if dwSize <= 0 {
            break
        }

        pszOutBuffer := make([]byte, dwSize + 1)
        if !WinHttpReadData(hRequest, raw_data(pszOutBuffer), dwSize, &dwDownloaded) {
            request.status = .Error
            request.error_code = .Error_Reading_Data
            return
        }

        append(&request.body, ..pszOutBuffer) 
    }

    request.status = .Done
}

perform_request :: proc(
    method: string,
    url: URL,
    json_data: []byte = {},
    allocator := context.allocator,
) -> (^Request, bool) {
    request := new(Request)

    hSession := WinHttpOpen(
        win32.utf8_to_wstring("WinHTTP Example/1.0"),
        WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
        nil,
        nil,
        0,
    )

    if hSession == nil {
        request.status = .Error
        request.error_code = .Error_Creating_Session
        return request, false
    }
    
    hConnect := WinHttpConnect(
        hSession,
        win32.utf8_to_wstring(url.host),
        cast(u16)url.port,
        0,
    )

    if hConnect == nil {
        request.status = .Error
        request.error_code = .Error_Creating_Connection
        return request, false
    }

    hRequest := WinHttpOpenRequest(
        hConnect,
        win32.utf8_to_wstring(method),
        win32.utf8_to_wstring(url.path),
        nil,
        nil,
        nil,
        url.scheme == "https" ? WINHTTP_FLAG_SECURE : 0,
    )

    if hRequest == nil {
        request.status = .Error
        request.error_code = .Error_Opening_Request
        return request, false
    } 

    bResults: win32.BOOL = false
    if len(json_data) > 0 {
        bResults = WinHttpSendRequest(
            hRequest,
            win32.utf8_to_wstring("content-type:application/json"),
            ~u32(0),
            &json_data[0],
            cast(u32)len(json_data),
            cast(u32)len(json_data),
            0,
        )
    } else {
        bResults = WinHttpSendRequest(
            hRequest,
            nil,
            0,
            nil,
            0,
            0,
            0,
        )
    }

    if !bResults {
        request.status = .Error
        request.error_code = .Error_Sending_Request
        return request, false
    }

    bResults = WinHttpReceiveResponse(hRequest, nil)

    if !bResults {
        request.status = .Error
        request.error_code = .Error_Receiving_Response
        return request, false
    }

    request.body = make([dynamic]byte, allocator)
    request.handle = hRequest

    thread.create_and_start_with_data(request, body_reader)

    return request, true
}
