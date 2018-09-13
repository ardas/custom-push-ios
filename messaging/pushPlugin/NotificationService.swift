//
//  NotificationService.swift
//  pushPlugin
//
//  Created by ____ on 12.09.18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import UserNotifications
import Alamofire

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    let url_status = "https://esputnik.com/api/v1/interactions/72B0DAEB-8FF6-421B-9A14-6A6B720277C4/status"
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
            putStatusRequest(urlWithName(url_status), completionHandler: { (error) in
                if error == nil {
                    bestAttemptContent.title = "\(bestAttemptContent.title) [OK send]"
                } else {
                    bestAttemptContent.title = "\(bestAttemptContent.title) [ERROR send]"
                }
                contentHandler(bestAttemptContent)
            })
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func urlWithName(_ absolutePath: String) -> URL {
        return URL(string: absolutePath)!
    }
    
    func putStatusRequest(_ urlString: URL, completionHandler: @escaping (NSError?) -> ()) {

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        let now = df.string(from: Date())
        
        let parameters: [String: Any] = [
            "token" : "eXiOMXw72qQ:APA91bG1QZfGh6pkey4nidsy_lueznYJqgSgDPibtTVQK7ku52FhyaEKrsljakcGG8amc_peYsguOIHV9zgIGIN8rBL08Nro8q4YyBcYp1TVyLHdzbglchdNPoNEtOS6dVKzWWTMdNwL",
            "status" : "DELIVERED",
            "time" : now
        ]

        Alamofire.request(urlString, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                //if let value = response.result.value {
                completionHandler(nil)
            //}
            case .failure(let error):
                completionHandler(error as NSError?)
            }
        }
    }

}
