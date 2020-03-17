//
//  MainDogListPresenter.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation

protocol DogListView: class {
	var presenter: DogListPresenter? { get set }
	func displayDogsWithImages(dogData: DogBreedResolvedImages)
	func displaySuggestedNames(dogBreeds: String)
}

protocol DogListPresenter {
	func viewLoaded()
	func userInputChanged(to: String)
}

class MainDogListPresenter: DogListPresenter {
	
	private let dogDataManager: DogDataManager
	private let asyncDispatch = DispatchQueue.init(label: "DogListPresenter", qos: .userInteractive)
	private let mainDispatch = DispatchQueue.main
	
	// Keep the reference weak to avoid a retain cycle
	private weak var dogListView: DogListView?
	
	public init(
		dataManager: DogDataManager,
		view: DogListView
	) {
		self.dogDataManager = dataManager
		self.dogListView = view
		
		// A little dirty; we'd like to have things like this injected with some
		// fancy tools, but this is simple enough: the view's presenter becomes
		// whatever presenter is latest constructed with it.
		view.presenter = self
	}
	
	func viewLoaded() {
		asyncDispatch.async { [weak self] in
			self?.dogDataManager.fetchInitialDogBreedList { initialList in
				self?.mainDispatch.async {
					self?.dogListView?.displayDogsWithImages(dogData: initialList)
					self?.dogListView?.displaySuggestedNames(dogBreeds: "")
				}
			}
		}
	}
	
	func userInputChanged(to: String) {
		
		// Don't bother fetching when the suggestions are empty; we don't show images,
		// and we don't want to kick off a fetch of everything.
		guard to.count > 0 else {
			mainDispatch.async {
				self.dogListView?.displaySuggestedNames(dogBreeds: "")
				self.dogListView?.displayDogsWithImages(dogData: self.dogDataManager.allKnownDogs)
			}
			return
		}
		
		asyncDispatch.async { [weak self] in
			self?.dogDataManager.dogSuggestionsForInput(userInput: to) { dogList in
				
				// First display the names, then begin fetching images
				// This section is a little ugly as well; we're rebuilding a string each time we have
				// a new suggestion, which could be done by the manager itself. If we had
				// true cached responses, this would be less worrisome.
				
				let allBreedNames: String
				if dogList.breedNameToUrlTuples.count == 0 {
					allBreedNames = "No breeds found matching '\(to)'"
				} else if dogList.breedNameToUrlTuples.count == 1 {
					allBreedNames = "Found '\(dogList.breedNameToUrlTuples.first!.breedName)'"
				} else {
					allBreedNames = "Suggested breeds: " + dogList.breedNameToUrlTuples.map { $0.breedName }.joined(separator: ", ")
				}
				
				self?.mainDispatch.async {
					self?.dogListView?.displaySuggestedNames(dogBreeds: allBreedNames)
					self?.dogListView?.displayDogsWithImages(dogData: dogList)
				}
				
				self?.dogDataManager.dogImagesForSuggestions(dogList) { resolvedImages in
					self?.mainDispatch.async {
						self?.dogListView?.displayDogsWithImages(dogData: resolvedImages)
					}
				}
			}
		}
	}
	
}
