import Foundation
import AVFoundation

class SocketClient {
    private var socketFD: Int32 = -1
    private let serverIP = "127.0.0.1"
    private let serverPort: UInt16 = 9000

    func connect() -> Bool {
        socketFD = socket(AF_INET, SOCK_STREAM, 0)
        guard socketFD >= 0 else {
            print("❌ 소켓 생성 실패")
            return false
        }

        var serverAddr = sockaddr_in()
        serverAddr.sin_family = sa_family_t(AF_INET)
        serverAddr.sin_port = serverPort.bigEndian
        inet_pton(AF_INET, serverIP, &serverAddr.sin_addr)

        let result = withUnsafePointer(to: &serverAddr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.connect(socketFD, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        if result < 0 {
            print("❌ 서버 연결 실패")
            close(socketFD)
            return false
        }

        return true
    }

    func sendImageData(_ data: Data) -> Int? {
        guard connect() else { return nil }

        var length = UInt32(data.count).bigEndian
        withUnsafeBytes(of: &length) {
            _ = send(socketFD, $0.baseAddress!, 4, 0)
        }
        _ = data.withUnsafeBytes {
            send(socketFD, $0.baseAddress!, data.count, 0)
        }

        var buffer = [UInt8](repeating: 0, count: 4)
        _ = recv(socketFD, &buffer, 4, 0)
        let result = buffer.withUnsafeBytes {
            $0.load(as: UInt32.self).bigEndian
        }

        close(socketFD)
        return Int(result)
    }
}
