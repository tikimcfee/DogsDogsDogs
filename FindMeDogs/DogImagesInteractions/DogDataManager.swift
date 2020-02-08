//
//  DogListDataManager.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation
import Kingfisher

typealias DogSearchCallback = (DogBreedResolvedImages) -> Void

class DogDataManager {
	
	// You'd usually want to inject a protocol here to make this more easily testable
	private var dogsApi: DogsApi = DogsApi() 
	
	// Do everything in cancellable operations! Hooray!
	private let dataOperator = DogDataManagerOperations()
	
	// Start the list as empty; fetch on start()
	var allKnownDogs: DogBreedResolvedImages = DogBreedResolvedImages()
	
	func fetchInitialDogBreedList(_ callback: @escaping DogSearchCallback) {
		dogsApi.fetchDogList { [weak self] breedList in
			let mappedImages = breedList.asResolvedImages
			self?.allKnownDogs = mappedImages			
			callback(mappedImages)
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
		_ dogNames: DogBreedResolvedImages,
		_ callback: @escaping DogSearchCallback
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

