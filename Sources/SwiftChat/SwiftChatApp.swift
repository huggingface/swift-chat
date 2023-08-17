//
//  SwiftChatApp.swift
//  SwiftChat
//
//  Created by Pedro Cuenca on 3/5/23.
//

import SwiftUI

@main
struct SwiftChatApp: App {
    @State private var clearTriggered = false

    var body: some Scene {
        WindowGroup {
            ContentView(clearTriggered: $clearTriggered)
        }
        .commands {
            CommandGroup(after: .pasteboard) {
                Button(action: {
                    print("clear")
                    self.clearTriggered.toggle()
                }) {
                    Text("Clear Output")
                }
                .keyboardShortcut(.delete, modifiers: [.command])
            }
        }
    }
}
