//
//  CARegistrationViewModel.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 12.10.2022.
//

import Foundation

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
