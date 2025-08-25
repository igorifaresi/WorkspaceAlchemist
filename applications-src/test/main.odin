package main

import "sdk:sdk/ui"
import "sdk:sdk"

update :: proc() {
    ui.button("Hello World!")
}

main :: proc() {
    sdk.easy_start_ui_module(update)
}