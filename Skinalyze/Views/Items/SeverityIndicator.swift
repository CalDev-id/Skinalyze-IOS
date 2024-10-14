//
//  SeverityIndicator.swift
//  Skinalyze
//
//  Created by Ali Haidar on 10/11/24.
//

import SwiftUI

struct SeverityIndicator: View {
    var acneLevelScale: Int
    var severityLevel: String
    //    var skinLevelScale: Int = 3
    //    var skinLevel: String = "Mild"
    
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width - 40
    }
    
    private var indicatorPosition: CGFloat{
        let segmentWidth = screenWidth / 3
        return segmentWidth * CGFloat(acneLevelScale)
    }
    
    private var textOffset: CGFloat {
        switch acneLevelScale {
        case 0:
            return (indicatorPosition - screenWidth / 2) + 23
        case 3:
            return (indicatorPosition - screenWidth / 2) - 23
        default:
            return (indicatorPosition - screenWidth / 2)
        }
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .center)){
            Rectangle()
                .foregroundColor(.clear)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.34, green: 0.5, blue: 0.69), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.64, green: 0, blue: 0.07), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0, y: 0.5),
                        endPoint: UnitPoint(x: 1, y: 0.5)
                    )
                )
                .cornerRadius(10)
                .frame(width: screenWidth, height: 13)
            //                .padding(10)
            Capsule()
                .fill(.white)
                .frame(width: 4, height: 10)
                .offset(x: (indicatorPosition - screenWidth / 2) - 5)
            Text(severityLevel)
                .font(Font.custom("Quattrocento Sans", size: 14))
                .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.27))
                .padding(.top, 35)
                .offset(x: textOffset)
        }
    }
}

struct SkinLevelIndicator_Previews: PreviewProvider {
    static var previewSkinLevelScale: Int = 0
    static var previewSkinLevel: String = "Healthy"
    
    static var previews: some View {
        SeverityIndicator(acneLevelScale: previewSkinLevelScale, severityLevel: previewSkinLevel)
    }
}
