// base class
public class RGBAFilter {
    
    public var factor: Double = 0.0 //the parameters to change the intensity of the effect
    
    public var averageColor: [UInt8] = [0,0,0] //red green blue
    
    public required init( _ factor_in: Double?=nil) {
        if (factor_in != nil) {
            factor = factor_in!
        }
    }
    
    public func toString()-> String {
        var str = String(self.dynamicType)
        str += " factor:\(factor)"
        return str
    }
    
    public func apply( inout image_in: RGBAImage )-> Void {
        for pixel_index in 0..<image_in.pixels.count {
            pixel_filter( &image_in.pixels[ pixel_index ] )
        }
    }
    
    private func pixel_filter( inout pixel: Pixel )-> Void {}
    
    // range of R G B A value
    private func hex_range( number: Double )-> UInt8 {
        return UInt8( min( 255, max( 0, number )))
    }
    
    public func setAverageColor(r: UInt8, g: UInt8, b: UInt8) {
        averageColor[0] = r
        averageColor[1] = g
        averageColor[2] = b
    }
    
}

/*
 class of filter
 -- red
 -- green
 -- blue
 -- alpha
 -- invert
 -- blackandwhite
 -- sepiatone
 -- grayscale
 -- brightness
 -- contrast
 */

public class RedFilter: RGBAFilter {
    // factor > 1 increase red color: 2~10
    // factor < 1 decrease red color: 1/2 ~ 1/10
    override func pixel_filter( inout pixel: Pixel )-> Void {
        let avgRed = averageColor[0]
        let diff = Int(pixel.red) - Int(avgRed)
        if (diff > 0) {
            pixel.red = hex_range( Double(avgRed) + Double(diff) * factor )
        }
    }
}

public class GreenFilter: RGBAFilter {
    // factor > 1 increase green color
    // factor < 1 decrease green color
    override func pixel_filter( inout pixel: Pixel )-> Void {
        let avgGreen = averageColor[1]
        let diff = Int(pixel.green) - Int(avgGreen)
        if (diff > 0) {
            pixel.green = hex_range( Double(avgGreen) + Double(diff) * factor )
        }
    }
}

public class BlueFilter: RGBAFilter {
    // factor > 1 increase blue color
    // factor < 1 decrease blue color
    override func pixel_filter( inout pixel: Pixel )-> Void {
        let avgBlue = averageColor[2]
        let diff = Int(pixel.blue) - Int(avgBlue)
        if (diff > 0) {
            pixel.blue = hex_range( Double(avgBlue) + Double(diff) * factor )
        }
    }
}

public class AlphaFilter: RGBAFilter {
    // factor: 0-1
    override func pixel_filter( inout pixel: Pixel )-> Void {
        pixel.alpha = hex_range( Double(pixel.alpha) * factor )
    }
}

public class InvertFilter: RGBAFilter {
    // without factor
    override func pixel_filter( inout pixel: Pixel )-> Void {
        pixel.red = hex_range( 255 - Double(pixel.red) )
        pixel.green = hex_range( 255 - Double(pixel.green) )
        pixel.blue = hex_range( 255 - Double(pixel.blue) )
    }
}

public class BlackAndWhiteFilter: RGBAFilter {
    // without factor
    override func pixel_filter( inout pixel: Pixel )-> Void {
        let ratio = ( Double(pixel.red) + Double(pixel.green) + Double(pixel.blue) ) / 3.0
        
        pixel.red = hex_range( ratio )
        pixel.green = pixel.red
        pixel.blue = pixel.red
    }
}

public class SepiaToneFilter: RGBAFilter {
    // without factor
    override func pixel_filter( inout pixel: Pixel )-> Void {
        
        let red = Double(pixel.red)
        let green = Double(pixel.green)
        let blue = Double(pixel.blue)
        let newRed = (red * 0.393) + (green * 0.769) + (blue * 0.189)
        let newGreen = (red * 0.349) + (green * 0.686) + (blue * 0.168)
        let newBlue = (red * 0.272) + (green * 0.534) + (blue * 0.131)
        pixel.red = hex_range(newRed)
        pixel.green = hex_range(newGreen)
        pixel.blue = hex_range(newBlue)

    }
}


public class GrayScaleFilter: RGBAFilter {
    // factor: 0 ~ 256？ 0 ～ 1 ？ 
    //without factor
    // Gray = R*0.299 + G*0.587 + B*0.114
    override func pixel_filter( inout pixel: Pixel )-> Void {
        let gray = ( Double(pixel.red)*0.299 + Double(pixel.green)*0.587 + Double(pixel.blue)*0.114 ) / 3.0
        
        pixel.red = hex_range( gray )
        pixel.green = pixel.red
        pixel.blue = pixel.red
    }
}


public class BrightnessFilter: RGBAFilter {
    // factor 0~100%
    override func pixel_filter( inout pixel: Pixel )-> Void {
        pixel.red = hex_range( Double(pixel.red) * factor / 100)
        pixel.green = hex_range( Double(pixel.green) * factor / 100)
        pixel.blue = hex_range( Double(pixel.blue) * factor / 100)
    }
    
}

public class ContrastFilter: RGBAFilter {
    // factor > 0 increase
    // factor < 0 decrease
    override func pixel_filter( inout pixel: Pixel )-> Void {
        let avgRed = averageColor[0]
        var diff = Int(pixel.red) - Int(avgRed)
        if (diff > 0) {
            pixel.red = hex_range( Double(avgRed) + Double(diff) * factor )
        }

        let avgGreen = averageColor[1]
        diff = Int(pixel.green) - Int(avgGreen)
        if (diff > 0) {
            pixel.green = hex_range( Double(avgGreen) + Double(diff) * factor )
        }
        
        let avgBlue = averageColor[2]
        diff = Int(pixel.blue) - Int(avgBlue)
        if (diff > 0) {
            pixel.blue = hex_range( Double(avgBlue) + Double(diff) * factor )
        }
    }
}
