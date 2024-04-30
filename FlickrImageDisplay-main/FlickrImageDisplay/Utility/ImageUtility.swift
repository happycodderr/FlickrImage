import Foundation
import UIKit

class ImageUtility {
    static func saveFile(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveFileComplete), nil)
    }
    
    @objc func saveFileComplete(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save File Completed!")
    }
}

