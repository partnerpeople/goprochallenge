import UIKit
@IBDesignable
class DesignableView: UIView {
    
    @IBInspectable var Color1:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var Color2:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override public class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors    = [Color1.cgColor, Color2.cgColor]
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
//@IBDesignable class DesignableView: UIView
//{
//    @IBInspectable var Color1: UIColor = UIColor.white {
//        didSet{
//            self.setGradient()
//        }
//    }
//    @IBInspectable var Color2: UIColor = UIColor.white {
//        didSet{
//            self.setGradient()
//        }
//    }
//    @IBInspectable var StartPoint: CGPoint = .zero {
//        didSet{
//            self.setGradient()
//        }
//    }
//    @IBInspectable var EndPoint: CGPoint = CGPoint(x: 0, y: 1) {
//        didSet{
//            self.setGradient()
//        }
//    }
//    private func setGradient()
//    {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [self.Color1.cgColor, self.Color2.cgColor]
//        gradientLayer.startPoint = self.StartPoint
//        gradientLayer.endPoint = self.EndPoint
//        gradientLayer.frame = self.bounds
//        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
//        {
//            topLayer.removeFromSuperlayer()
//        }
//
//        self.layer.insertSublayer(gradientLayer, at: 0)
//
//    }
//}
