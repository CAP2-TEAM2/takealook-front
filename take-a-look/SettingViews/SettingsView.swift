import SwiftUI

struct AppSettings {
    static var shared = AppSettings()
    var talOn: Bool = true
}

struct SettingsView: View {
    @ObservedObject var responseStore = ServerResponseStore.shared
    
    @State private var talOn: Bool = AppSettings.shared.talOn
    
    @AppStorage("transparency") private var transparency: Double = 1.0
    
    @AppStorage("cat_On") private var cat_On: Bool = true
    
    @AppStorage("feedback1_On") private var feedback1_On: Bool = true
    @AppStorage("feedback2_On") private var feedback2_On: Bool = true
    @AppStorage("feedback3_On") private var feedback3_On: Bool = true
    @AppStorage("feedback4_On") private var feedback4_On: Bool = true
    @AppStorage("feedback5_On") private var feedback5_On: Bool = true
    
    @State private var selectedTab: String = "일반"
    
    let options = ["일반", "화면 피드백", "제스처 컨트롤", "기타"]
    
    var body: some View {
        VStack (alignment: .center) {
            ZStack {
                HStack {
                    Image(systemName: "pawprint")
                        .bold(true)
                    Spacer()
                }
                .padding(.horizontal, 10)
                HStack {
                    Spacer()
                    Text("Take a Look")
                        .font(.custom("DungGeunMo", size: 18))
                    Spacer()
                }
                HStack {
                    Spacer()
                    Toggle("", isOn: $talOn)
                        .toggleStyle(.switch)
                        .tint(.orange)
                        .onChange(of: talOn) { _, newValue in
                            AppSettings.shared.talOn = newValue
                            if !newValue {
                                PopupWindowManager.shared.closePopup()
                            }
                        }
                }
                .padding(.horizontal, 10)
            }
            .foregroundStyle(.black.opacity(0.8))
            .padding(.top, 10)
            
            Picker("", selection: $selectedTab) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(.segmented)
            .offset(x: -3)
            
            Spacer()
            
            // 선택된 항목에 따라 내용 변경
            switch selectedTab {
            case "일반":
                VStack {
                    HStack {
                        Toggle("", isOn: $cat_On)
                            .toggleStyle(.checkbox)
                            .frame(width: 20, height: 20)
                            .offset(y: -2)
                        Text("고양이 애호가")
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 40)
                    
                    HStack {
                        Text(String(format: "투명도 : %.1f", transparency))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Slider(value: $transparency, in: 0.8...1)
                        .padding(.horizontal, 20)

                    Spacer()
                }
                .frame(width: 300)
                
            case "화면 피드백":
                FeedbackSettingsView(
                    feedback1_On: $feedback1_On,
                    feedback2_On: $feedback2_On,
                    feedback3_On: $feedback3_On,
                    feedback4_On: $feedback4_On,
                    feedback5_On: $feedback5_On
                )
            case "제스처 컨트롤":
                GestureControl(cat_On: cat_On)
            default:
                Text("\(String(describing: responseStore.value))")
            }
            
            Spacer()
        }
        .background (
            ZStack {
                if talOn {
                    CameraView()
                }
                Color.clear
                    .overlay(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .opacity(transparency)
            }
        )
        .onChange(of: responseStore.value) {
            if talOn {
                if let value: Int = responseStore.value {
                    let digits = String(format: "%05d", value).compactMap { Int(String($0)) }
                    //              밝기 / 얼굴 거리 / 눈 깜빡임 / 어깨, 턱 각도 / 거북목
                    let val1 = digits[0]
                    let val2 = digits[1]
                    let val3 = digits[2]
                    let val4 = digits[3]
                    let val5 = digits[4]
                    
                    if value == 99999 {
                        print("NO Face")
                        PopupWindowManager.shared.closePopup()
                        PopupWindowManager.shared.showPopup() {
                            FeedbackView(pose: 99, cat_On: cat_On)
                        }
                    }
                    
                    if value == 11111 {
                        PopupWindowManager.shared.closePopup()
                        return
                    }
                    // 어두움
                    if val1 == 2 && feedback1_On{
                        //                        PopupWindowManager.shared.closePopup()
                        PopupWindowManager.shared.showPopup() {
                            FeedbackView(pose: 10, cat_On: cat_On)
                        }
                    }
                    
                    // 가까움
                    if val2 == 2 && feedback2_On{
                        //                        PopupWindowManager.shared.closePopup()
                        PopupWindowManager.shared.showPopup() {
                            FeedbackView(pose: 20, cat_On: cat_On)
                        }
                    }
                    
                    // 눈 깜빡임
                    if val3 == 2 && feedback3_On {
                        //                        PopupWindowManager.shared.closePopup()
                        PopupWindowManager.shared.showPopup() {
                            FeedbackView(pose: 30, cat_On: cat_On)
                        }
                    }
                    
                    // 턱, 어깨 각도
                    if val4 == 2 && feedback4_On {
                        //                        PopupWindowManager.shared.closePopup()
                        PopupWindowManager.shared.showPopup() {
                            FeedbackView(pose: 41, cat_On: cat_On)
                        }
                    }
                    else if val4 == 3 && feedback4_On {
                        //                        PopupWindowManager.shared.closePopup()
                        PopupWindowManager.shared.showPopup() {
                            FeedbackView(pose: 42, cat_On: cat_On)
                        }
                    }
                    
                    // 거북목
                    else if (val4 == 1 && val5 == 2) && feedback5_On {
                        //                        PopupWindowManager.shared.closePopup()
                        PopupWindowManager.shared.showPopup() {
                            FeedbackView(pose: 50, cat_On: cat_On)
                        }
                    }
                }
            }
        }
    }
}
