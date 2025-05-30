import SwiftUI;

struct SidebarView: View {
    @Binding var messageItems: [MessageItem];
    @Binding var selectedItem: MessageItem?;
    
    @State private var showAddMessageAlert = false;
    @State private var newMessage = MessageItem(
        name: "",
        endpointURL: "",
        queueURL: "",
        region: "",
        messageBody: ""
    );
    
    var body: some View {
        List(selection: $selectedItem) {
            ForEach(self.messageItems.reversed()) { item in
                HStack {
                    Text(item.name)
                        .foregroundColor(Color(NSColor.labelColor));
                }
                .background(self.selectedItem == item
                    ? Color(NSColor.selectedControlColor)
                    : Color(Color.clear)
                )
                .cornerRadius(5)
                .tag(item);
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
        .background(Color(NSColor.windowBackgroundColor))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {showAddMessageAlert.toggle()}) {
                    Label("Add Message", systemImage: "plus");
                }
            }
        }
        .sheet(isPresented: $showAddMessageAlert) {
            VStack {
                Text("Message Name");
                TextField("Message Name", text: $newMessage.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle());
                Button(action: addMessage) {
                    Label("Add Message", systemImage: "plus");
                }
            }
            .padding();
        }
    }
    
    private func addMessage() {
        messageItems.append(newMessage);
        selectedItem = messageItems.last;
        
        newMessage = MessageItem(
            name: "",
            endpointURL: "",
            queueURL: "",
            region: "",
            messageBody: ""
        );
        
        showAddMessageAlert.toggle();
    }
}
