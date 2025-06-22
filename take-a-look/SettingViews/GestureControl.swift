//
//  GestureControl.swift
//  take-a-look
//
//  Created by Anthony on 6/11/25.
//

import Foundation
import Cocoa
import Quartz
import SwiftUI

struct GestureControl: View {
    @ObservedObject var responseStore = ServerResponseStore.shared
    
    @AppStorage("gesture_On") private var gesture_On: Bool = true
    @AppStorage("upGesture") private var upGesture: Int = 0
    @AppStorage("horizontalGesture") private var horizontalGesture: Int = 0
    
    @State private var currentGesture: Int = 0

    @State private var arrow: String = ""
    @State private var eyepos: CGFloat = 0
    @State private var headyaw: CGFloat = 0
    @State private var headpitch: CGFloat = 0
    
    var cat_On: Bool
    
    var body: some View {
        VStack {
            HStack {
                Toggle("", isOn: $gesture_On)
                    .toggleStyle(.checkbox)
                    .frame(width: 20, height: 20)
                    .offset(y: -2)
                Text("전체 제스처")
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Picker("", selection: $horizontalGesture) {
                    Text("자동").tag(0)
                    Text("분할 창 이동").tag(2)
                    Text("미디어 컨트롤").tag(3)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 80)
                .onHover {b in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        headyaw = b ? -30 : 0
                        arrow = b ? "arrow-left" : ""
                    }
                }
                ZStack {
                    Picker("", selection: $upGesture) {
                        Text("없음").tag(-1)
                        Text("Mission Control").tag(1)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80)
                    .onHover {b in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            headpitch = b ? 30 : 0
                            arrow = b ? "arrow-up" : ""
                        }
                    }
                    .offset(y: -60)
                    
                    ZStack {
                        Image("gesture-cat")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                        
                        Image("pupil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8)
                            .offset(x: -12 + eyepos, y: -3)
                        Image("pupil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8)
                            .offset(x: 12 + eyepos, y: -3)
                    }
                    .rotation3DEffect(
                        .degrees(headyaw),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .center,
                        perspective: 0.5
                    )
                    .rotation3DEffect(
                        .degrees(headpitch),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .center,
                        perspective: 0.5
                    )
                    
                    if arrow != "" {
                        Image(arrow)
                            .resizable()
                            .scaledToFit()
                            .opacity(0.8)
                            .offset(y: 20)
                            .frame(width: 24)
                    }
                    
                }.offset(y: 20)
                
                Picker("", selection: $horizontalGesture) {
                    Text("자동").tag(0)
                    Text("분할 창 이동").tag(2)
                    Text("미디어 컨트롤").tag(3)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 80)
                .onHover {b in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        headyaw = b ? 30 : 0
                        arrow = b ? "arrow-right" : ""
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20).frame(width: 300)
        .onChange(of: responseStore.gesture) {
            currentGesture = responseStore.gesture ?? 0
            if cat_On && gesture_On {
                // print(currentGesture)
                if currentGesture == 1 {
                    performGestureByCode(code: upGesture, direction: "up")
                }
                else if currentGesture == 2 {
                    performGestureByCode(code: horizontalGesture, direction: "left")
                }
                else if currentGesture == 3 {
                    performGestureByCode(code: horizontalGesture, direction: "right")
                }
            }
        }
    }
}

func getCurrentApp() -> String? {
    if let app = NSWorkspace.shared.frontmostApplication {
        return app.localizedName
    }
    return nil
}

func performAutoGesture(code: Int, direction: String) {
    let name = getCurrentApp() ?? "null"
    print(name)
    switch name {
    case "Code": pressCmdArrow(direction: direction)
    case "Xcode": pressCmdArrow(direction: direction)
    case "Google Chrome": pressCmdOptArrow(direction: direction)
    default:
        pressArrow(direction: direction)
    }
}

func performGestureByCode(code: Int, direction: String) {
    switch code {
    case 0: performAutoGesture(code: code, direction: direction)
    case 1: openMissionControl()
    case 2: focusSplitWindow(which: direction)
    case 3: controlMediaTrack(direction: direction)
    default: break
    }
}

func openMissionControl() {
    let task = Process()
    task.launchPath = "/usr/bin/open"
    task.arguments = ["/System/Applications/Mission Control.app"]
    task.launch()
}


func controlMediaTrack(direction: String) {
    let name = (direction == "left") ? "previousMedia" : "nextMedia"
    let task = Process()
    task.launchPath = "/usr/bin/shortcuts"	
    task.arguments = ["run", name]
    task.launch()
}

func pressArrow(direction: String) {
    let src = CGEventSource(stateID: .hidSystemState)
    
    let keyCode: CGKeyCode = (direction == "left") ? 0x7B : 0x7C // Left: 0x7B, Right: 0x7C

    let keyDown = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
    keyDown?.post(tap: .cghidEventTap)

    let keyUp = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
    keyUp?.post(tap: .cghidEventTap)
}

func pressCmdArrow(direction: String) {
    let src = CGEventSource(stateID: .hidSystemState)
    
    let keyCode: CGKeyCode = (direction == "left") ? 0x7B : 0x7C // Left: 0x7B, Right: 0x7C
    let flags: CGEventFlags = [.maskCommand]
                               
    let keyDown = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
    keyDown?.flags = flags
    keyDown?.post(tap: .cghidEventTap)

    let keyUp = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
    keyUp?.flags = flags
    keyUp?.post(tap: .cghidEventTap)
}

func pressCmdOptArrow(direction: String) {
    let src = CGEventSource(stateID: .hidSystemState)
    
    let keyCode: CGKeyCode = (direction == "left") ? 0x7B : 0x7C // Left: 0x7B, Right: 0x7C
    let flags: CGEventFlags = [.maskCommand, .maskAlternate]

    let keyDown = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
    keyDown?.flags = flags
    keyDown?.post(tap: .cghidEventTap)

    let keyUp = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
    keyUp?.flags = flags
    keyUp?.post(tap: .cghidEventTap)
}

func focusSplitWindow(which: String) {
    let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
    guard let windowListInfo = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: AnyObject]] else {
        print("창 정보를 가져올 수 없습니다.")
        return
    }

