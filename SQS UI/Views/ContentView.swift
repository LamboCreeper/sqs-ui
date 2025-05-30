import SwiftUI;
import Foundation;

struct ContentView: View {
    @State var selectedItem: MessageItem?;
    @State var messages: [MessageItem] = [];

    var body: some View {
        NavigationView {
            SidebarView(
                messageItems: $messages,
                selectedItem: $selectedItem
            );
            
            if let selectedItem = selectedItem {
                ConfigurationView(
                    messageItems: $messages,
                    selectedItem: Binding(
                        get: { selectedItem },
                        set: { val in self.selectedItem = val }
                    )
                );
            } else {
                Text("Select or Create Message");
            }
        }
        .onAppear() {
            self.loadMessages();
        }
        .onDisappear() {
            self.saveMessages();
        }
    }
    
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: "messages") {
            if let decodedMessages = try? JSONDecoder().decode([MessageItem].self, from: data) {
                print("Got \(decodedMessages.count) messages");

                self.messages = decodedMessages;
            }
        }
    }
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: "messages");
            
            print("Saved \(messages.count) messages");
        }
    }
}

#Preview {
    ContentView();
}
