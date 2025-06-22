//
//  take_a_lookApp.swift
//  take-a-look
//
//  Created by Anthony on 4/7/25.
//

import SwiftUI

@main
struct take_a_lookApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Window("Take a Look", id: "tal") {
            EmptyView()
        }
        .windowResizability(.contentSize)
    }
}
