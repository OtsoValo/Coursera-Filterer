
// run filters in user_filters list
public class RGBAImageProcessor {
    
    public let image: RGBAImage
    private var averageColor: [UInt8] = [0,0,0] //red green blue
    
    var user_filters = [RGBAFilter]()
    
    
    //default filter formulas and parameters
    let predefinedFilterNames = ["50% Brightness", "2x Contrast", "50% GrayScale", "SepiaTone","Invert","50% Alpha","Red +5"]
    
    public func addPredefinedFilter(name: String) {
        switch name {
        case "50% Brightness":
            addFilter(BrightnessFilter(50))
        case "2x Contrast":
            addFilter(ContrastFilter(2))
        case "50% GrayScale":
            addFilter(GrayScaleFilter(0.5))
        case "SepiaTone":
            addFilter(SepiaToneFilter())
        case "Invert":
            addFilter(InvertFilter())
        case "50% Alpha":
            addFilter(AlphaFilter(255*0.5))
        case "Red +5":
            addFilter(RedFilter(5))
        default:
            print("Undefined filter formular: \(name)")
        }
    }

    public func applyPredefinedFilter(name: String) -> RGBAImage? {
        
        if (!predefinedFilterNames.contains(name)) {
            print("Undefined filter formular: \(name)")
            return nil
        }
        
        removeFilters()
        addPredefinedFilter(name)
        return applyFilters()
    }

    public init( _ image_in: RGBAImage ) {
        image = image_in
        getAverageColor()
    }
    
    private func getAverageColor() {
        
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = y * image.width + x
                let pixel = image.pixels[index]
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        
        let count = image.width * image.height
        averageColor[0] = UInt8(totalRed/count)
        averageColor[1] = UInt8(totalGreen/count)
        averageColor[2] = UInt8(totalBlue/count)
    
    }
    
    public func addFilter( filter: RGBAFilter )-> Void {
        user_filters.append( filter )
        filter.setAverageColor(averageColor[0], g: averageColor[1], b: averageColor[2])
    }
    
    public func removeFilters() {
        user_filters.removeAll()
    }
    
    public func initFilter( filter: RGBAFilter ) {
        removeFilters()
        addFilter(filter)
    }
    
    public func showFilters()-> String {

        var str = ""
        
        for filter in user_filters {
            str += filter.toString() + "\n"
        }
        
        return str
    }
    
    public func lastFilterName()-> String {
        
        guard user_filters.count > 0 else { return "" }
        
        return String(user_filters[user_filters.count-1].dynamicType)
    }
    
    public func applyFilters()-> RGBAImage {
        
        var new_image = image
        
        for filter in user_filters {
            filter.apply( &new_image )
        }
        
        return new_image
    }
    
}
