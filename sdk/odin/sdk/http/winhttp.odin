#+build windows
package http

import win32 "core:sys/windows"
import "core:testing"
import "core:fmt"
import "core:log"

HINTERNET :: win32.LPVOID

INTERNET_DEFAULT_PORT :: 0
INTERNET_DEFAULT_HTTP_PORT :: 80
INTERNET_DEFAULT_HTTPS_PORT :: 443

INTERNET_PORT :: win32.WORD

INTERNET_SCHEME_HTTP :: 1
INTERNET_SCHEME_HTTPS :: 2
INTERNET_SCHEME :: int

/* flags for WinHttpOpen */
WINHTTP_FLAG_ASYNC :: 0x10000000

/* flags for WinHttpOpenRequest */
WINHTTP_FLAG_ESCAPE_PERCENT ::         0x00000004
WINHTTP_FLAG_NULL_CODEPAGE ::          0x00000008
WINHTTP_FLAG_ESCAPE_DISABLE ::         0x00000040
WINHTTP_FLAG_ESCAPE_DISABLE_QUERY ::   0x00000080
WINHTTP_FLAG_BYPASS_PROXY_CACHE ::     0x00000100
WINHTTP_FLAG_REFRESH ::                WINHTTP_FLAG_BYPASS_PROXY_CACHE
WINHTTP_FLAG_SECURE ::                 0x00800000

WINHTTP_ACCESS_TYPE_DEFAULT_PROXY ::  0
WINHTTP_ACCESS_TYPE_NO_PROXY ::       1
WINHTTP_ACCESS_TYPE_NAMED_PROXY ::    3

/* WINHTTP_NO_PROXY_NAME : rawptr : nil
WINHTTP_NO_PROXY_BYPASS : rawptr : nil

WINHTTP_NO_REFERER : rawptr : nil
WINHTTP_DEFAULT_ACCEPT_TYPES : rawptr : nil */

WINHTTP_ERROR_BASE :: 12000

/* The original WINE winhttp.h didn't contain symbolic names for the
 * error codes. However, the values of most of them are publicly
 * documented at
 * http://msdn.microsoft.com/en-us/library/aa383770(VS.85).aspx so
 * we can add them here.
 */
ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR :: 12178
ERROR_WINHTTP_BAD_AUTO_PROXY_SCRIPT :: 12166
ERROR_WINHTTP_CANNOT_CALL_AFTER_OPEN :: 12103
ERROR_WINHTTP_CANNOT_CALL_AFTER_SEND :: 12102
ERROR_WINHTTP_CANNOT_CALL_BEFORE_OPEN :: 12100
ERROR_WINHTTP_CANNOT_CALL_BEFORE_SEND :: 12101
ERROR_WINHTTP_CANNOT_CONNECT :: 12029
ERROR_WINHTTP_CHUNKED_ENCODING_HEADER_SIZE_OVERFLOW :: 12183
ERROR_WINHTTP_CLIENT_AUTH_CERT_NEEDED :: 12044
ERROR_WINHTTP_CONNECTION_ERROR :: 12030
ERROR_WINHTTP_HEADER_ALREADY_EXISTS :: 12155
ERROR_WINHTTP_HEADER_COUNT_EXCEEDED :: 12181
ERROR_WINHTTP_HEADER_NOT_FOUND :: 12150
ERROR_WINHTTP_HEADER_SIZE_OVERFLOW :: 12182
ERROR_WINHTTP_INCORRECT_HANDLE_STATE :: 12019
ERROR_WINHTTP_INCORRECT_HANDLE_TYPE :: 12018
ERROR_WINHTTP_INTERNAL_ERROR :: 12004
ERROR_WINHTTP_INVALID_OPTION :: 12009
ERROR_WINHTTP_INVALID_QUERY_REQUEST :: 12154
ERROR_WINHTTP_INVALID_SERVER_RESPONSE :: 12152
ERROR_WINHTTP_INVALID_URL :: 12005
ERROR_WINHTTP_LOGIN_FAILURE :: 12015
ERROR_WINHTTP_NAME_NOT_RESOLVED :: 12007
ERROR_WINHTTP_NOT_INITIALIZED :: 12172
ERROR_WINHTTP_OPERATION_CANCELLED :: 12017
ERROR_WINHTTP_OPTION_NOT_SETTABLE :: 12011
ERROR_WINHTTP_OUT_OF_HANDLES :: 12001
ERROR_WINHTTP_REDIRECT_FAILED :: 12156
ERROR_WINHTTP_RESEND_REQUEST :: 12032
ERROR_WINHTTP_RESPONSE_DRAIN_OVERFLOW :: 12184
ERROR_WINHTTP_SECURE_CERT_CN_INVALID :: 12038
ERROR_WINHTTP_SECURE_CERT_DATE_INVALID :: 12037
ERROR_WINHTTP_SECURE_CERT_REV_FAILED :: 12057
ERROR_WINHTTP_SECURE_CERT_REVOKED :: 12170
ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE :: 12179
ERROR_WINHTTP_SECURE_CHANNEL_ERROR :: 12157
ERROR_WINHTTP_SECURE_FAILURE :: 12175
ERROR_WINHTTP_SECURE_INVALID_CA :: 12045
ERROR_WINHTTP_SECURE_INVALID_CERT :: 12169
ERROR_WINHTTP_SHUTDOWN :: 12012
ERROR_WINHTTP_TIMEOUT :: 12002
ERROR_WINHTTP_UNABLE_TO_DOWNLOAD_SCRIPT :: 12167
ERROR_WINHTTP_UNRECOGNIZED_SCHEME :: 12006
/* End of added error codes */

