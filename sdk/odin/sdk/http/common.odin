package http

import "core:thread"
import "core:net"
import "core:testing"
import "core:encoding/json"
import "core:log"

Request_Status :: enum {
    Running,
    Done,
    Error,
}

Request_Error :: enum {
    Error_Creating_Session,
    Error_Creating_Connection,
    Error_Opening_Request,
    Error_Sending_Request,
    Error_Receiving_Response,
    Error_Quering_Data,
    Error_Reading_Data,
}

Request :: struct {
    status: Request_Status,
    error_code: Request_Error,
    body: [dynamic]byte,
    handle: rawptr,
}

URL :: struct {
    scheme: string,
    host: string,
    path: string,
    fragment: string,
    port: int,
}

parse_url :: proc(url_string: string, allocator := context.allocator) -> URL {
    scheme, host, path, queries, fragment := net.split_url(url_string, allocator)
    host_without_port, port, ok := net.split_port(host)
    
    if port == 0 {
        switch scheme {
        case "http":
            port = 80
        case "https":
            port = 443
        }
    }

    url := URL{
        scheme = scheme,
        host = host_without_port,
        path = path,
        fragment = fragment,
        port = port,
    }

    return url
}

get :: proc(url: string, allocator := context.allocator) -> (^Request, bool) {
    url := parse_url(url, allocator)
    request, ok := perform_request("GET", url, {}, allocator)
    return request, ok
}

post := proc(url: string, payload: any, allocator := context.allocator) -> (^Request, bool) {
    json_data, err := json.marshal(payload, {}, allocator)
    if err != nil {
        return nil, false
    }

    url := parse_url(url, allocator)
    
    request, ok := perform_request("POST", url, json_data, allocator)
    return request, ok
}

@(test)
test_get :: proc(t: ^testing.T) {
    request, ok := get("www.microsoft.com")

    if !ok {
        panic("Error creating request")
    }

    for request.status == .Running {
        if request.status == .Error {
            panic("Error processing request")
        }
    }

    //log.info(string(request.body[:]))
}

@(test)
test_post :: proc(t: ^testing.T) {
    Example_Struct :: struct {
        foo: string,
        bar: string,
    }

    payload := Example_Struct{"foo", "bar"}

    request, ok := post("http://localhost:4242/", payload)

    if !ok {
        log.info(request)
        panic("Error creating request")
    }

    for request.status == .Running {
        if request.status == .Error {
            panic("Error processing request")
        }
    }

    log.info(string(request.body[:]))
}
