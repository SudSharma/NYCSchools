//
//  SchoolDetailsCell.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import UIKit

class SchoolDetailsCell: UITableViewCell {
    struct Model {
        var criticalReadingAverageScore: String?
        var mathAverageScore: String?
        var writingAverageScore: String?
    }
    
    var model: Model? {
        didSet {
            applyModel()
        }
    }
    
    @IBOutlet var criticalReadingAverageScore: UILabel!
    @IBOutlet var mathAverageScore: UILabel!
    @IBOutlet var writingAverageScore: UILabel!
}

private extension SchoolDetailsCell {
    func applyModel() {
        criticalReadingAverageScore?.text = model?.criticalReadingAverageScore
        mathAverageScore?.text = model?.mathAverageScore
        writingAverageScore?.text = model?.writingAverageScore
    }
}
