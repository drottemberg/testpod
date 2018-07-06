//
//  ImagesStitchingManager.swift
//  snapstar
//
//  Created by Nur  on 13/12/2016.
//  Copyright © 2016 SnapStar. All rights reserved.
//

import UIKit

/**
  in charge of aggregating and stitching images of receipts in order to prepare them for S3 uploading
  - Author: Nur
 */
class ImagesStitchingManager: NSObject {

    /**
     * @return lazy singleton of the manager
     */
    static let sharedInstance = ImagesStitchingManager()
    
    private var imagesArray:[UIImage?] = []
    
    /**
    * just takes the array of images and adds them one by one from the top to bottom
    *
    * - Author: Nur
    */
    func stitchImagesNaiively() -> UIImage? {
        // calc max height & width
        var dimensions = CGSize(width: 0.0, height: 0.0)
        for image in imagesArray {
            dimensions.width = max(dimensions.width, image!.size.width)
            dimensions.height += image!.size.height
        }

        UIGraphicsBeginImageContext(dimensions)

        var lastY = CGFloat(0.0)
        for image in imagesArray {
            image?.draw(in:CGRect(x: 0, y: lastY, width: dimensions.width, height: image!.size.height))
            lastY += image!.size.height
        }
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    /**
      rotates the image 90° clockwise so it works with the stitching algorithm provided by OpenCV
      - Parameter image: to rotate
      - Returns: rotated image
      - Author: nur
     */
    func rotateImage(image: UIImage) -> UIImage {
        let rotated = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: .right)
        return rotated
    }

    func appendImage(image: UIImage) {
        // must rotate image before appending it because of stitching algorithm -nur
        //let rotatedImage = rotateImage(image: image)
        self.imagesArray.append(image)
    }
    
    func removeLastImage() {
        _ = self.imagesArray.popLast()
    }
    
    func removeAllImages() {
        self.imagesArray.removeAll()
    }
    
    func getLastImage() -> UIImage! {
        return self.imagesArray.last!
    }
    
    func hasImages() -> Bool {
        return self.imagesArray.count > 0
    }
    
    func imagesCount() -> Int {
        return self.imagesArray.count
    }
    
    func getImages() -> [UIImage?] {
        return self.imagesArray
    }

    
    
}
