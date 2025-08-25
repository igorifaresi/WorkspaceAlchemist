package build

import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:strings"
import "core:encoding/cbor"

import "sdk:sdk/ui"

p :: fmt.println

exec :: proc(cmd: string) {
    parts := strings.split(cmd, " ")

	process_desc := os2.Process_Desc{
		command = parts,
	}

    p("---> Executing:", cmd)
	state, sout, serr, err := os2.process_exec(process_desc, context.allocator)
    p(string(sout))

	if err != nil {
		panic("Error executing command")
	}

	if len(serr) > 0 {
        p(string(serr))
        panic("The command returned a error message")
	}

	if !state.success {
        panic("Failed running command")
    }

    p(string(sout))
}

check_option :: proc(option: string) -> bool {
    for arg in os.args[1:] {
        if arg == option {
            return true
        }
    }
    return false
}

main :: proc() {
    p("--------------------------------------")
    p("Welcome to WorkspaceAlchemist builder!")
    p("--------------------------------------")
    p("")

    if len(os.args) < 2 {
        panic("Invalid argument count [OPTION] required")
    }

    if check_option("client-docs") {
        exec("odin doc client -all-packages -collection:sdk=sdk/odin -out:client/docs.odin-docs -doc-format -custom-attribute:plugin_callable")
    }

    if check_option("sdk") {
        exec("odin run sdk_generator -out:build/sdk_generator.exe")
    }

    if check_option("apps") {
        handle, err := os.open("applications-src")
        if err != nil {
            panic("Error opening src modules folder")
        }

        files, err2 := os.read_dir(handle, 1024)
        if err2 != nil {
            panic("Unable to read dir")
        }

        for f in files {
            if f.is_dir {
                cmd := strings.concatenate([]string{"odin build ", f.fullpath, "\\main.odin -file -debug -collection:sdk=sdk/odin -custom-attribute:plugin_callable -out:applications\\", f.name, "\\app.exe"})
                exec(cmd)
            }
        }
    }

    if check_option("font") {
        bitmap, palette := ui.generate_font_atlas()

        os.write_entire_file("sdk/odin/ui/assets/font_atlas_bitmap.bin", bitmap)

        os.write_entire_file("sdk/odin/ui/assets/font_atlas_map.bin", (cast([^]byte)palette)[:size_of(ui.Font_Palette)])
    }

    if check_option("client") {
        exec("odin build client -debug -collection:sdk=sdk/odin -custom-attribute:plugin_callable -out:build/client.exe")
    }

    if check_option("run-client") {
        exec("odin run client -debug -collection:sdk=sdk/odin -custom-attribute:plugin_callable -out:build/client.exe")
    }
}