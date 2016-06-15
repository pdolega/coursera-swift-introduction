//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")

// Process the image!


class Filter {
    func filter(inout image: RGBAImage) -> Void {
        
    }
    
    func executeForEachPixel(inout image: RGBAImage, logic: (index: Int, pixel: Pixel) -> Void) {
        for index in 0..<image.width * image.height {
            logic(index: index, pixel: image.pixels[index])
        }
    }
}

class FilterProcessor {
    func process(srcImage: UIImage, filters: Filter...) -> UIImage {
        var imageToModify = RGBAImage(image: srcImage)!

        filters.forEach {
            $0.filter(&imageToModify)
        }
        
        return imageToModify.toUIImage()!
    }
}

class AmplifyRedFilter: Filter {
    override func filter(inout image: RGBAImage) -> Void {
        var colorSums = (0, 0, 0)

        executeForEachPixel(&image) { index, pixel in
            colorSums = (colorSums.0 + Int(pixel.red), colorSums.1 + Int(pixel.green), colorSums.2 + Int(pixel.blue))
        }
        
        let totalPixelCount = image.width * image.height
        let colorAvgs = (colorSums.0 / totalPixelCount, colorSums.1 / totalPixelCount, colorSums.2 / totalPixelCount)
        let redAvg = colorAvgs.0
        
        executeForEachPixel(&image) { index, pixel in
            let diff = Int(pixel.red) - redAvg
            
            if diff > 0 {
                var pixelToChange = pixel
                let newRed = UInt8(min(255, redAvg + 3 * diff))
                pixelToChange.red = newRed
                image.pixels[index] = pixelToChange
            }
        }
    }
}

let processor = FilterProcessor()
let processedImage = processor.process(image!, filters: AmplifyRedFilter())
