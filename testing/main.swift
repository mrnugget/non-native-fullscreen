//
//  main.swift
//  testing
//
//  Created by Thorsten Ball on 05.07.23.
//

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
