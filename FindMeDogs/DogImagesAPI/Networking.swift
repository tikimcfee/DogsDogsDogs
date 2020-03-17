//
//  NetworkFetching.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation


typealias DogBreedsListCallback = (DogAPI_BreedsListResponse) -> Void
typealias DogBreedImageListCallback = (DogAPI_DogBreedImagesResponse) -> Void
typealias URLSessionCompletion = (Data?, URLResponse?, Error?) -> Void


// Meat of fetching from Dogs API. Handles model coding / decoding, and handles work
// on its own queue
class DogsApi {
	
	// In a larget application, you'd likely want a separate networking class
	// to handle header configurations, caching mechanisms, etc. Most of the
	// work in this app is temporary, so there's no real reason to complicate
	// things too much
	private let urlSession = URLSession.shared
	private let basePath = "https://dog.ceo/api"
	private let backgroundQueue = DispatchQueue.init(label: "DogFetchAPIQueue", qos: .userInitiated)
	
	private func fetch(_ url: URL, _ callback: @escaping URLSessionCompletion) {
		backgroundQueue.async { [weak self] in
			self?.urlSession.dataTask(with: url, completionHandler: callback).resume()
		}
	}
	
	func fetchDogList(
		with completion: @escaping DogBreedsListCallback
	) {
		fetch(Endpoint.allBreedsList.url(basePath)) { data, _, _ in
			let dogBreedListModel = ModelCoding.shared.decode(data: data, asModel: DogAPI_BreedsListResponse.self)
			completion(dogBreedListModel)
		}
	}
	
	func fetchDogImages(
		for breed: String, 
		with completion: @escaping DogBreedImageListCallback
	) {
		fetch(Endpoint.imagesForBreed(breed).url(basePath)) { data, _, _ in
			let dogImageListModel = ModelCoding.shared.decode(data: data, asModel: DogAPI_DogBreedImagesResponse.self)
			completion(dogImageListModel)
		}
	}
	
}
