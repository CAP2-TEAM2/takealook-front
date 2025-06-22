//
//  CharacterView.swift
//  take-a-look
//
//  Created by Anthony on 5/14/25.
//

import SwiftUI

struct CharacterView: View {
    @Binding var talOn: Bool
    
    @State private var isSleeping: Bool = false
    @State private var isHovering: Bool = false
    
    @ObservedObject var responseStore = ServerResponseStore.shared
    
    var body: some View {
        ZStack {
            Image("body")
                .resizable()
                .frame(width: 70, height: 70)
                .offset(y: 40)
            Image(talOn ? "head" : "head-sleep")
                .resizable()
                .frame(width: 100, height: 100)
                .offset(y: isHovering ? -18 : -20)
        }
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovering.toggle()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    if abs(value.translation.width) < 0.2 && abs(value.translation.height) < 0.2 {
                        talOn.toggle()
                    }
                }
        )
    }
}
