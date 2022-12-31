//
//  CARegistrationViewModel.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 12.10.2022.
//

import Foundation
import UIKit

protocol FormViewModel {
    func updateForm()
}

protocol AuthenticationViewModel {
    var formIsValid: Bool { get }
    var buttonBackgroundColor: UIColor {get}
}

struct CARegistrationViewModel: AuthenticationProtocol {

    
    var email: String?
    var fullName: String?
    var userName: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
            && fullName?.isEmpty == false
            && userName?.isEmpty == false
            && password?.isEmpty == false
    }
    
    
}

struct ResetPasswordViewModel: AuthenticationViewModel {
    var email: String?
    
    var formIsValid: Bool {return email?.isEmpty == false}
    
    var buttonBackgroundColor: UIColor {
         formIsValid ? .cyan : .cyan.withAlphaComponent(0.5)
    }
    
}
