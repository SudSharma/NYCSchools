//
//  SchoolCell.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import MessageUI
import UIKit

protocol SchoolCellActions: AnyObject {
    func email(_ address: String)
    func phone(_ number: String)
    func openWebsite(_ url: String)
}

class SchoolCell: UITableViewCell {

    struct Model {
        
        let name: String
        
        // Address fields
        var address: String?
        var city: String?
        var stateCode: String?
        var zip: String?
        
        // School Contacts
        var email: String?
        var phone: String?
        var website: String?
    }
    
    @IBOutlet var name: UILabel!
    
    // Address fields
    @IBOutlet var address: UILabel!
    @IBOutlet var city: UILabel!
    @IBOutlet var stateCode: UILabel!
    @IBOutlet var zip: UILabel!
    
    // School Contacts
    @IBOutlet var email: UIButton!
    @IBOutlet var phone: UIButton!
    @IBOutlet var website: UIButton!
    
    weak var delegate: SchoolCellActions?
    
    var model: Model? {
        didSet {
            applyModel()
        }
    }
    
    @IBAction func onEmailButtonTap(_ sender: UIButton) {
        guard let model = model, let email = model.email else { return }

        delegate?.email(email)
    }
    
    @IBAction func onPhoneButtonTap(_ sender: UIButton) {
        guard let model = model, let phone = model.phone else { return }

        delegate?.phone(phone)
    }
    
    @IBAction func onWebsiteButtonTap(_ sender: UIButton) {
        guard let model = model, let website = model.website else { return }

        delegate?.openWebsite(website)
    }
}

private extension SchoolCell {
    func applyModel() {
        name?.text = model?.name
        address?.text = model?.address
        city?.text = model?.city
        stateCode?.text = model?.stateCode
        zip?.text = model?.zip
        
        phone.tintColor = UIColor.systemBlue
        email.tintColor = UIColor.systemBlue
        website.tintColor = UIColor.systemBlue
        #if targetEnvironment(simulator)
        phone.tintColor = UIColor.lightGray
        #endif
        
        if MFMailComposeViewController.canSendMail() {
            email.tintColor = UIColor.lightGray
        }
    }
}
