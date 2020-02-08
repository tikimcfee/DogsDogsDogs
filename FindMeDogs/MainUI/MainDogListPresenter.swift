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
	func displayDogNames(names: [String])
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
		
		// A little dirty; we'd like to have things like this injected with some
		// fancy tools, but this is simple enough: the view's presenter becomes
		// whatever presenter is latest constructed with it.
		view.presenter = self
		self.dogListView = view
	}
	
	func viewLoaded() {
		asyncDispatch.async { [weak self] in
			self?.dogDataManager.fetchInitialDogBreedList { initialList in
				self?.mainDispatch.async {
					self?.dogListView?.displayDogNames(names: initialList.message)
				}
			}
		}
	}
	
	func userInputChanged(to: String) {
		asyncDispatch.async { [weak self] in
			self?.dogDataManager.dogSuggestionsForInput(userInput: to) { dogList in
				self?.mainDispatch.async {
					self?.dogListView?.displayDogNames(names: dogList)
				}
			}
		}
	}
	
	deinit {
		print("Did deinit presenter")
	}
	
}