ERROR_WINHTTP_AUTODETECTION_FAILED :: (WINHTTP_ERROR_BASE + 180)

URL_COMPONENTS :: struct {
    dwStructSize: win32.DWORD,
    lpszScheme: win32.LPWSTR,
    dwSchemeLength: win32.DWORD,
    nScheme: INTERNET_SCHEME,
    lpszHostName: win32.LPWSTR,
    dwHostNameLength: win32.DWORD,
    nPort: INTERNET_PORT,
    lpszUserName: win32.LPWSTR,
    dwUserNameLength: win32.DWORD,
    lpszPassword: win32.LPWSTR,
    dwPasswordLength: win32.DWORD,
    lpszUrlPath: win32.LPWSTR,
    dwUrlPathLength: win32.DWORD,
    lpszExtraInfo: win32.LPWSTR,
    dwExtraInfoLength: win32.DWORD,
}

WINHTTP_ASYNC_RESULT :: struct {
    dwResult: win32.DWORD_PTR,
    dwError: win32.DWORD,
}

WINHTTP_CERTIFICATE_INFO :: struct {
    ftExpiry: win32.FILETIME,
    ftStart: win32.FILETIME,
    lpszSubjectInfo: win32.LPWSTR,
    lpszIssuerInfo: win32.LPWSTR,
    lpszProtocolName: win32.LPWSTR,
    lpszSignatureAlgName: win32.LPWSTR,
    lpszEncryptionAlgName: win32.LPWSTR,
    dwKeySize: win32.DWORD,
}

WINHTTP_PROXY_INFO :: struct {
    dwAccessType: win32.DWORD,
    lpszProxy: win32.LPCWSTR,
    lpszProxyBypass: win32.LPCWSTR,
}

WINHTTP_CURRENT_USER_IE_PROXY_CONFIG :: struct {
    fAutoDetect: win32.BOOL,
    lpszAutoConfigUrl: win32.LPWSTR,
    lpszProxy: win32.LPWSTR,
    lpszProxyBypass: win32.LPWSTR,
}

WINHTTP_STATUS_CALLBACK :: proc(HINTERNET,win32.DWORD_PTR,win32.DWORD,win32.LPVOID,win32.DWORD)

WINHTTP_AUTOPROXY_OPTIONS :: struct {
    dwFlags: win32.DWORD,
    dwAutoDetectFlags: win32.DWORD,
    lpszAutoConfigUrl: win32.LPCWSTR,
    lpvReserved: win32.LPVOID,
    dwReserved: win32.DWORD,
    fAutoLogonIfChallenged: win32.BOOL,
}

HTTP_VERSION_INFO :: struct {
    dwMajorVersion: win32.DWORD,
    dwMinorVersion: win32.DWORD,
}

/* The sixth parameter to WinHttpOpenRequest was wrong in the original
 * WINE header. It should be win32.LPCWSTR*, not win32.LPCWSTR, as it points to an
 * array of wide strings.
 */
