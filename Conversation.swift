//
//  Conversation.swift
//  ScrollFun
//
//  Created by James Stewart on 4/18/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import Foundation

struct Conversation: Hashable, Codable {
    var messages: [Message] = []
}

struct Message: Hashable, Codable, Identifiable {
    public var id: Int
    let body: String
}

let demoConversation: Conversation = {
    var conversation = Conversation()
    for index in 0..<40 {
        var message = Message(id: index, body: "message \(index)")
        conversation.messages.append(message)
    }
    return conversation
}()
