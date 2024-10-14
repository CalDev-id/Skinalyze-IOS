//
//  AcneSeverityLevel.swift
//  Skinalyze
//
//  Created by Ali Haidar on 10/14/24.
//

enum AcneSeverityLevel: Int, CaseIterable {
    case mild = 1
    case moderate = 2
    case severe = 3
    case verySevere = 4
    case extremelySevere = 5

    var description: String {
        switch self {
        case .mild:
            return "Mild"
        case .moderate:
            return "Moderate"
        case .severe:
            return "Severe"
        case .verySevere:
            return "Very Severe"
        case .extremelySevere:
            return "Extremely Severe"
        }
    }
}