/*
win32.BOOL        WINAPI WinHttpQueryAuthParams(HINTERNET,win32.DWORD,LPVOID*);
win32.BOOL        WINAPI WinHttpQueryAuthSchemes(HINTERNET,LPwin32.DWORD,LPwin32.DWORD,LPwin32.DWORD);
win32.BOOL        WINAPI WinHttpQueryHeaders(HINTERNET,win32.DWORD,win32.LPCWSTR,LPVOID,LPwin32.DWORD,LPwin32.DWORD);
win32.BOOL        WINAPI WinHttpReceiveResponse(HINTERNET,LPVOID);
win32.BOOL        WINAPI WinHttpSetDefaultProxyConfiguration(WINHTTP_PROXY_INFO*);
win32.BOOL        WINAPI WinHttpSetCredentials(HINTERNET,win32.DWORD,win32.DWORD,win32.LPCWSTR,win32.LPCWSTR,LPVOID);
win32.BOOL        WINAPI WinHttpSetOption(HINTERNET,win32.DWORD,LPVOID,win32.DWORD);
WINHTTP_STATUS_CALLBACK WINAPI WinHttpSetStatusCallback(HINTERNET,WINHTTP_STATUS_CALLBACK,win32.DWORD,win32.DWORD_PTR);
win32.BOOL        WINAPI WinHttpSetTimeouts(HINTERNET,int,int,int,int);
win32.BOOL        WINAPI WinHttpTimeFromSystemTime(CONST SYSTEMTIME *,win32.LPWSTR);
win32.BOOL        WINAPI WinHttpTimeToSystemTime(win32.LPCWSTR,SYSTEMTIME*);
win32.BOOL        WINAPI WinHttpWriteData(HINTERNET,LPCVOID,win32.DWORD,LPwin32.DWORD);*/

/* Additional definitions, from the public domain <wininet.h> in mingw */
ICU_ESCAPE :: 0x80000000
ICU_DECODE :: 0x10000000

/* A few constants I couldn't find publicly documented, so I looked up
 * their value from the Windows SDK <winhttp.h>. Presumably this falls
 * under fair use.
 */
WINHTTP_QUERY_CONTENT_LENGTH :: 5
WINHTTP_QUERY_CONTENT_TYPE :: 1
WINHTTP_QUERY_LAST_MODIFIED :: 11
WINHTTP_QUERY_STATUS_CODE :: 19
WINHTTP_QUERY_STATUS_TEXT :: 20

WINHTTP_QUERY_FLAG_SYSTEMTIME :: 0x40000000


foreign import lib {
    "system:winhttp.lib",
}

@(default_calling_convention="c")
foreign lib {
	WinHttpAddRequestHeaders :: proc(HINTERNET,win32.LPCWSTR,win32.DWORD,win32.DWORD) -> win32.BOOL ---
    WinHttpDetectAutoProxyConfigUrl :: proc(win32.DWORD,^win32.LPWSTR) -> win32.BOOL ---
    WinHttpCheckPlatform :: proc() -> win32.BOOL ---
    WinHttpCloseHandle :: proc(HINTERNET) -> win32.BOOL ---
    WinHttpConnect :: proc(HINTERNET,win32.LPCWSTR,INTERNET_PORT,win32.DWORD) -> HINTERNET ---
    WinHttpCrackUrl :: proc(win32.LPCWSTR,win32.DWORD,win32.DWORD,^URL_COMPONENTS) -> win32.BOOL ---
    WinHttpCreateUrl :: proc(^URL_COMPONENTS,win32.DWORD,win32.LPWSTR,^win32.DWORD) -> win32.BOOL ---
    WinHttpGetDefaultProxyConfiguration :: proc(^WINHTTP_PROXY_INFO) -> win32.BOOL ---
    WinHttpGetIEProxyConfigForCurrentUser :: proc(^WINHTTP_CURRENT_USER_IE_PROXY_CONFIG) -> win32.BOOL ---
    WinHttpGetProxyForUrl :: proc(HINTERNET,win32.LPCWSTR,^WINHTTP_AUTOPROXY_OPTIONS,^WINHTTP_PROXY_INFO) -> win32.BOOL ---
    WinHttpOpen :: proc(win32.LPCWSTR,win32.DWORD,win32.LPCWSTR,win32.LPCWSTR,win32.DWORD) -> HINTERNET ---
    WinHttpOpenRequest :: proc(HINTERNET,win32.LPCWSTR,win32.LPCWSTR,win32.LPCWSTR,win32.LPCWSTR,^win32.LPCWSTR,win32.DWORD) -> HINTERNET ---
    WinHttpSendRequest :: proc(HINTERNET,win32.LPCWSTR,win32.DWORD,win32.LPVOID,win32.DWORD,win32.DWORD,win32.DWORD_PTR) -> win32.BOOL ---
    WinHttpReceiveResponse :: proc(HINTERNET,win32.LPVOID) -> win32.BOOL ---
    WinHttpReadData :: proc(HINTERNET,win32.LPVOID,win32.DWORD,win32.LPDWORD) -> win32.BOOL ---
    WinHttpQueryDataAvailable :: proc(HINTERNET,win32.LPDWORD) -> win32.BOOL ---;
}
