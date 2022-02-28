//
//  Extensions.swift
//  SAT Vocabulary
//
//  Created by Askar Almukhamet on 27.02.2022.
//

import UIKit
import SwiftyJSON

extension UIImageView {
    func download(from link: String) {
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.contentMode = .scaleAspectFit
                self?.image = image
            }
        }.resume()
    }
}


