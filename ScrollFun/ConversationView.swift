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
    
    let subj1_2 = DragSubject()
    let subj2_1 = DragSubject()
    
    @State private var latency: Double = 0.0
    @State private var reliability: Double = 100.0
    
    init(conversation: Conversation) {
        self.conversation = conversation
        self.scrollViewModel1 = ScrollViewModel("model1", inboundSubject: subj2_1, outboundSubject: subj1_2)
        self.scrollViewModel2 = ScrollViewModel("model2", inboundSubject: subj1_2, outboundSubject: subj2_1)
    }
    
    var body: some View {
//        print("ConversationView updated")
        let latencyBinding = Binding(
            get: { self.latency },
            set: { self.latency = $0
                self.scrollViewModel1.latency = $0
                self.scrollViewModel2.latency = $0
            }
        )
        
        let reliabilityBinding = Binding(
            get: { self.reliability },
            set: { self.reliability = $0
                self.scrollViewModel1.reliability = Int($0)
                self.scrollViewModel2.reliability = Int($0)
            }
        )
        
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
                Text( "Latency is \(latency) seconds")
                Slider(value: latencyBinding, in :0.001...2.0, step: 0.1)
                Text( "Reliability is \(reliability)%")
                Slider(value: reliabilityBinding, in :0.0...100.0, step: 5.0)
                
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
