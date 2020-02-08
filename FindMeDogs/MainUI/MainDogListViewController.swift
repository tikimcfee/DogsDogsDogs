//
//  ViewController.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import UIKit

enum TableMode {
	case mainDogList, dogsWithImages
}

class MainDogListViewController: UIViewController {
	
	// DogListView requirement
	var presenter: DogListPresenter? = nil
	
	// View holds a reference to last instance to separate data from current presenter / manager state
	var currentMode: TableMode = .mainDogList
	var currentResolvedImages = DogBreedResolvedImages()
	
	override func viewDidLoad() {
		super.viewDidLoad()	
		configure()
		presenter?.viewLoaded()
	}
	
	// MARK: VC Views and setup
	lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.preservesSuperviewLayoutMargins = true
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.register(MainDogListTableViewCell.self, forCellReuseIdentifier: MainDogListTableViewCell.ReuseIdentifier)
		tableView.register(MainDogWithImageTableViewCell.self, forCellReuseIdentifier: MainDogWithImageTableViewCell.ReuseIdentifier)
		
		return tableView
	}()
	
	lazy var inputField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Type a dog breed here"
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.preservesSuperviewLayoutMargins = true
		textField.addTarget(self, action: #selector(userTextDidChange), for: UIControl.Event.editingChanged)
		return textField
	}()
	
	lazy var suggestedBreedsLabel: UILabel = {
		let suggestedNames = UILabel()
		suggestedNames.translatesAutoresizingMaskIntoConstraints = false
		suggestedNames.preservesSuperviewLayoutMargins = true
		suggestedNames.numberOfLines = 0
		suggestedNames.lineBreakMode = .byWordWrapping
		suggestedNames.textColor = UIColor.gray
		return suggestedNames
	}()
	
	func makeSeparator() -> UIView {
		let separator = UIView()
		separator.translatesAutoresizingMaskIntoConstraints = false
		separator.backgroundColor = UIColor.gray
		return separator
	}
	
	private func configure() {
		// Really simple configurations; nevermind UIStackView - Good ol' constraints!
		view.backgroundColor = UIColor.white
		
		let topSeparator = makeSeparator()
		let bottomSeparator = makeSeparator()
		
		view.addSubview(topSeparator)
		view.addSubview(inputField)
		view.addSubview(suggestedBreedsLabel)
		view.addSubview(bottomSeparator)
		view.addSubview(tableView)
		
		let insets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
		
		NSLayoutConstraint.activate([
			topSeparator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: insets.top),
			topSeparator.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			topSeparator.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			topSeparator.heightAnchor.constraint(equalToConstant: 1.0),
			
			inputField.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: insets.top),
			inputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: insets.left),
			inputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right),
			inputField.bottomAnchor.constraint(equalTo: suggestedBreedsLabel.topAnchor, constant: -insets.bottom),
			
			suggestedBreedsLabel.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: insets.top),
			suggestedBreedsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: insets.left),
			suggestedBreedsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right),
			suggestedBreedsLabel.bottomAnchor.constraint(equalTo: bottomSeparator.topAnchor, constant: -insets.bottom),
			
			bottomSeparator.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			bottomSeparator.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			bottomSeparator.heightAnchor.constraint(equalToConstant: 1.0),
			
			tableView.topAnchor.constraint(equalTo: bottomSeparator.bottomAnchor, constant: insets.top),
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
		])
	}
	
	@objc private func userTextDidChange() {
		presenter?.userInputChanged(to: inputField.text ?? "")
	}
}

// MARK: View protocol implementation
extension MainDogListViewController: DogListView {
	
	func displayDogsWithImages(dogData: DogBreedResolvedImages) {
		self.currentMode = dogData.includesResolvedURLs ? .dogsWithImages : .mainDogList
		self.currentResolvedImages = dogData
		self.tableView.reloadData()
	}
	
	func displaySuggestedNames(dogBreeds: String) {
		suggestedBreedsLabel.text = dogBreeds
		suggestedBreedsLabel.isHidden = dogBreeds.count == 0
	}
}

// MARK: UITableViewDataSource Implementation
extension MainDogListViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let imageCell = cell as? MainDogWithImageTableViewCell {
			imageCell.dogImage.kf.cancelDownloadTask()
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currentResolvedImages.breedNameToUrlTuples.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch (currentMode) {
			case .dogsWithImages:
				return cellForImageMode(at: indexPath)
			case .mainDogList:
				return cellForSuggestionMode(at: indexPath)
		}
	}
	
	private func cellForSuggestionMode(at indexPath: IndexPath) -> UITableViewCell {
		let cell = (
			tableView.dequeueReusableCell(withIdentifier: MainDogListTableViewCell.ReuseIdentifier) 
			?? MainDogListTableViewCell()
		) as! MainDogListTableViewCell
		
		cell.configure(currentResolvedImages.breedNameToUrlTuples[indexPath.row].breedName)
		return cell
	}
	
	private func cellForImageMode(at indexPath: IndexPath) -> UITableViewCell {
		let cell = (
			tableView.dequeueReusableCell(withIdentifier:  MainDogWithImageTableViewCell.ReuseIdentifier)
			?? MainDogWithImageTableViewCell()
		) as! MainDogWithImageTableViewCell
		
		cell.configure(resolvedBreed: currentResolvedImages.breedNameToUrlTuples[indexPath.row])
		return cell
	}
}

// MARK: UITableViewDelegate Implementation
extension MainDogListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	// Dismiss keyboard when scrolling around
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.inputField.endEditing(true)
	}
}
