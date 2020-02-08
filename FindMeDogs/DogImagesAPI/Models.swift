//
//  ApiModels.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation

protocol Constructible {
	init()
}

enum StatusMessage: String, Codable {
	case success = "success"
	case error = "error"
	case unknown = "unknown"
}

struct DogBreedsList: Codable, Constructible {
	let message: [String]
	let status: StatusMessage
	
	init() {
		self.message = []
		self.status = .unknown
	}
}

struct DogBreedImages: Codable, Constructible {
	let message: [String]
	let status: StatusMessage
	init() {
		self.message = []
		self.status = .unknown
	}
}
