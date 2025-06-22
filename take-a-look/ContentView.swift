//
//  MainView.swift
//  take-a-look
//
//  Created by Anthony on 4/16/25.
//

import SwiftUI

struct ContentView: View {
    @State var windowSize: CGFloat = 100
    @State private var talOn: Bool = AppSettings.shared.talOn
    
    var cat_On: Bool = true
    
    @ObservedObject var responseStore = ServerResponseStore.shared
    
    var body: some View {
        ZStack {
            CharacterView(talOn: $talOn)
                .onChange(of: AppSettings.shared.talOn) { _, newValue in
                    talOn = newValue
                    print("talOn value changed to \(AppSettings.shared.talOn)")
                }
            
            if talOn {
                CameraView()
                    .opacity(0)
            }
        }
        .frame(width: windowSize, height: windowSize * 1.5)
        .background(Color.clear)
        .onChange(of: responseStore.value) {
            if let value: Int = responseStore.value {
                let digits = String(format: "%05d", value).compactMap { Int(String($0)) }
                //              밝기 / 얼굴 거리 / 눈 깜빡임 / 어깨, 턱 각도 / 거북목
                //                let val1 = digits[0]
                let val2 = digits[1]
                let val3 = digits[2]
                let val4 = digits[3]
                // let val5 = digits[4]
                
                if value == 99999 {
                    print("NO Face")
                    return
                }
                
                if value == 11111 {
                    PopupWindowManager.shared.closePopup()
                    return
                }
                
                if val2 == 2 {
                    PopupWindowManager.shared.showPopup() {
                        FeedbackView(pose: 20, cat_On: cat_On)
                    }
                }
                
                if val3 == 2 {
                    PopupWindowManager.shared.showPopup() {
                        FeedbackView(pose: 30, cat_On: cat_On)
                    }
                }
                
                if val4 == 2 {
                    PopupWindowManager.shared.showPopup() {
                        FeedbackView(pose: 41, cat_On: cat_On)
                    }
                }
                else if val4 == 3 {
                    PopupWindowManager.shared.showPopup() {
                        FeedbackView(pose: 42, cat_On: cat_On)
                    }
                }
                
                //                    if val5 == 2 {
                //                         isFeedbackOn = true
                //                        PopupWindowManager.shared.showPopup() {
                //                            FeedbackView(pose: 50, cat_On: cat_On)
                //                        }
                //                    }
            }
        }
    }
}
