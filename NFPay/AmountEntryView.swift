import SwiftUI

struct AmountEntryView: View {
    @State private var amount = ""
    var onSend: () -> Void
    var onRequest: () -> Void

    let grid = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Ishan Godawatta")
                    .font(.headline)
                Text("40-75-65 | 82657475")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)

            Text("£\(formattedAmount)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .padding(.bottom, 20)

            LazyVGrid(columns: grid, spacing: 16) {
                ForEach(numberPadKeys, id: \.self) { key in
                    Button(action: { handleKeyPress(key) }) {
                        Text(keyDisplay(key))
                            .font(.title)
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: submitSend) {
                    Text("Send")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .font(.title3)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: submitRequest) {
                    Text("Request")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .font(.title3)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    private var formattedAmount: String {
        let value = Double(amount) ?? 0
        let pounds = value / 100
        return String(format: "%.2f", pounds)
    }

    private var numberPadKeys: [String] {
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "←", "0", "✓"]
    }

    private func handleKeyPress(_ key: String) {
        switch key {
        case "←":
            if !amount.isEmpty { amount.removeLast() }
        case "✓":
            submitSend()
        default:
            if amount.count < 6 {
                amount.append(key)
            }
        }
    }

    private func keyDisplay(_ key: String) -> String {
        key == "✓" ? "✓" : key
    }

    private func submitSend() {
        let finalAmount = formattedAmount
        print("Sending £\(finalAmount)...")

        // Build the URL with the amount in the query string
        let urlString = "https://luckily-learning-elf.ngrok-free.app/send?amount=\(finalAmount)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Send failed: \(error.localizedDescription)")
            } else if let data = data,
                      let responseMessage = try? JSONDecoder().decode(SendResponse.self, from: data) {
                print("✅ \(responseMessage.message)")
            } else {
                print("✅ Sent, but could not parse response.")
            }
        }

        task.resume()
        onSend()
    }

    private func submitRequest() {
        let finalAmount = formattedAmount
        print("Requesting £\(finalAmount)...")

        // Build the URL with the amount in the query string
        let urlString = "https://luckily-learning-elf.ngrok-free.app/request?amount=\(finalAmount)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed: \(error.localizedDescription)")
            } else if let data = data,
                      let responseMessage = try? JSONDecoder().decode(SendResponse.self, from: data) {
                print("✅ \(responseMessage.message)")
            } else {
                print("✅ Requested, but could not parse response.")
            }
        }

        task.resume()
        onRequest()
    }
}

struct SendResponse: Codable {
    let status: String
    let message: String
}
