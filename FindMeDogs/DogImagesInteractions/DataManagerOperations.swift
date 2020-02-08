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
	
	private let targetBreeds: [String]
	private let fetcher: DogsApi
	var resolvedDogImages = DogBreedResolvedImages()
	
	init(
		_ targets: [String],
		_ fetcher: DogsApi
	) {
		self.targetBreeds = targets
		self.fetcher = fetcher
	}
	
	override func main() {
		if isCancelled { return }
		
		let dispatchGroup = DispatchGroup()
		
		for dogName in targetBreeds {
			if isCancelled { return }
			
			dispatchGroup.enter()
			
			fetcher.fetchDogImages(for: dogName) { dogBreedImages in
				if self.isCancelled { return }
				
				let allBreedImages = dogBreedImages.imageUrls
				
				for breedImage in allBreedImages {
					if self.isCancelled { return }
					
					self.resolvedDogImages.resolvedImages.append(
						(dogName, breedImage)
					)
				}
				
				dispatchGroup.leave()
			}
		}
		
		dispatchGroup.wait()
		
	}
}

class DogBreedSearcher: Operation {
	
	private let dogBreedsList: DogBreedsList
	private let searchString: String
	var didComplete: Bool = false
	var result: [String] = []
	
	init(_ list: DogBreedsList, _ search: String) {
		self.dogBreedsList = list
		self.searchString = search.lowercased()
	}
	
	override func main() {
		if isCancelled { return }
		
		for dogName in dogBreedsList.message {
			if isCancelled { return }
			
			if dogName.starts(with: searchString) {
				result.append(dogName)
			}
		}
	}
	
}
