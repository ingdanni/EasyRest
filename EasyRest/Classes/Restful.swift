//
//  Restful.swift
//  Upboard
//
//  Created by Danny Narvaez on 1/25/18.
//  Copyright © 2018 ingdanni. All rights reserved.
//

import Foundation

/// A tuple containg HTTP request response and error string
public typealias APIError = (code: Int, message: String)

/// Restful protocol with HTTP default methods
public protocol Restful {
    
    func get(completion: @escaping (Data?, APIError?) -> Void)
    func get<D: Decodable>(as type: D.Type, completion: @escaping (D?, APIError?)-> Void)
    func get<T>(_ id: T, completion: @escaping (Data?, APIError?) -> Void)
    func get<T, D: Decodable>(_ id: T, as type: D.Type, completion: @escaping (D?, APIError?)-> Void)
    
    func post<E: Codable>(_ body: E, completion: @escaping (Data?, APIError?) -> Void)
    func post<E: Codable, D: Decodable>(_ body: E, as type: D.Type, completion: @escaping (D?, APIError?)-> Void)
    
    func put<T, E: Codable>(_ id: T, body: E, completion: @escaping (Data?, APIError?) -> Void)
    func put<T, E: Codable, D: Decodable>(_ id: T, body: E, as type: D.Type, completion: @escaping (D?, APIError?)-> Void)
    
    func delete<T>(_ id: T,completion: @escaping (Data?, APIError?) -> Void)
    func delete<T, D: Decodable>(_ id: T, as type: D.Type, completion: @escaping (D?, APIError?)-> Void)
    
}

extension Encodable {
    
    /// Transforms Encodable object to a dictionary
    var dictionary: [String: AnyObject]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: AnyObject] }
    }
}
