//
//  ImageService.swift
//  Able
//
//  Created by Ziyi Liew on 5/11/20.
//

import Foundation
import UIKit

class ImageService {
    static func downloadImage(withURL url: URL, completion: @escaping (_ image:UIImage?)->()) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            var downloadedImage:UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
            
        }
        dataTask.resume()
    }
}
