//
//  AuthService.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 18.10.2022.
//

import Firebase
import UIKit
import Firebase
import FirebaseFirestore

struct RegistrationCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
    let fcmToken: String
}

struct AuthService {
    static let shared = AuthService()
   
    
    func createUser(credentials: RegistrationCredentials, completion: ((Error?) -> Void)?) {
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        // fotograf icin uniq id
        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion!(error)
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                // Kullanıcı olustur
                Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                    if let error = error {
                        completion!(error)
                        return
                    }
                    
                    //  user id
                    guard let uid = result?.user.uid else { return }
                    
                    let data = ["email": credentials.email,
                                "fullname": credentials.fullname,
                                "profileImageUrl": profileImageUrl,
                                "uid": uid,
                                "username": credentials.username,
                                "fcmToken": credentials.fcmToken] as [String: Any]
                    
                    Firestore.firestore().collection("users").document(uid).setData(data, completion: completion)
                }
            }
        }
    }
    
    func updateProfileImage(image: UIImage, completion: @escaping(URL?) -> Void) {
           guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
           guard let uid = Auth.auth().currentUser?.uid else { return }
           let filename = NSUUID().uuidString
           let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        print("Kullanıcı\(uid)")
           
           ref.putData(imageData, metadata: nil) { (meta, error) in
               ref.downloadURL { (url, error) in
                   guard let profileImageUrl = url?.absoluteString else { return }
                   let values = ["profileImageUrl": profileImageUrl]
                   
                   COLLECTION_USERS.document(uid).updateData(values) { err in
                       completion(url)
                   }
               }
           }
       }
}
