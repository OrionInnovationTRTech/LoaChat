//
//  CALoginViewModel.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 12.10.2022.
//

import Foundation

protocol AuthenticationProtocol {
    var formIsValid: Bool { get }
}

struct CALoginViewModel: AuthenticationProtocol {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
            && password?.isEmpty == false
    }
}


