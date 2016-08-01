//
//  ViewController.swift
//  Filterer
//
//  Created by hyf on 16/7/13.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let buttonAnimateDuration = 0.8
    var sliderVisible = false // indicate slider is show or not
    
    var originalImage, filteredImage: UIImage!
    var myProcessor: RGBAImageProcessor!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet weak var bottomMenu: UIView!
    @IBOutlet var hSlider: UISlider!
    
    @IBOutlet weak var FilterButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var onNewPhoto: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    
    @IBOutlet weak var originalLabel: UILabel!
    
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    
        hSlider.translatesAutoresizingMaskIntoConstraints = false
        
        
        // add Tap gesture recognizer to ImageView
        let tapGestureRecognizer = UILongPressGestureRecognizer(target:self, action:#selector(ViewController.toggleImage(_:)))
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        //set temporary image view that is used for crossfade
        // tempImageView is at top of imageView
        tempImageView.backgroundColor = imageView.backgroundColor
        tempImageView.contentMode = imageView.contentMode
     
        
        //initialization views
        originalImage = imageView.image //UIImage(named: "scenery")!
        myProcessor = RGBAImageProcessor(RGBAImage(image: originalImage)!)
        compareButton.enabled = false
        editButton.enabled = false
        tempImageView.alpha = 0
        
    }
    
    // gesture action
    
    func toggleImage(sender: UILongPressGestureRecognizer) {
        // when the image is original image, does not toggle it
        if compareButton.enabled == false {
            return
        }
        
        if sender.state == .Began {
            imageView.image = originalImage
            originalLabel.hidden = false
        } else if sender.state == .Ended {
            imageView.image = filteredImage
            originalLabel.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // action: compare
    
    @IBAction func onCompare(sender: AnyObject) {
        corssfadeImage(imageView.image!, toImage: originalImage)
        editButton.enabled = false
        hideSlider()
        compareButton.enabled = false
        originalLabel.hidden = false
    }
    
    func corssfadeImage(fromImage: UIImage, toImage: UIImage) {
        tempImageView.image = fromImage
        imageView.image = toImage
        
        tempImageView.alpha = 1.0
        UIView.animateWithDuration(3) {
            self.tempImageView.alpha = 0
        }
    }
    
    // actoin: share
    
    @IBAction func onShare(sender: AnyObject) {
        
        let activityController = UIActivityViewController(activityItems: ["cool image",imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // action: new photo
    
    @IBAction func onNewPhoto(sender: UIButton) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in self.showCamera()}))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in self.showAlbum()}))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .Alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.Default,
            handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC,
                              animated: true,
                              completion: nil)
    }
    
    func showCamera() {
        // there is no camera in simulator
        /* a way to check camera
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) == nil {
            noCamera()
            return
        }*/
       
        if (UIImagePickerController.isSourceTypeAvailable(.Camera) == false) {
            noCamera()
            return
        }
        
        let cameraPicker = UIImagePickerController()
        
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
        
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
        
    }
    
    // UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        
        // a new image selected
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            //this is delegate, animation does no effort with it, so do it asynchronously
            //waits until the specified time and then asynchronously adds crossfadeImage to the specified queue.
            
            let shortDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(1*NSEC_PER_USEC))
            dispatch_after(shortDelay, dispatch_get_main_queue()) {
                self.corssfadeImage(self.imageView.image!, toImage: image)
            }
        
            editButton.enabled = false
            hideSlider()
            compareButton.enabled = false
            originalLabel.hidden = false
            
            // set original image
            originalImage = image
            myProcessor = RGBAImageProcessor(RGBAImage(image: originalImage)!)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //action: filter
    
    @IBAction func onFilter(sender: UIButton) {
        
        hideSlider()
        
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
        
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomContraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightContraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        NSLayoutConstraint.activateConstraints([bottomContraint,leftConstraint,rightConstraint,heightContraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(buttonAnimateDuration) {
            self.secondaryMenu.alpha = 1.0
        }
        
    }
    
    func hideSecondaryMenu() {
        
        UIView.animateWithDuration(buttonAnimateDuration, animations: {
            self.secondaryMenu.alpha = 0}) {
                completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
  
    }
    
    //action: edit
    
    @IBAction func onEdit(sender: UIButton) {
        
        FilterButton.selected = false
        
        if sliderVisible {
            hideSlider()
 
        } else {
            showSlider()

        }
    }
    
    func showSlider() {
        view.addSubview(hSlider)
        
        let bottomConstraint = hSlider.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = hSlider.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = hSlider.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = hSlider.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.hSlider.alpha = 0
        UIView.animateWithDuration(buttonAnimateDuration) {
            self.hSlider.alpha = 1.0
        }
        
        sliderVisible = true
        
        // init slider value
        hSlider.setValue(hSlider.maximumValue/2, animated: false)
        
        hideSecondaryMenu()
    }

    func hideSlider() {
        if sliderVisible == false {
            return
        }
        
        UIView.animateWithDuration(buttonAnimateDuration, animations: {
            self.hSlider.alpha = 0}) {
                completed in
                if completed == true {
                    self.hSlider.removeFromSuperview()
                }
        }
        
        sliderVisible = false
        
     }

    // action: slide value changed
    
    @IBAction func onSlideValueChanged(sender: AnyObject) {
        let filterName = myProcessor.lastFilterName()
        var value = hSlider.value
        
        switch filterName {
        case "RedFilter":
            if (value > hSlider.maximumValue / 2) {
                value = (value - hSlider.maximumValue / 2) * 20
            }
        case "GreenFilter":
            if (value > hSlider.maximumValue / 2) {
                value = (value - hSlider.maximumValue / 2) * 20
            }

        case "BlueFilter":
            if (value > hSlider.maximumValue / 2) {
                value = (value - hSlider.maximumValue / 2) * 20
            }
        case "BrightnessFilter":
            value = value * 100
        case "ContrastFilter":
            if (value > hSlider.maximumValue / 2) {
                value = (value - hSlider.maximumValue / 2) * 20
            }
        case "AlphaFilter": break
            
        case "GrayScaleFilter":
            value = value * 256
            
            
        default: return
            
        }
        
        // get the project name
        guard  let appName: String?
            = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String?
            else { return }
        
        // generate the full name of your class (take a look into your "YourProject-swift.h" file)
        let classStringName = appName! + "." + filterName
        // get the class!
        let objType =  NSClassFromString(classStringName) as? RGBAFilter.Type
        
        let obj = objType!.init(Double(value))

        myProcessor.initFilter(obj)
        imageView.image = myProcessor.applyFilters().toUIImage()
        
        filteredImage = imageView.image
    }
    
    
    //class name, button image, init value, can update
    
    let filters = [
        ["name": "RedFilter", "picture": "brush_red.png", "default": 2, "canupdate": true],
        ["name": "GreenFilter", "picture": "brush_green.png", "default": 2,  "canupdate": true],
        ["name": "BlueFilter", "picture": "brush_blue.png",  "default": 2, "canupdate": true],
        ["name": "BrightnessFilter", "picture": "brightness.png",  "default": 50, "canupdate": true],
        ["name": "ContrastFilter", "picture": "contrast.png",  "default": 2, "canupdate": true],
        ["name": "AlphaFilter", "picture": "alpha.png",  "default": 0.5, "canupdate": true],
        ["name": "GrayScaleFilter", "picture": "grayscale.png",  "default": 0, "canupdate": false],
        ["name": "BlackAndWhiteFilter", "picture": "blackandwhite.png",  "default": 0, "canupdate": false],
        ["name": "SepiaToneFilter", "picture": "sepiatone.png",  "default": 0, "canupdate": false],
        ["name": "InvertFilter", "picture": "invert.png",  "default": 0, "canupdate": false],

        ]
    

    
    // for UICollectionViewDelegate
    
    internal func buttonOnClick(index: Int) {
        let filterName = filters[index]["name"] as! String
        let filterDefault = filters[index]["default"] as! Double
        let filterCanupdate = filters[index]["canupdate"] as! Bool
        
        
        // get the project name
        guard  let appName: String?
            = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String?
            else { return }
        
        // generate the full name of your class (take a look into your "YourProject-swift.h" file)
        let classStringName = appName! + "." + filterName
        // get the class!
        let objType =  NSClassFromString(classStringName) as? RGBAFilter.Type
        
        let obj = objType!.init(filterDefault)
        
        myProcessor.initFilter(obj)
        imageView.image = myProcessor.applyFilters().toUIImage()
        
        editButton.enabled = filterCanupdate
        compareButton.enabled = true
        originalLabel.hidden = true
        filteredImage = imageView.image
        
    }
        
    /*
    func crossfade2image() {
        let toImage = self.originalImage//self.imageView.image//UIImage(named:"myname.png")
        UIView.transitionWithView(self.imageView,
                                  duration:5,
                                  options: UIViewAnimationOptions.TransitionCrossDissolve,
                                  animations: { self.imageView.image = toImage },
                                  completion: nil)
    }
 */
  
    /*
     func crossfade2image() {
     
     let image1:UIImage = UIImage(named: "sample")!;
     let image2:UIImage = UIImage(named: "scenery")!;
     let crossFade:CABasicAnimation = CABasicAnimation(keyPath: "contents");
     crossFade.duration = 5.0;
     crossFade.fromValue = image1.CGImage;
     crossFade.toValue = image2.CGImage;
     imageView.layer.addAnimation(crossFade, forKey:"animateContents");
     
     }
     */
    
}


// UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    // bing datasouce to viewcontroller, else it does not work

    // count
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count;
    }
    
    //cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            "DesignViewCell", forIndexPath: indexPath) as UICollectionViewCell
        
        (cell.contentView.subviews.first as! UIImageView).image =
            UIImage(named: filters[indexPath.item]["picture"]! as! String)
        
        
        //cell.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
}

// UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    //bing delegate to viewcontroller
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        buttonOnClick(indexPath.row)
    }
}


