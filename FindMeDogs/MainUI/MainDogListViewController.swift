//
//  ViewController.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import UIKit

enum TableCells: String {
	case mainDogListCell = "MainDogListCell"
	case dogWithImageCell = "DogWithImageCell"
}

enum TableMode {
	case mainDogList, dogsWithImages
}

class MainDogListViewController: UIViewController {
	
	// MARK: DogListView
	var currentMode: TableMode = .mainDogList
	var presenter: DogListPresenter? = nil
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
		
		tableView.register(MainDogListTableViewCell.self, forCellReuseIdentifier: TableCells.mainDogListCell.rawValue)
		tableView.register(MainDogWithImageTableViewCell.self, forCellReuseIdentifier: TableCells.dogWithImageCell.rawValue)
		
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
	
	private func configure() {
		// Really simple configurations
		view.backgroundColor = UIColor.white
		
		view.addSubview(inputField)
		view.addSubview(tableView)
		
		NSLayoutConstraint.activate([
			inputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			inputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			inputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			inputField.bottomAnchor.constraint(equalTo: tableView.topAnchor),
			
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
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
		let cell = (tableView.dequeueReusableCell(withIdentifier: TableCells.mainDogListCell.rawValue) ?? MainDogListTableViewCell()) as! MainDogListTableViewCell
		cell.configure(currentResolvedImages.breedNameToUrlTuples[indexPath.row].breedName)
		return cell
	}
	
	private func cellForImageMode(at indexPath: IndexPath) -> UITableViewCell {
		let cell = (tableView.dequeueReusableCell(withIdentifier: TableCells.dogWithImageCell.rawValue) ?? MainDogWithImageTableViewCell()) as! MainDogWithImageTableViewCell
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
