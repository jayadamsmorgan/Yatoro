import AppKit

// Function to download image data from a URL
func downloadImageData(from url: URL, completion: @escaping @Sendable (Data?) async -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            Task {
                await completion(nil)
            }
            return
        }
        Task {
            await completion(data)
        }
    }
    task.resume()
}

// Function to create an NSImage from Data
func imageFromData(_ data: Data) -> NSImage? {
    return NSImage(data: data)
}

// Function to extract RGBA byte array from NSImage
func rgbaByteArray(from image: NSImage) -> [UInt8]? {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return nil
    }

    let width = cgImage.width
    let height = cgImage.height

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

    var pixelData = [UInt8](repeating: 0, count: Int(width * height * 4))

    let success = pixelData.withUnsafeMutableBytes { ptr -> Bool in
        guard
            let context = CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            )
        else {
            return false
        }

        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(cgImage, in: rect)
        return true
    }

    return success ? pixelData : nil
}

// Main function to download the image and convert it to RGBA byte array
func downloadImageAndConvertToRGBA(url: URL, completion: @escaping @Sendable ([UInt8]?) async -> Void) {
    downloadImageData(from: url) { data in
        guard let data = data else {
            await completion(nil)
            return
        }
        guard let image = imageFromData(data) else {
            await completion(nil)
            return
        }
        guard let pixelArray = rgbaByteArray(from: image) else {
            await completion(nil)
            return
        }
        await completion(pixelArray)
    }
}
