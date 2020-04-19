//
//  ContentView.swift
//  ScrollFun
//
//  Created by James Stewart on 4/18/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import SwiftUI

struct ConversationView: View {
    var conversation: Conversation
    
    var body: some View {
        NavigationView {
            ReverseScrollView {
                VStack(spacing: 8) {
                    ForEach(self.conversation.messages) { message in
                        BubbleView(message: message.body)
                    }
                }
            }
            .navigationBarTitle(Text("Conversation"))
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(conversation: demoConversation)
    }
}
