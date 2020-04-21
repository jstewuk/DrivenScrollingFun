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
    var dummyModel = DummyModel()
    var cancellable: Cancellable
    
    let dragChangedSubject = DragChangedSubject()
    let dragEndedSubject = DragEndedSubject()
    let dragChangedSubject2 = DragChangedSubject()
    let dragEndedSubject2 = DragEndedSubject()
    
    init(conversation: Conversation) {
        self.conversation = conversation
        self.scrollViewModel1 = ScrollViewModel("model1", dragChangedSubject: dragChangedSubject, dragEndedSubject: dragEndedSubject)
        self.scrollViewModel2 = ScrollViewModel("model2", dragChangedSubject: dragChangedSubject2, dragEndedSubject: dragEndedSubject2)
        self.cancellable = self.scrollViewModel1.objectWillChange.sink {
            os_log("model1 changed")
        }
    }
    
    var body: some View {
        print("ConversationView updated")
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
                Button("increment dummyVar") { self.incrementDummy() }
                
                NavigationView {
                    ReverseScrollView(model: scrollViewModel2) {
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
    
    func scrollMe() {
        print("scrollMe()")
        self.scrollViewModel1.scrollOffset += 100
    }
    
    func incrementDummy() {
        print("incrementDummy()")
        self.dummyModel.dummyVar += 1
    }
}


struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(conversation: demoConversation)
    }
}
