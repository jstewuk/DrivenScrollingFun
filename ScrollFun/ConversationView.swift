//
//  ContentView.swift
//  ScrollFun
//
//  Created by James Stewart on 4/18/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import SwiftUI
import Combine
import os

struct ConversationView: View {
    var conversation: Conversation
    
    let subj1_2 = DragSubject()
    let subj2_1 = DragSubject()
    
    @State private var latency: Double = 0.0
    @State private var reliability: Double = 100.0
    
    init(conversation: Conversation) {
        self.conversation = conversation
    }
    
    var body: some View {
        
        return
            VStack {
                NavigationView {
                    DrivenScrollView(enabledAxes: [.vertical, .horizontal], inboundSubject: subj2_1, outboundSubject: subj1_2) {
                        VStack(spacing: 8) {
                            ForEach(self.conversation.messages) { message in
                                BubbleView(message: message.body)
                            }
                        }
                    }
                    .navigationBarTitle(Text("Conversation"))
                }
                
                NavigationView {
                    DrivenScrollView(enabledAxes: [.vertical, .horizontal], inboundSubject: subj1_2, outboundSubject: subj2_1) {
                        VStack(spacing: 8) {
                            ForEach(self.conversation.messages) { message in
                                BubbleView(message: message.body)
                            }
                        }
                    }
                    .navigationBarTitle(Text("Conversation Mirror"))
                }
        }
    }
}


struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(conversation: demoConversation)
    }
}
