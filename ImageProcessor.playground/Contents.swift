//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")

// Process the image!

var imageToModify = RGBAImage(image: image!)!

let width = imageToModify.height
let height = imageToModify.width

let totalRed = 0
let totalGreen = 0
let totalBlue = 0

func executeForEachPixel(image: RGBAImage, logic: (index: Int, pixel: Pixel) -> Void) {
    for index in 0..<image.width * image.height {
        logic(index: index, pixel: image.pixels[index])
    }
}

var colorSums = (0, 0, 0)
executeForEachPixel(imageToModify) { index, pixel in
    colorSums = (colorSums.0 + Int(pixel.red), colorSums.1 + Int(pixel.green), colorSums.2 + Int(pixel.blue))
}

let totalPixelCount = width * height
let colorAvgs = (colorSums.0 / totalPixelCount, colorSums.1 / totalPixelCount, colorSums.2 / totalPixelCount)
let redAvg = colorAvgs.0
let greenAvg = colorAvgs.1
let blueAvg = colorAvgs.2

print(colorAvgs)

executeForEachPixel(imageToModify) { index, pixel in
    let diff = Int(pixel.red) - redAvg
    
    if diff > 0 {
        var pixelToChange = pixel
        let newRed = UInt8(min(255, redAvg + 3 * diff))
        pixelToChange.red = newRed
        imageToModify.pixels[index] = pixelToChange
    }
}

let newImage = imageToModify.toUIImage()!


