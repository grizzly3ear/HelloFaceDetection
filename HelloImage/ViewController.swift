import UIKit
import CoreImage

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var colorView1: UIView!
    @IBOutlet weak var colorView2: UIView!
    
    let faceDetector = FaceLandmarksDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorView1.backgroundColor = .black
        colorView2.backgroundColor = .black
        
        image.isUserInteractionEnabled = true
        setupTapGesture()
        setupDragGesture()
//        setupPinchGesture()
        
        detect(image.image!)
    }
    
    @objc func onPinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
            print("\(sender.scale)")
        }
    }
    
    @objc func onDrag(_ sender: UIPanGestureRecognizer) {
        let touchPoint2 = sender.location(in: image)
        let color2 = image.image?.getPixelColor(point: touchPoint2, sourceView: image)
        colorView2.backgroundColor = color2
        print("\(color2!) on \(touchPoint2)")
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        let touchPoint2 = sender.location(in: image)
        let color2 = image.image?.getPixelColor(point: touchPoint2, sourceView: image)
        colorView2.backgroundColor = color2
        print("\(color2!) on \(touchPoint2)")
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelect = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            image.image = imageSelect
            
            detect(imageSelect)
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func detect(_ selectedImage: UIImage) {
        let maxSize = CGSize(width: 1024, height: 1024)
        
        faceDetector.highlightFaces(for: (selectedImage.imageWithAspectFit(size: maxSize))!) { (resultImage) in
            
            self.image.image = resultImage
        }
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        image.addGestureRecognizer(tapGesture)
    }
    
    func setupDragGesture() {
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onDrag))
        dragGesture.minimumNumberOfTouches = 1
        image.addGestureRecognizer(dragGesture)
    }
    
    func setupPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.onPinch))
        pinchGesture.scale = 1
        image.addGestureRecognizer(pinchGesture)
    }

}
