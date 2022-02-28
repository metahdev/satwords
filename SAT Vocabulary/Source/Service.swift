//
//  Service.swift
//  SAT Vocabulary
//
//  Created by Askar Almukhamet on 27.02.2022.
//

import Foundation
import SwiftyJSON

protocol ServiceDelegate: AnyObject {
    func definitionAndSentenceLoaded(definition: String, example: String)
    func linkLoaded(link: String)
}

#warning("some refactoring here if the project is continued")
struct Service {
    static var delegate: ServiceDelegate!
    
    static func getDefinitionAndSentence(of word: String) {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/" + word) else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                let data = data, error == nil
            else { return }
            let json = try? JSON(data: data)
            let definition = json?[0]["meanings"][0]["definitions"][0]["definition"].string ?? ""
            let sentence = json?[0]["meanings"][0]["definitions"][1]["example"].string ?? ""
            delegate.definitionAndSentenceLoaded(definition: definition, example: sentence)
        }.resume()
    }
    
    static func getImageURLString(of name: String) {
        let headers = [
            "x-rapidapi-host": "bing-image-search1.p.rapidapi.com",
            "x-rapidapi-key": "6e8c93b65bmshe18c589743b173fp1a1a40jsn1094a7bb1ee6"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://bing-image-search1.p.rapidapi.com/images/search?q=" + name.replacingOccurrences(of: " ", with: ""))! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                let data = data, error == nil
            else { return }
            let json = try? JSON(data: data)
            delegate.linkLoaded(link: json?["value"][0]["thumbnailUrl"].string ?? "")
        }.resume()
    }
}






