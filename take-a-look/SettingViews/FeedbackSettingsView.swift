import SwiftUI

struct FeedbackSettingsView: View {
    @Binding var feedback1_On: Bool
    @Binding var feedback2_On: Bool
    @Binding var feedback3_On: Bool
    @Binding var feedback4_On: Bool
    @Binding var feedback5_On: Bool
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 6) {
                HStack {
                    Toggle("", isOn: $feedback1_On)
                        .toggleStyle(.checkbox)
                        .frame(width: 20, height: 20)
                        .offset(y: -2)
                    Image(systemName: "lightbulb.slash")
                        .scaledToFit()
                        .frame(width: 20)
                    Text("어두운 환경")
                }
                HStack {
                    Toggle("", isOn: $feedback2_On)
                        .toggleStyle(.checkbox)
                        .frame(width: 20, height: 20)
                        .offset(y: -2)
                    Image(systemName: "ruler")
                        .scaledToFit()
                        .frame(width: 20)
                    Text("가까운 거리")
                }
                HStack {
                    Toggle("", isOn: $feedback3_On)
                        .toggleStyle(.checkbox)
                        .frame(width: 20, height: 20)
                        .offset(y: -2)
                    Image(systemName: "eye.trianglebadge.exclamationmark")
                        .scaledToFit()
                        .frame(width: 20)
                    Text("안구 건조증")
                }
                HStack {
                    Toggle("", isOn: $feedback4_On)
                        .toggleStyle(.checkbox)
                        .frame(width: 20, height: 20)
                        .offset(y: -2)
                    Image(systemName: "person.and.background.striped.horizontal")
                        .scaledToFit()
                        .frame(width: 20)
                    Text("어깨 비대칭")
                }
                HStack {
                    Toggle("", isOn: $feedback5_On)
                        .toggleStyle(.checkbox)
                        .frame(width: 20, height: 20)
                        .offset(y: -2)
                    Image(systemName: "tortoise")
                        .scaledToFit()
                        .frame(width: 20)
                    Text("거북목")
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
