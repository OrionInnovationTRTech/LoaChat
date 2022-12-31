//
//  Services.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 24.10.2022.
//

import Firebase

struct Service {
    
    static func fetchUsers(complition: @escaping([User]) -> Void ) {
        COLLECTION_USERS.getDocuments { snapshot, error in
            guard var users = snapshot?.documents.map({ User(dictionary: $0.data()) }) else { return }
            if let i = users.firstIndex(where: { $0.uid == Auth.auth().currentUser?.uid }) {
                users.remove(at: i)
            }
            complition(users)
        }
    }
    
    static func fetchUser(withUID uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { (snapshot, error) in
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchUserOnlineStatus(withUID uid: String, completion: @escaping(User) -> Void) {
        
        COLLECTION_USERS.document(uid)
            .addSnapshotListener { documentSnapshot, error in
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
              guard let data = document.data() else {
                print("Document data was empty.")
                return
              }
                print("Current data3: \(data)")
                let user = User(dictionary: data)
                completion(user)
            }
    }
    
    static func uploadMessage(_ message: String, to user: User, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let data = ["text": message,
                    "fromId":currentUid,
                    "toId":user.uid,
                    "timestamp":Timestamp(date: Date())] as [String : Any]
        
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) {_ in
            
        COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data, completion: completion)
            
        COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data)
           
        COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid).setData(data)
            
            }
    }
    
    static func fetchMessage(forUser user: User, complition: @escaping([Message]) -> Void) {
        var  messages = [Message]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp")
        query.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let dictionary = change.document.data()
                    messages.append(Message(dictionary: dictionary))
                    print("Dedeman")
                    complition(messages)
                }
            })
        }
    }
    
    static func fetchConversation(complition: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        conversations.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_MESSAGES.document(uid).collection("recent-messages").order(by:"timestamp")
        query.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ change in
                let dictionary = change.document.data()
                let message = Message(dictionary: dictionary)
                self.fetchUser(withUID: message.chatPartnerId) { user in
                    let conversation = Conversation(user: user, message: message)
                    conversations.append(conversation)
                    complition(conversations)
                }
            })
        }
    }
    
    static func sendImageMessage(_ image: UIImage, to user: User, completion: ((Error?) -> Void)?) {
        uploadToFirebaseStorageUsingImage(image: image) { imageUrl in
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            let data = ["imageUrl": imageUrl!,
                        "fromId":currentUid,
                        "toId":user.uid,
                        "timestamp":Timestamp(date: Date())] as [String : Any]
            COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) {_ in

                COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data, completion: completion)

                COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data)

                COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid).setData(data)
            }
        }
    }
    
    var image: String
    
    static func uploadToFirebaseStorageUsingImage(image: UIImage, completion: ((String?) -> Void)? ) {
        
        let fileName = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/Message_Images/\(fileName)")
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            
            ref.putData(uploadData, metadata: nil, completion:  { (metadata, error) in
                if error != nil {
                    print("fail to upload image,",error!)
                    return
                }
                ref.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    guard let profileImageUrl = url?.absoluteString else { return }
                    completion!(profileImageUrl)
                })
            } )
        }
    }
}
