//
//  ApiModels.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation


// MARK: Core API Definitions
protocol Constructible {
	init()
}

enum StatusMessage: String, Codable {
	case success = "success"
	case error = "error"
	case unknown = "unknown"
}

struct DogAPI_BreedsListResponse: Codable, Constructible {
	let message: [String]
	let status: StatusMessage
	
	init() {
		self.message = []
		self.status = .unknown
	}
}

struct DogAPI_DogBreedImagesResponse: Codable, Constructible {
	let message: [String]
	let status: StatusMessage
	init() {
		self.message = []
		self.status = .unknown
	}
	
	var imageUrls: [URL] {
		return message.compactMap { 
			URL.init(string: $0) 
		}
	}
}

// MARK: DTOs, aliases, and helper extensions
typealias DogBreedImageTuple = (breedName: String, breedImage: URL?)

class DogBreedResolvedImages {
	// Adding some state to the model; since we've got no model hiearchy, 
	// just set a flag for whether or not this model should be interpreted as
	// an actual set of dog data, or just a list of breed names
	var includesResolvedURLs = false
	var breedNameToUrlTuples: [DogBreedImageTuple] = []
}

extension Array where Element == String {
	var asResolvedImages: DogBreedResolvedImages {
		let mapped = DogBreedResolvedImages.init()
		mapped.breedNameToUrlTuples = compactMap { ($0, nil) }
		return mapped
	}
}

extension DogAPI_BreedsListResponse {
	var asResolvedImages: DogBreedResolvedImages {
		let mapped = DogBreedResolvedImages.init()
		mapped.breedNameToUrlTuples = message.compactMap { ($0, nil) }
		return mapped
	}
}
