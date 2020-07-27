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
        let cacheKey = NSString(string: urlString) // NSCache의 키 타입은 AnyObject 타입으로만 사용하도록 되어있어서 Class 타입으로 들어가야 한다. 일반 String은 구조체라서 사용이 불가능하다. 그래서 클래스인 NSString 으로 사용

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
