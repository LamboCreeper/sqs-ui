import SwiftUI;
import Foundation;

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            self.isAutomaticQuoteSubstitutionEnabled = false;
        }
    }
}

struct ConfigurationView: View {
    @Binding var messageItems: [MessageItem];
    @Binding var selectedItem: MessageItem;

    @State var output: String?;
    
    var regions: [String] = ["eu-west-1"];

    var body: some View {
        if output != nil {
            Text(output!).font(.system(.body, design: .monospaced)).padding();
        }
        
        HStack {
            Form {
                TextField("Endpoint URL", text: $selectedItem.endpointURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle());

                TextField("Queue URL", text: $selectedItem.queueURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle());

                Picker("Region", selection: $selectedItem.region) {
                    ForEach(regions, id: \.self) { region in
                        Text(region).tag(region);
                    }
                }.pickerStyle(MenuPickerStyle());

                LabeledContent("Message Body") {
                    TextEditor(text: $selectedItem.messageBody)
                        .font(.system(.body, design: .monospaced))
                        .frame(height: 200)
                        .border(Color.gray, width: 1);
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: executeMessage) {
                    Label("Execute", systemImage: "play")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button(action: saveMessage) {
                    Label("Save", systemImage: "pencil")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button(action: deleteMessage) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    private func deleteMessage() {
        if let index = messageItems.firstIndex(where: {
            $0.id == self.selectedItem.id
        }) {
            messageItems.remove(at: index);
        }
    }

    private func saveMessage() {
        if let index = messageItems.firstIndex(where: {
            $0.id == self.selectedItem.id
        }) {
            messageItems[index] = self.selectedItem;
        }
    }
    
    private func executeMessage() {
        print("Executing...");
        
        do {
            let task = Process();
            let pipe = Pipe();

            task.standardOutput = pipe;
            task.standardError = pipe;
            task.standardInput = nil;
            task.executableURL = URL(fileURLWithPath: "/bin/zsh");
            
            print(selectedItem.messageBody);
            
            let command = [
                "--endpoint-url=\(selectedItem.endpointURL)",
                "sqs", "send-message",
                "--queue-url", selectedItem.queueURL,
                "--region", selectedItem.region,
                "--message-body", "'\(selectedItem.messageBody)'"
            ];

            task.arguments = [
                "-c", "/opt/homebrew/bin/aws \(command.joined(separator: " "))"
            ];

            try task.run();
            
            task.waitUntilExit();
            
            output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: "}", with: "");
            
            print(output!);
        } catch {
            print(error);
        }
    }
}
