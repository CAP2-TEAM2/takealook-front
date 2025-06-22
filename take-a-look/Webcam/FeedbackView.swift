import Foundation
import SwiftUI
import AppKit

struct Cat: View {
    var headRotation: CGFloat = 0.0
    var headImage: String = "head"
    var headScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Image("body")
                .resizable()
                .frame(width: 70, height: 70)
                .offset(y: 40)
            Image(headImage)
                .resizable()
                .frame(width: 100, height: 100)
                .offset(y: -10 + -10 * headScale)
                .scaleEffect(headScale)
                .rotationEffect(.degrees(headRotation))
        }
    }
}

struct FeedbackView: View {
    @State private var capturedImage: NSImage?
    @State private var capturedScreenshot: NSImage?
    @State private var rotation: CGFloat = 0.0
    @State private var zoom: CGFloat = 1.0
    @State private var blur: CGFloat = 0.0
    @State private var opa: CGFloat = 1.0
    @State private var ment: String = ""
    @State private var displayedMent: String = ""
    @State private var diagonalAngle: CGFloat = 0
    @State private var elapsedTime: Float = 0
    
    @State private var headRotation: CGFloat = 0.0
    @State private var headScale: CGFloat = 1.0
    @State private var catX: CGFloat = 0
    @State private var catY: CGFloat = 0
    
    @State private var timerRunning = true
    
    var pose: Int = 0
    var cat_On: Bool
    
    private let menuBarHeight = NSApplication.shared.mainMenu?.menuBarHeight ?? 24

    var body: some View {
        return ZStack {
            if pose == 99 {
                if let image = capturedImage {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: FullScreen.width, height: FullScreen.height)
                }
                
                Color.clear
                    .overlay(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                if cat_On {
                    Image("clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: FullScreen.height/2, height: FullScreen.height/2)
                        .offset(y: -100)
                }
                
                VStack (spacing: 10) {
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("사용자의 얼굴이 인식되길 기다리고 있어요..")
                        .font(.custom("DungGeunMo", size: 16))
                        .foregroundStyle(.black.opacity(0.8))
                    Spacer()
                }
            }
            
            // 저조도 피드백
            if pose == 10 {
                if let image = capturedScreenshot, image.representations.count > 0 {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: FullScreen.width, height: FullScreen.height)
                        .scaleEffect(zoom)
                }
                Rectangle()
                    .fill(Color.black)
                    .opacity(opa)
            }
            
            // 확대 피드백
            if pose == 20 {
                if let image = capturedScreenshot, image.representations.count > 0 {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: FullScreen.width, height: FullScreen.height)
                        .scaleEffect(zoom)
                }
                
                if cat_On {
                    Image("tooClose")
                        .resizable()
                        .frame(width: FullScreen.width)
                        .offset(y: catY)
                }
            }
            
            // 블러 피드백
            else if pose == 30 {
                if let image = capturedScreenshot, image.representations.count > 0 {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: FullScreen.width, height: FullScreen.height)
                        .scaleEffect(zoom)
                        .rotationEffect(.degrees(rotation))
                        .blur(radius: blur)
                        .onAppear {
                            withAnimation(.easeIn(duration: 2)) {
                                blur = 10
                            }
                        }
                }
            }
            
            // 흘러내리는 피드백
            else if pose == 41 || pose == 42 {
                if let image = capturedImage {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: FullScreen.width, height: FullScreen.height)
                }
                
                Color.clear
                    .overlay(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                if cat_On{
                    Image("chin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: FullScreen.height/1.2)
                        .opacity(0.8)
                        .scaleEffect(x: pose == 42 ? -1 : 1, y: 1, anchor: .center)
                }
                
                ZStack {
                    ForEach(0..<40, id: \.self) { index in
                        if let image = capturedScreenshot?.copy() as? NSImage {
                            let delay: Double = Double(index) * 0.1
                            let progress: Float = max(0, elapsedTime - Float(delay))
                            let width: CGFloat = FullScreen.width
                            let height: CGFloat = FullScreen.height
                            let maskWidth: CGFloat = width * 1.7
                            let maskHeight: CGFloat = height / 20
                            let maskOffsetY: CGFloat = -height + maskHeight * CGFloat(index)
                            let offsetX: CGFloat = pow(CGFloat(progress), 3) * cos(.pi / 6) * diagonalAngle * 30
                            let offsetY: CGFloat = pow(CGFloat(progress), 3) * sin(.pi / 6) * abs(diagonalAngle) * 30
                            
                            Image(nsImage: image)
                                .resizable()
                                .mask(
                                    Rectangle()
                                        .frame(width: maskWidth, height: maskHeight)
                                        .offset(y: maskOffsetY)
                                        .rotationEffect(.degrees(diagonalAngle))
                                )
                                .offset(x: offsetX, y: offsetY)
                        }
                    }
                }
            }
            
            // 거북목 피드백
            else if pose == 50 {
                if let image = capturedImage {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: FullScreen.width, height: FullScreen.height)
                }
                
                Color.clear
                    .overlay(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                if cat_On {
                    Image("money")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 1000, height: 1000)
                }
                
                if let image = capturedScreenshot, image.representations.count > 0 {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: FullScreen.width, height: FullScreen.height)
                        .scaleEffect(zoom)
                        .rotation3DEffect(
                            .degrees(rotation),
                            axis: (x: 1.0, y: 0.0, z: 0.0),
                            anchor: .bottom,
                            perspective: 0.6
                        )
                }
            }
            
            // 피드백 텍스트 이펙트
            VStack {
                Spacer()
                Spacer()
                Spacer()
                Text(displayedMent)
                    .font(.custom("DungGeunMo", size: 60))
                    .foregroundStyle(.white)
                    .background(Color.black.opacity(0.75))
                    .onAppear {
                        // Typewriter animation for displayedMent
                        displayedMent = ""
                        let characters = Array(ment)
                        for (i, char) in characters.enumerated() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.1) {
                                displayedMent.append(char)
                            }
                        }
                    }
                Spacer()
            }
        }
        .frame(width: FullScreen.width, height: FullScreen.height)
        .onAppear {
            captureFullscreen()
            
            CameraFrame.capture { image in
                if let captured = image {
                    capturedImage = captured
                }
            }
            
            switch pose {
            case 10:
                withAnimation(.easeInOut(duration: 1)) {
                    opa = 1.0
                }
            case 20:
                ment = "안돼! 빨려들어가고 있어요!"
                catY = FullScreen.height
                withAnimation(.easeIn(duration: 4)) {
                    zoom = 20
                    catY = 0
                }
            case 30:
                ment = "눈을 깜빡이실 시간이에요!"
                
            case 41:
                ment = "고개가 무너져내렸어요.."
                diagonalAngle = 30
            case 42:
                ment = "고개가 무너져내렸어요.."
                diagonalAngle = -30
            case 50:
                ment = "목 디스크 수술비 2천만원.."
                withAnimation(.easeIn(duration: 2)) {
                    rotation = 80
                }
            default:
                break
            }
        }
        .onReceive(Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()) { _ in
            if timerRunning {
                elapsedTime += 1/60
            }
        }
        .onDisappear {
            timerRunning = false
        }
    }

    func captureFullscreen() {
        let path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("screenshot.jpg").path
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-x", path]  // -x: 사운드 없이 캡처

        task.launch()
        task.waitUntilExit()

        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let image = NSImage(data: data) {
            self.capturedScreenshot = image
            print("📸 전체화면 스크린샷 성공")
        } else {
            print("❌ 이미지 로드 실패")
        }
    }
}

extension View {
    func flipHorizontally() -> some View {
        self.scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
