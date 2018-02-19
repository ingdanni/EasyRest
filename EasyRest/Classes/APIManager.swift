//
//  APIManager.swift
//  DGCalendar
//
//  Created by Danny Narvaez on 2/19/18.
//  Copyright © 2018 dealergeek. All rights reserved.
//

import Foundation

public class APIManager {
    
    public var baseUrl: String?
    
    public var httpAdditionalHeaders: [String: Any]?
    
    public var timeOutInterval: TimeInterval = 10
    
    public static let shared = APIManager()
    
    public init() {}
}
