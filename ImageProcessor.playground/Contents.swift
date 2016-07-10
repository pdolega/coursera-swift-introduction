//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")

// Process the image!

// Base filter class
class Filter {
    func filter(inout image: RGBAImage) -> Void {
        
    }
    
    func executeForEachPixel(inout image: RGBAImage, logic: (index: Int, pixel: Pixel) -> Void) {
        for index in 0..<image.width * image.height {
            logic(index: index, pixel: image.pixels[index])
        }
    }
}

// Filter processor allowing application of multiple filters to single image
class FilterProcessor {
    func process(srcImage: UIImage, filters: Filter...) -> UIImage {
        var imageToModify = RGBAImage(image: srcImage)!

        filters.forEach {
            $0.filter(&imageToModify)
        }
        
        return imageToModify.toUIImage()!
    }
}

// Generic amplify filter
class AmplifyFilter: Filter {
    enum Color: Int {
        case RED = 0
        case GREEN = 1
        case BLUE = 2
    }
    
    let colorToAmplify: Color
    let amplification: Double
    
    init(color: Color, amplification: Double = 3.0) {
        colorToAmplify = color
        self.amplification = amplification
    }
    
    private func colorValue(pixel: Pixel, color: Color) -> UInt8 {
        switch color {
        case .RED:
            return pixel.red
        case .GREEN:
            return pixel.green
        case .BLUE:
            return pixel.blue
            
        }
    }
    
    private func avgColorComponent(avgs: (Int, Int, Int)) -> Int {
        switch colorToAmplify {
        case .RED:
            return avgs.0
        case .GREEN:
            return avgs.1
        case .BLUE:
            return avgs.2
            
        }
    }
    
    private func assignColor(inout pixel: Pixel, newColor: UInt8) -> Pixel {
        switch colorToAmplify {
        case .RED:
            pixel.red = newColor
        case .GREEN:
            pixel.green = newColor
        case .BLUE:
            pixel.blue = newColor
            
        }
        
        return pixel
    }
    
    override func filter(inout image: RGBAImage) -> Void {
        var colorSums = (0, 0, 0)

        executeForEachPixel(&image) { index, pixel in
            colorSums = (colorSums.0 + Int(pixel.red), colorSums.1 + Int(pixel.green), colorSums.2 + Int(pixel.blue))
        }
        
        let totalPixelCount = image.width * image.height
        let colorAvgs = (colorSums.0 / totalPixelCount, colorSums.1 / totalPixelCount, colorSums.2 / totalPixelCount)
        
        executeForEachPixel(&image) { index, pixel in
            let colorAvg = self.avgColorComponent(colorAvgs)
            let diff = Int(self.colorValue(pixel, color: self.colorToAmplify)) - colorAvg
            
            if diff > 0 {
                var pixelToChange = pixel
                let newColorUncapped = colorAvg + Int(Double(diff) * self.amplification)
                let newColor = UInt8(min(255, newColorUncapped))
                self.assignColor(&pixelToChange, newColor: newColor)
                image.pixels[index] = pixelToChange
            }
        }
    }
}

class GrayScaleFilter: Filter {
    let weightRed: Double
    let weightGreen: Double
    let weightBlue: Double
    
    init(weightRed: Double = 1, weightGreen: Double = 1, weightBlue: Double = 1) {
        self.weightRed = weightRed
        self.weightGreen = weightGreen
        self.weightBlue = weightBlue
    }
    
    override func filter(inout image: RGBAImage) -> Void {
        executeForEachPixel(&image) { index, pixel in
            let gray = UInt8((self.weightRed * Double(pixel.red) + self.weightGreen * Double(pixel.green) + self.weightBlue * Double(pixel.blue)) / 3)
            var pixelToChange = pixel
            pixelToChange.red = gray
            pixelToChange.green = gray
            pixelToChange.blue = gray
            image.pixels[index] = pixelToChange
        }
    }
}

// and here we have default filters predefined
class DefaultFilters {
    static let AmplifyRed = AmplifyFilter(color: .RED)
    static let AmplifyGreen = AmplifyFilter(color: .GREEN)
    static let AmplifyBlue = AmplifyFilter(color: .BLUE)
    
    static let DampenRed = AmplifyFilter(color: .RED, amplification: 0.25)
    static let DampenGreen = AmplifyFilter(color: .GREEN, amplification: 0.25)
    static let DampenBlue = AmplifyFilter(color: .BLUE, amplification: 0.25)
    
    static let GrayScale = GrayScaleFilter(weightRed: 0.3, weightGreen: 0.59, weightBlue: 0.11)
}


// and here is testing
let processor = FilterProcessor()
let processedImage0 = processor.process(UIImage(named: "sample")!, filters: AmplifyFilter(color: .RED, amplification: 0.33))

let processedImage1 = processor.process(UIImage(named: "sample")!, filters: AmplifyFilter(color: .GREEN, amplification: 3))

let processedImage2 = processor.process(UIImage(named: "sample")!, filters: GrayScaleFilter())


let processedImage3 = processor.process(UIImage(named: "sample")!, filters: DefaultFilters.DampenBlue)




