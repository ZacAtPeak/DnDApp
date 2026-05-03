//
//  DnDAppSwiftUIApp.swift
//  DnDAppSwiftUI
//
//  Created by Zachary Reyes on 5/2/26.
//

import SwiftUI

@main
struct DnDAppSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        }
        .defaultSize(width: 1250, height: 875)
    }
}
