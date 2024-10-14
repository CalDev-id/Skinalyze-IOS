//
//  ResultModel.swift
//  Skinalyze
//
//  Created by Ali Haidar on 10/14/24.
//

import Foundation
import SwiftData

@Model
class Result {
    var id: UUID = UUID()
    var timestamp: Date = Date.now
    var image1: String?
    var image2: String?
    var image3: String?
    var selectedCardIndex: Int
    var analyzedImages1: String?
    var analyzedImages2: String?
    var analyzedImages3: String?
    var isLoading: Bool
    var acneCounts: [String: Int]
    var geaScale: Int
    var currentDate: Date
    
    init(images: [String], selectedCardIndex: Int, analyzedImages: [String], isLoading: Bool, acneCounts: [String: Int], geaScale: Int, currentDate: Date) {
            self.selectedCardIndex = selectedCardIndex
            self.isLoading = isLoading
            self.acneCounts = acneCounts
            self.geaScale = geaScale
            self.currentDate = currentDate
            
            // Assign images
            if images.count > 0 { image1 = images[0] }
            if images.count > 1 { image2 = images[1] }
            if images.count > 2 { image3 = images[2] }
            
            // Assign analyzed images
            if analyzedImages.count > 0 { analyzedImages1 = analyzedImages[0] }
            if analyzedImages.count > 1 { analyzedImages2 = analyzedImages[1] }
            if analyzedImages.count > 2 { analyzedImages3 = analyzedImages[2] }
        }
}
