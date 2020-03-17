//
//  DataManagerOperations.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation

enum OperationKey: Hashable, Equatable {
	case searchBreedList, getImages
}

class DogDataManagerOperations {
	
	lazy var operationsInProgress: [OperationKey : Operation] = [:]
	lazy var operationQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.qualityOfService = .userInteractive
		queue.name = "Dog Data Manager Queue"
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
	
	func cancelExistingOperation(_ key: OperationKey) {
		let maybeOp = operationsInProgress.removeValue(forKey: key)
		maybeOp?.cancel()
	}
	
	func addOperation(_ key: OperationKey, _ op: Operation) {
		operationsInProgress[key] = op
		operationQueue.addOperation(op)
	}
}

class DogImagesFetcher: Operation {
	
	private let targetBreeds: DogBreedResolvedImages
	private let fetcher: DogsApi
	var resolvedDogImages = DogBreedResolvedImages()
	
	init(
		_ targets: DogBreedResolvedImages,
		_ fetcher: DogsApi
	) {
		self.targetBreeds = targets
		self.fetcher = fetcher
	}
	
	override func main() {
		if isCancelled { return }
		
		// Create a dispatch group to await while we fetch all 
		// the image urls for each target breed
		let dispatchGroup = DispatchGroup()
		
		for dogImageMapping in targetBreeds.breedNameToUrlTuples {
			if isCancelled { return }
			
			// Each dog name results in a fetch and mapping; enter group external to the fetch
			dispatchGroup.enter()
			let dogName = dogImageMapping.breedName
			
			fetcher.fetchDogImages(for: dogName) { dogBreedImages in
				
				if self.isCancelled {
					dispatchGroup.leave()
					return 
					
				}
				
				// Essentially a flatMap, but allows for cancellation
				for breedImage in dogBreedImages.imageUrls {
					if self.isCancelled {
						dispatchGroup.leave()
						return 
					}
					
					self.resolvedDogImages.breedNameToUrlTuples.append(
						(dogName, breedImage)
					)
				}
				
				// Leave the group *after* the fetch has completed and mapped URLs
				dispatchGroup.leave()
			}
		}
		
		// Images have been fetched
		resolvedDogImages.includesResolvedURLs = true
		
		// Wait for 'dispatched' groups to complete
		dispatchGroup.wait()
	}
}

class DogBreedSearcher: Operation {
	
	private let dogBreedsList: DogBreedResolvedImages
	private let searchString: String
	var didComplete: Bool = false
	var result: DogBreedResolvedImages = DogBreedResolvedImages()
	
	init(_ list: DogBreedResolvedImages, _ search: String) {
		self.dogBreedsList = list
		self.searchString = search.lowercased()
	}
	
	override func main() {
		if isCancelled { return }
		
		var breedNames: [String] = []
		for dogMapping in dogBreedsList.breedNameToUrlTuples {
			if isCancelled { return }
			
			if dogMapping.breedName.starts(with: searchString) {
				breedNames.append(dogMapping.breedName)
			}
		}
		
		result = breedNames.asResolvedImages
	}
	
}
