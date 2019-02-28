import UIKit
import Vision

class FaceLandmarksDetector {
    
    open func highlightFaces(for source: UIImage, complete: @escaping (UIImage) -> Void) {
        var resultImage = source
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            if error == nil {
                if let results = request.results as? [VNFaceObservation] {
                    for faceObservation in results {
                        guard let landmarks = faceObservation.landmarks else {
                            continue
                        }
                        let boundingRect = faceObservation.boundingBox
                        
                        resultImage = self.drawOnImage(source: resultImage, boundingRect: boundingRect, faceLandmarks: landmarks)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
            complete(resultImage)
        }
        
        let vnImage = VNImageRequestHandler(cgImage: source.cgImage!, options: [:])
        try? vnImage.perform([detectFaceRequest])
    }
    
    private func drawOnImage(source: UIImage, boundingRect: CGRect, faceLandmarks: VNFaceLandmarks2D) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0.0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rectWidth = source.size.width * boundingRect.size.width
        let rectHeight = source.size.height * boundingRect.size.height
        
        let rect = CGRect(x: 0, y:0, width: source.size.width, height: source.size.height)
        context.draw(source.cgImage!, in: rect)
        
        //draw bound rect
        context.setStrokeColor(UIColor.green.cgColor)
        context.addRect(CGRect(x: boundingRect.origin.x * source.size.width, y:boundingRect.origin.y * source.size.height, width: rectWidth, height: rectHeight))
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        context.setLineWidth(2.0)
        
        func drawFeature(_ feature: VNFaceLandmarkRegion2D, color: CGColor, close: Bool = false) {
            
//            for point in feature.normalizedPoints {
//                // Draw DEBUG numbers
//                let textFontAttributes = [
//                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
//                    NSAttributedString.Key.foregroundColor: UIColor.white
//                ]
//                context.saveGState()
//
//                context.translateBy(x: 0.0, y: source.size.height)
//                context.scaleBy(x: 1.0, y: -1.0)
//                let mp = CGPoint(x: boundingRect.origin.x * source.size.width + point.x * rectWidth,
//                                 y: source.size.height - (boundingRect.origin.y * source.size.height + point.y * rectHeight))
//                context.fillEllipse(in: CGRect(origin: CGPoint(x: mp.x-2.0, y: mp.y-2), size: CGSize(width: 4.0, height: 4.0)))
//                if let index = feature.normalizedPoints.index(of: point) {
//                    NSString(format: "%d", index).draw(at: mp, withAttributes: textFontAttributes)
//                }
//                context.restoreGState()
//            }
            
            let mappedPoints = feature.normalizedPoints.map { (point) -> CGPoint in
                return CGPoint(x: boundingRect.origin.x * source.size.width + point.x * rectWidth,
                               y: boundingRect.origin.y * source.size.height + point.y * rectHeight)
            }
            
            context.setStrokeColor(color)
            context.setFillColor(color)
            
            context.addLines(between: mappedPoints)
            if close, let first = mappedPoints.first, let lats = mappedPoints.last {
                context.addLines(between: [lats, first])
            }
            context.strokePath()
        }
        
        if let outerLips = faceLandmarks.outerLips {
            drawFeature(outerLips, color: UIColor.blue.cgColor, close: true)
        }
        if let innerLips = faceLandmarks.innerLips {
            drawFeature(innerLips, color: UIColor.yellow.cgColor, close: true)
        }
        
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return coloredImg
    }
}
