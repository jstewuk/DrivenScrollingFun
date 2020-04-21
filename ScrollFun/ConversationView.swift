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
    var scrollViewModel1: ScrollViewModel
    var scrollViewModel2: ScrollViewModel
    var cancellable: Cancellable
    
    let subj1_2 = DragSubject()
    let subj2_1 = DragSubject()
    
    init(conversation: Conversation) {
        self.conversation = conversation
        self.scrollViewModel1 = ScrollViewModel("model1", inboundSubject: subj2_1, outboundSubject: subj1_2)
        self.scrollViewModel2 = ScrollViewModel("model2", inboundSubject: subj1_2, outboundSubject: subj2_1)
        self.cancellable = self.scrollViewModel1.objectWillChange.sink {
            os_log("model1 changed")
        }
    }
    
    var body: some View {
//        print("ConversationView updated")
        return
            VStack {
                NavigationView {
                    ReverseScrollView(model: scrollViewModel1) {
                        VStack(spacing: 8) {
                            ForEach(self.conversation.messages) { message in
                                BubbleView(message: message.body)
                            }
                        }
                    }
                    .navigationBarTitle(Text("Conversation"))
                }
                
                Button("scroll") { self.scrollMe() }
                
                NavigationView {
                    ReverseScrollView(model: scrollViewModel2) {
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
    
    func scrollMe() {
        print("scrollMe()")
        self.scrollViewModel1.scrollOffset += 100
    }
    
}


struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(conversation: demoConversation)
    }
}
