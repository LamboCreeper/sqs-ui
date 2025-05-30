import Foundation

struct MessageItem: Codable, Identifiable, Hashable {
    var id: UUID = UUID();
    var name: String;
    var endpointURL: String;
    var queueURL: String;
    var region: String;
    var messageBody: String;
}
