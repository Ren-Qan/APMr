//
//  IColors.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/2.
//

import Foundation

protocol IColorsBoxProtocol {
    associatedtype Maker: IColorsMakerProtocol
    static var box: IColorBox<Maker> { get }
}

protocol IColorsMakerProtocol {
    associatedtype Color
    static func color(_ name: String) -> Color
}

struct IColorBox<M: IColorsMakerProtocol> {
    let A1 = M.color("Accent1")
    
    let BG1 = M.color("Background1")
    
    let BG2 = M.color("Background2")
    
    let BG3 = M.color("Background3")
    
    let SBG1 = M.color("SubBackground1")
    
    let B1 = M.color("Border1")
    
    let H1 = M.color("Headline1")
    
    let H2 = M.color("Headline2")
    
    let C1 = M.color("Content1")
    
    let CS1 = M.color("ContentSeparator1")
    
    let S1 = M.color("Separator1")
    
    let S2 = M.color("Separator2")
    
    let SEL1 = M.color("Selected1")
    
    let SEL2 = M.color("Selected2")
    
    let BLUE1 = M.color("BLUE1")
    
    let BLUE2 = M.color("BLUE2")
    
    let BLUE3 = M.color("BLUE3")
    
    let GREEN1 = M.color("GREEN1")
    
    let ORANGE1 = M.color("ORANGE1")
    
    let PURPLE1 = M.color("PURPLE1")
}
