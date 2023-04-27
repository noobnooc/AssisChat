//
//  ContentView.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-05.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
#if os(iOS)
        NavigationView {
            ChatsView()
                .navigationTitle("AssisChat")
                .inlineNavigationBar()
            SelectChatHintView()
        }
#else
        NavigationSplitView {
            ChatsView()
                .frame(width: 280)
                .navigationTitle("AssisChat")
                .navigationSplitViewColumnWidth(280)
        } detail: {
            SelectChatHintView()
                .frame(minWidth: 600, minHeight: 500)
        }
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
