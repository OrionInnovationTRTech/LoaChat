//
//  CAPushNotificationSender.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 12.11.2022.
//

import UIKit
class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        
        print("")
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAof0HEmc:APA91bECuKKg5i8UfgBD7wYjceK9mDKHzwzJaVq2ppoD_wqdYc5zHFtv5__rOeuWA6eVJ1vAK3Ro4dmwC4M4Q3Lgpf80ZOG5sqcDZjcnoThv_0BcW4MAv8s9bUFWghDNg39eStzZU5Op", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        print("Bir şey var: \(jsonDataDict)")
                    }
                }
            } catch let err as NSError {
                print("Hey: \(err.localizedDescription)")
            }
        }
        task.resume()
    }
}
