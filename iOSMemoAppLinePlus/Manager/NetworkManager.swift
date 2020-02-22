//
//  NetworkManager.swift
//  iOSMemoAppLinePlus
//
//  Created by SEONGJUN on 2020/02/18.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    let cache = NSCache<NSString, UIImage>()
    
    func downloadImage(from urlString: String, completed: @escaping (Result<UIImage, ImageLoadError>) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(.success(image))
            return
        }
        guard let url = URL(string: urlString) else {
            completed(.failure(.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard error == nil else { completed(.failure(.unableToComplete)); return }
            
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completed(.failure(.invaildData))
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            
            completed(.success(image))
        }
        
        task.resume()
    }
}
