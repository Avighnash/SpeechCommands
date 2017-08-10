import Foundation

class Command {
    
    var command: String
    
    var action: (() -> Void)?
    
    init(command commandValue: String) {
        self.command = commandValue
    }
    
    func response(action actionValue: @escaping () -> Void) {
        self.action = actionValue
    }
}
