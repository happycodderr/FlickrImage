import Foundation
import UIKit

class ImageDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var displayImageDesc: UILabel!
    
    func setData(_ imageDetail: ImageDetail) {
        displayImageDesc.text = imageDetail.title
        displayImage.loadImageFromUrl(urlString: imageDetail.url)
    }

}
