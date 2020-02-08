//
//  Endpoint.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation

// Simple list of endpoints, and easier construction of URLs
enum Endpoint {
	
	case allBreedsList
	case imagesForBreed(String)
	
	var path: String {
		switch (self) {
			case .allBreedsList:
				return "/breeds/list"
			case .imagesForBreed(let breedName):
				return "/breed/\(breedName)/images"
		}
	}
	
	// A little dirty; forced unwrapping isn't great, especially for a dynamic URL,
	// but it makes constructing fetch requests easier to read and consume
	func url(_ basePath: String) -> URL {
		return URL.init(string: basePath + path)!
	}
}
