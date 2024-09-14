extension String {
    public static func convertToUnsafePointer(from string: String?) -> UnsafePointer<CChar>? {
        guard let unwrappedString = string else {
            return nil
        }
        let cString = unwrappedString.cString(using: .utf8)
        return cString?.withUnsafeBufferPointer { buffer in
            return buffer.baseAddress
        }
    }
}
