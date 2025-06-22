import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject var responseStore = ServerResponseStore.shared
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 10) {
                Text("General tab")
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
