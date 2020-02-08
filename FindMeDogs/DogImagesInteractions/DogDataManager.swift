//
//  DogListDataManager.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation

typealias InitialFetchCallback = (DogBreedsList) -> Void
typealias DogSearchCallback = ([String]) -> Void

enum OperationKey: Hashable, Equatable {
	case searchBreedList
}

class DogDataManager {
	
	// You'd usually want to inject a protocol here to make this more easily testable
	private var dogsApi: DogsApi = DogsApi() 
	
	// Start the list as empty; fetch on start()
	private var allKnownDogs: DogBreedsList = DogBreedsList()
	
	// Do everything in cancellable operations! Hooray!
	private let dataOperator = DogDataManagerOperations()
	
	func fetchInitialDogBreedList(_ callback: @escaping InitialFetchCallback) {
		dogsApi.fetchDogList { [weak self] breedList in
			self?.allKnownDogs = breedList
			callback(breedList)
		}
	}
	
	func dogSuggestionsForInput(
		userInput: String,
		_ callback: @escaping DogSearchCallback
	) {
		dataOperator.cancelExistingOperation(.searchBreedList)
		
		let searcher = DogBreedSearcher(allKnownDogs, userInput)
		searcher.completionBlock = {
			if searcher.isCancelled { return }
			callback(searcher.result)
		}
		
		dataOperator.addOperation(.searchBreedList, searcher)
	}
	
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

class DogBreedSearcher: Operation {
	
	private let dogBreedsList: DogBreedsList
	private let searchString: String
	var didComplete: Bool = false
	var result: [String] = []
	
	init(_ list: DogBreedsList, _ search: String) {
		self.dogBreedsList = list
		self.searchString = search
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
