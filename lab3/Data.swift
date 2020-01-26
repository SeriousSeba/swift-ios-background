//
//  Data.swift
//  lab3
//
//  Created by arek on 20/01/2020.
//  Copyright © 2020 aolesek. All rights reserved.
//

import Foundation

struct Urls {
    
    static let urls = ["https://dabrowski37lo.edu.pl/wp-content/uploads/2018/12/2018-2019_klasowe_1b.jpg"
        ,"https://upload.wikimedia.org/wikipedia/commons/c/c8/Valmy_Battle_painting.jpg"
        ,"https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/New_LA_Infobox_Pic_Montage_5.jpg/800px-New_LA_Infobox_Pic_Montage_5.jpg"
        ,"https://upload.wikimedia.org/wikipedia/commons/0/06/Master_of_Flémalle_-_Portrait_of_a_Fat_Man_-_Google_Art_Project_(331318).jpg"
        ,"https://upload.wikimedia.org/wikipedia/commons/c/ce/Petrus_Christus_-_Portrait_of_a_Young_Woman_-_Google_Art_Project.jpg"
        ,"https://upload.wikimedia.org/wikipedia/commons/3/36/Quentin_Matsys_-_A_Grotesque_old_woman.jpg"
    ]
    
    static func getUrls() -> [URL] {
        return urls.compactMap { (url) -> URL? in
            return (self.computeURL(urlString: url))
        }
    }
    
    static func computeURL(urlString: String) -> URL? {
        let components = transformURLString(urlString)
        
        if let url = components?.url {
            return url;
        } else {
            print("Invalid url " + urlString)
            return nil
        }
    }
    
    static func transformURLString(_ string: String) -> URLComponents? {
        guard let urlPath = string.components(separatedBy: "?").first else {
            return nil
        }
        var components = URLComponents(string: urlPath)
        if let queryString = string.components(separatedBy: "?").last {
            components?.queryItems = []
            let queryItems = queryString.components(separatedBy: "&")
            for queryItem in queryItems {
                guard let itemName = queryItem.components(separatedBy: "=").first,
                    let itemValue = queryItem.components(separatedBy: "=").last else {
                        continue
                }
                components?.queryItems?.append(URLQueryItem(name: itemName, value: itemValue))
            }
        }
        return components
    }
}
