import SwiftNotCurses

public actor CommandInput {

    private var inputs: [Character]

    public static let shared = CommandInput()

    private var lastCommandOutput: String

    private var cursorPositionInWord: Int

    private init() {
        self.inputs = []
        self.lastCommandOutput = ""
        self.cursorPositionInWord = 0
    }

    private func deletePressed(_ newInput: Input) -> Bool {
        if newInput.id == 1115008 {
            // DELETE pressed
            if !inputs.isEmpty {
                self.cursorPositionInWord -= 1
                inputs.remove(at: cursorPositionInWord)
            }
            return true
        }
        return false
    }

    private func arrowKeysPressed(_ newInput: Input) -> Bool {
        switch newInput.id {
        case 1115005:
            // left
            if cursorPositionInWord > 0 {
                cursorPositionInWord -= 1
            }
            return true
        case 1115003:
            // right
            if cursorPositionInWord < inputs.count {
                cursorPositionInWord += 1
            }
            return true
        default:
            return false
        }
    }

    public func add(_ newInput: Input) async {
        guard !deletePressed(newInput) else {
            return
        }
        guard !arrowKeysPressed(newInput) else {
            return
        }
        guard !newInput.utf8.isEmpty else {
            return
        }
        inputs.insert(Character(newInput.utf8), at: cursorPositionInWord)
        cursorPositionInWord += 1
    }

    public func getCursorPosition() async -> Int {
        self.cursorPositionInWord
    }

    public func add(_ newCharacter: Character) async {
        inputs.append(newCharacter)
        cursorPositionInWord += 1
    }

    public func add(_ string: String) async {
        for char in string {
            self.inputs.append(char)
        }
        cursorPositionInWord += string.count
    }

    public func clear() async {
        self.inputs = []
        cursorPositionInWord = 0
    }

    public func get() async -> String {
        String(self.inputs)
    }

    public func setLastCommandOutput(_ newValue: String) async {
        self.lastCommandOutput = newValue
    }

    public func getLastCommandOutput() async -> String {
        self.lastCommandOutput
    }

}
