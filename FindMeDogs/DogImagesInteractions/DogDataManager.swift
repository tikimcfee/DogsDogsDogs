//
//  DogListDataManager.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation
import Kingfisher

typealias InitialFetchCallback = (DogBreedsList) -> Void
typealias DogSearchCallback = ([String]) -> Void
typealias DogSearchImageCallback = (DogBreedResolvedImages) -> Void


class DogDataManager {
	
	// You'd usually want to inject a protocol here to make this more easily testable
	private var dogsApi: DogsApi = DogsApi() 
	
	// Do everything in cancellable operations! Hooray!
	private let dataOperator = DogDataManagerOperations()
	
	// Start the list as empty; fetch on start()
	var allKnownDogs: DogBreedsList = DogBreedsList()
	var allKnownDogNames: [String] {
		return allKnownDogs.message
	}
	
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
	
	func dogImagesForSuggestions(
		_ dogNames: [String],
		_ callback: @escaping DogSearchImageCallback
	) {
		dataOperator.cancelExistingOperation(.getImages)
		
		let images = DogImagesFetcher(dogNames, dogsApi)
		images.completionBlock = {
			if images.isCancelled { return }
			callback(images.resolvedDogImages)
		}
		
		dataOperator.addOperation(.searchBreedList, images)
	}
	
}

