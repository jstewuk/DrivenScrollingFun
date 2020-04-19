//
//  ContentView.swift
//  ScrollFun
//
//  Created by James Stewart on 4/18/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import SwiftUI
import Combine

struct ConversationView: View {
    var conversation: Conversation
    var scrollViewModel = ScrollViewModel()
    var cancellable: Cancellable
    
    init(conversation: Conversation) {
        self.conversation = conversation
        self.cancellable = self.scrollViewModel.objectWillChange.sink {
            print("ScrollViewModel changed")
        }
    }
    
    var body: some View {
        VStack {
            NavigationView {
                ReverseScrollView(model: scrollViewModel) {
                    VStack(spacing: 8) {
                        ForEach(self.conversation.messages) { message in
                            BubbleView(message: message.body)
                        }
                    }
                }
                .navigationBarTitle(Text("Conversation"))
            }
            
            Button("scroll") { self.scrollMe() }
        }
    }
    
    func scrollMe() {
        self.scrollViewModel.scrollOffset += 100
    }
}


struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(conversation: demoConversation)
    }
}