    let allBounds = windowListInfo.compactMap { $0["kCGWindowBounds"] as? [String: CGFloat] }
    let totalBounds = allBounds.reduce(CGRect.zero) { result, dict in
        let rect = CGRect(
            x: dict["X"] ?? 0,
            y: dict["Y"] ?? 0,
            width: dict["Width"] ?? 0,
            height: dict["Height"] ?? 0
        )
        return result.union(rect)
    }
    let screenWidth = totalBounds.width

    // 전체 화면을 다 차지하는 창 제외
    let candidates = windowListInfo.compactMap { window -> (name: String, bounds: CGRect)? in
        guard
            let ownerName = window["kCGWindowOwnerName"] as? String,
            let boundsDict = window["kCGWindowBounds"] as? [String: CGFloat]
        else {
            return nil
        }

        let bounds = CGRect(
            x: boundsDict["X"] ?? 0,
            y: boundsDict["Y"] ?? 0,
            width: boundsDict["Width"] ?? 0,
            height: boundsDict["Height"] ?? 0
        )

        // 전체 화면 너비를 거의 다 차지하는 창 제외
        if bounds.width >= screenWidth * 0.98 {
            return nil
        }

        return (ownerName, bounds)
    }

    for i in 0..<candidates.count {
        for j in i+1..<candidates.count {
            let pair = [candidates[i], candidates[j]].sorted { $0.bounds.origin.x < $1.bounds.origin.x }
            let a = pair[0]
            let b = pair[1]
            let totalWidth = a.bounds.width + b.bounds.width

            if abs(totalWidth - screenWidth) < 10.0 {
                if which == "left" {
                    let task = Process()
                    task.launchPath = "/usr/bin/open"
                    task.arguments = ["-a", a.name]
                    task.launch()
                }
                else if which == "right" {
                    let task = Process()
                    task.launchPath = "/usr/bin/open"
                    task.arguments = ["-a", b.name]
                    task.launch()
                }
                return
            }
        }
    }
}

