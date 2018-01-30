//
//  SCColor.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/26/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import UIKit

class SCColor {
    
    var colors = [[CGColor]]()
    var vintageColors = [UIColor]()
    var psychedelicIceCreamShopColors = [UIColor]()
    var currentColors: Int = 0
    var gradientLayer = CAGradientLayer()
    
    
    
    init(colors: [[CGColor]]){
        self.colors = colors
        
    }
    
    // Color index
    
    class func findColorIndex(indexPath: IndexPath, colors: [UIColor])-> Int{
        
        var colorIdx: Int
        if indexPath.row > colors.count-1 {
            colorIdx = indexPath.row-colors.count
            if colorIdx > colors.count-1 {
                colorIdx -= colors.count
            }
        } else {
            colorIdx = indexPath.row
        }
        return colorIdx
    }

    //MARK: Gradient color
    
    
    func configureGradientLayer(in view: UIView, from startPoint: CGPoint, to endPoint: CGPoint) {
        
        gradientLayer.frame = view.frame
        gradientLayer.colors = colors
//        gradientLayer.locations = [0.0, 0.35]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
//        view.layer.addSublayer(gradientLayer)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
    func morphColors(in view: UIView, fillMode: String) {

//        if currentColors < colors.count - 1 {
//            currentColors+=1
//        } else {
//            currentColors = 0
//        }
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.duration = 0.3
        colorChangeAnimation.fromValue = colors[0]
        colorChangeAnimation.toValue = colors[1]
        colorChangeAnimation.fillMode = fillMode
        colorChangeAnimation.autoreverses = true
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
    }

    
    //MARK: Custom colors
    
    struct Custom {
        
        struct Gray {
            static let dark = UIColor.init(red: 49.0/255.0, green: 36.0/255.0, blue: 32.0/255.0, alpha: 0.4)
        }
        struct PsychedelicIceCreamShoppe {
            static let medViolet = UIColor.init(red: 180.0/255.0, green: 172.0/255.0, blue: 216.0/255.0, alpha: 1.0)
            static let lightViolet = UIColor.init(red: 213.0/255.0, green: 201.0/255.0, blue: 223.0/255.0, alpha: 1.0)
            static let lightRose = UIColor.init(red: 235.0/255.0, green: 209.0/255.0, blue: 215.0/255.0, alpha: 1.0)
            static let rose = UIColor.init(red: 242.0/255.0, green: 184.0/255.0, blue: 189.0/255.0, alpha: 1.0)
            static let lightCoral = UIColor.init(red: 248.0/255.0, green: 146.0/255.0, blue: 134.0/255.0, alpha: 1.0)
            static let medRose = UIColor.init(red: 255.0/255.0, green: 124.0/255.0, blue: 134.0/255.0, alpha: 1.0)
            static let darkRose = UIColor.init(red: 219.0/255.0, green: 107.0/255.0, blue: 96.0/255.0, alpha: 1.0)
            static let brightCoral = UIColor.init(red: 255.0/255.0, green: 89.0/255.0, blue: 97.0/255.0, alpha: 1.0)
            static let ice = UIColor.init(red: 216.0/255.0, green: 225.0/255.0, blue: 234.0/255.0, alpha: 1.0)
            static let darkViolet = UIColor.init(red: 156.0/255.0, green: 90.0/255.0, blue: 205.0/255.0, alpha: 1.0)
            static let lightestBlueSky = UIColor.init(red: 154.0/255.0, green: 216.0/255.0, blue: 234.0/255.0, alpha: 1.0)
            static let lighterBlueSky = UIColor.init(red: 110.0/255.0, green: 200.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            static let lightBlueSky = UIColor.init(red: 0/255.0, green: 175.0/255.0, blue: 224.0/255.0, alpha: 1.0)
            static let deepBlue = UIColor.init(red: 0/255.0, green: 134.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            static let deepBlueShade = UIColor.init(red: 35.0/255.0, green: 115.0/255.0, blue: 195.0/255.0, alpha: 1.0)
            static let deepBlueDark = UIColor.init(red: 0/255.0, green: 103.0/255.0, blue: 188.0/255.0, alpha: 1.0)
            static let lighterBlue = UIColor.init(red: 0/255.0, green: 103.0/255.0, blue: 188.0/255.0, alpha: 1.0)
            static let neonAqua = UIColor.init(red: 0/255.0, green: 205.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        }
        struct VintageSeaStyle {
            static let brightVintageRed = UIColor.init(red: 220.0/255.0, green: 46.0/255.0, blue: 42.0/255.0, alpha: 1.0)
            static let lightVintageRed =  UIColor.init(red: 231.0/255.0, green: 93.0/255.0, blue: 47.0/255.0, alpha: 1.0)
            static let cream = UIColor.init(red: 248.0/255.0, green: 222.0/255.0, blue: 177.0/255.0, alpha: 1.0)
            static let lightAlgae = UIColor.init(red: 163.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0)
            static let darkAlgae = UIColor.init(red: 3.0/255.0, green: 123.0/255.0, blue: 98.0/255.0, alpha: 1.0)
            static let medAlgae = UIColor.init(red: 10.0/255.0, green: 144.0/255.0, blue: 117.0/255.0, alpha: 1.0)
            static let darkAqua = UIColor.init(red: 4.0/255.0, green: 108.0/255.0, blue: 113.0/255.0, alpha: 1.0)
            static let vintageBlue = UIColor.init(red: 26.0/255.0, green: 123.0/255.0, blue: 146.0/255.0, alpha: 1.0)
            static let mint = UIColor.init(red: 174.0/255.0, green: 200.0/255.0, blue: 162.0/255.0, alpha: 1.0)
            static let lightCreamsicle = UIColor.init(red: 255.0/255.0, green: 186.0/255.0, blue: 91.0/255.0, alpha: 1.0)
            static let darkCreamsicle = UIColor.init(red: 252.0/255.0, green: 126.0/255.0, blue: 31.0/255.0, alpha: 1.0)
            static let darkNavyBlue = UIColor.init(red: 44.0/255.0, green: 76.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            static let emeraldGreen = UIColor.init(red: 56.0/255.0, green: 168.0/255.0, blue: 126.0/255.0, alpha: 1.0)
            static let lemon = UIColor.init(red: 234.0/255.0, green: 221.0/255.0, blue: 54.0/255.0, alpha: 1.0)
            static let limestone = UIColor.init(red: 174.0/255.0, green: 196.0/255.0, blue: 191.0/255.0, alpha: 1.0)
            static let lime = UIColor.init(red: 183.0/255.0, green: 181.0/255.0, blue: 61.0/255.0, alpha: 1.0)
            static let darkGreen = UIColor.init(red: 85.0/255.0, green: 110.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        }
    }
    
    
    
    class func getVintageColors()-> [UIColor]{
        //vintage colors set
        let brightVintageRed = UIColor.init(red: 220.0/255.0, green: 46.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        let lightVintageRed =  UIColor.init(red: 231.0/255.0, green: 93.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        let cream = UIColor.init(red: 248.0/255.0, green: 222.0/255.0, blue: 177.0/255.0, alpha: 1.0)
        let lightAlgae = UIColor.init(red: 163.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0)
        let darkAlgae = UIColor.init(red: 3.0/255.0, green: 123.0/255.0, blue: 98.0/255.0, alpha: 1.0)
        let medAlgae = UIColor.init(red: 10.0/255.0, green: 144.0/255.0, blue: 117.0/255.0, alpha: 1.0)
        let darkAqua = UIColor.init(red: 4.0/255.0, green: 108.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        let vintageBlue = UIColor.init(red: 26.0/255.0, green: 123.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        let mint = UIColor.init(red: 174.0/255.0, green: 200.0/255.0, blue: 162.0/255.0, alpha: 1.0)
        let lightCreamsicle = UIColor.init(red: 255.0/255.0, green: 186.0/255.0, blue: 91.0/255.0, alpha: 1.0)
        let darkCreamsicle = UIColor.init(red: 252.0/255.0, green: 126.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        let darkNavyBlue = UIColor.init(red: 44.0/255.0, green: 76.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        let emeraldGreen = UIColor.init(red: 56.0/255.0, green: 168.0/255.0, blue: 126.0/255.0, alpha: 1.0)
        let lemon = UIColor.init(red: 234.0/255.0, green: 221.0/255.0, blue: 54.0/255.0, alpha: 1.0)
        let limestone = UIColor.init(red: 174.0/255.0, green: 196.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        let lime = UIColor.init(red: 183.0/255.0, green: 181.0/255.0, blue: 61.0/255.0, alpha: 1.0)
        let darkGreen = UIColor.init(red: 85.0/255.0, green: 110.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        let ice = UIColor.init(red: 216.0/255.0, green: 225.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        
        
        let vintUIColors = [brightVintageRed, lightVintageRed, cream, lightCreamsicle, darkCreamsicle, lightAlgae, medAlgae, darkAlgae, darkAqua,  mint, darkNavyBlue, emeraldGreen, lemon, limestone, lime, darkGreen, vintageBlue, ice]
        return vintUIColors
    }
    
    
    class func getPsychedelicIceCreamShopColors()-> [UIColor] {
        
        
        // psychedelic ice cream shop
        let medViolet = UIColor.init(red: 180.0/255.0, green: 172.0/255.0, blue: 216.0/255.0, alpha: 1.0)
        let lightViolet = UIColor.init(red: 213.0/255.0, green: 201.0/255.0, blue: 223.0/255.0, alpha: 1.0)
        let lightRose = UIColor.init(red: 235.0/255.0, green: 209.0/255.0, blue: 215.0/255.0, alpha: 1.0)
        let rose = UIColor.init(red: 242.0/255.0, green: 184.0/255.0, blue: 189.0/255.0, alpha: 1.0)
        let lightCoral = UIColor.init(red: 248.0/255.0, green: 146.0/255.0, blue: 134.0/255.0, alpha: 1.0)
        let medRose = UIColor.init(red: 255.0/255.0, green: 124.0/255.0, blue: 134.0/255.0, alpha: 1.0)
        let darkRose = UIColor.init(red: 219.0/255.0, green: 107.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        let brightCoral = UIColor.init(red: 255.0/255.0, green: 89.0/255.0, blue: 97.0/255.0, alpha: 1.0)
        let darkViolet = UIColor.init(red: 156.0/255.0, green: 90.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        let lightestBlueSky = UIColor.init(red: 154.0/255.0, green: 216.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        let lighterBlueSky = UIColor.init(red: 110.0/255.0, green: 200.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        let lightBlueSky = UIColor.init(red: 0/255.0, green: 175.0/255.0, blue: 224.0/255.0, alpha: 1.0)
        let deepBlue = UIColor.init(red: 0/255.0, green: 134.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        let deepBlueShade = UIColor.init(red: 35.0/255.0, green: 115.0/255.0, blue: 195.0/255.0, alpha: 1.0)
        let deepBlueDark = UIColor.init(red: 0/255.0, green: 103.0/255.0, blue: 188.0/255.0, alpha: 1.0)
        let lighterBlue = UIColor.init(red: 0/255.0, green: 103.0/255.0, blue: 188.0/255.0, alpha: 1.0)
        let neonAqua = UIColor.init(red: 0/255.0, green: 205.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        
        
        let psyUIColors = [neonAqua, lightCoral, lightViolet, deepBlue, darkViolet, lightestBlueSky, brightCoral, medViolet, medViolet, deepBlueDark, medRose, medViolet, darkRose, medRose, deepBlueShade, lighterBlueSky, medViolet, lighterBlue, lightBlueSky, lightRose, rose ]
        
        return psyUIColors
    }
    
    
    //MARK: Color index helper method

    class func FindColorIndex(indexPath: IndexPath, colors: [UIColor])-> Int{
        
        var colorIdx: Int
        if indexPath.row > colors.count-1 {
            colorIdx = indexPath.row-colors.count
            if colorIdx > colors.count-1 {
                colorIdx -= colors.count
            }
        } else {
            colorIdx = indexPath.row
        }
        return colorIdx
    }
    
    
    class func BrighterColor(color: UIColor) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        let success: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if !success {
            // handle error
        }
        // ... adjust components..
        print("hue - \(hue), sat - \(saturation), bri - \(brightness), a - \(alpha)")
        let newColor = UIColor.init(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
        return newColor
    }
    
    
    class func HigherSaturation(color: UIColor) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        let success: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if !success {
            // handle error
        }
        // ... adjust components..
        print("hue - \(hue), sat - \(saturation), bri - \(brightness), a - \(alpha)")
        let newColor = UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        return newColor
    }
    
    
    class func BrighterHigherSatColor(color: UIColor) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        let success: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if !success {
            // handle error
        }
        // ... adjust components..
//        print("hue - \(hue), sat - \(saturation), bri - \(brightness), a - \(alpha)")
        let newColor = UIColor.init(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        return newColor
    }

}
