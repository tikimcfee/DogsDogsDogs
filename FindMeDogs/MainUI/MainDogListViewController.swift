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
	
	// !!! Warning !!!
	// This is somewhat of an indicator of a weak backing model for this; ideally, a single model
	// with optional data would be passed through a view model, and the view would 'switch' between
	// one cell type and another. We jump this hurdle with a 'view mode' that switches between which cells
	// to instantiate / dequeue / configure
	// ---------------
	var currentDogNames: [String] = []
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
		view.backgroundColor = UIColor.white
		
		// Add and constrain tableview
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

extension MainDogListViewController: DogListView {
	
	func displayDogNames(names: [String]) {
		self.currentMode = .mainDogList
		self.currentDogNames = names
		self.tableView.reloadData()
	}
	
	func displayDogsWithImages(dogData: DogBreedResolvedImages) {
		self.currentMode = .dogsWithImages
		self.currentResolvedImages = dogData
		self.tableView.reloadData()
	}
	
}

extension MainDogListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}
}

extension MainDogListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let imageCell = cell as? MainDogWithImageTableViewCell {
			imageCell.dogImage.kf.cancelDownloadTask()
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch currentMode {
			case .dogsWithImages:
				return currentResolvedImages.resolvedImages.count
			default:
				return currentDogNames.count
		}
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
		
		cell.configure(currentDogNames[indexPath.row])
		
		return cell
	}
	
	private func cellForImageMode(at indexPath: IndexPath) -> UITableViewCell {
		let cell = (tableView.dequeueReusableCell(withIdentifier: TableCells.dogWithImageCell.rawValue) ?? MainDogWithImageTableViewCell()) as! MainDogWithImageTableViewCell
		
		cell.configure(resolvedBreed: currentResolvedImages.resolvedImages[indexPath.row])
		
		return cell
	}
}

class MainDogWithImageTableViewCell: UITableViewCell {
	
	private let dogNameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let dogImage: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(dogNameLabel)
		contentView.addSubview(dogImage)
		
		NSLayoutConstraint.activate([
			dogNameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
			dogNameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			
			dogImage.topAnchor.constraint(equalTo: dogNameLabel.bottomAnchor),
			dogImage.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			dogImage.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			dogImage.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
			dogImage.heightAnchor.constraint(greaterThanOrEqualToConstant: 80.0),
		])
	}
	
	func configure(resolvedBreed: DogBreedImageTuple) {
		dogNameLabel.text = resolvedBreed.breedName
		dogImage.kf.setImage(with: resolvedBreed.breedImage)
	}
}

class MainDogListTableViewCell: UITableViewCell {
	
	private let dogNameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// No nibs, no coders - just manual instantiation
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(dogNameLabel)
		
		NSLayoutConstraint.activate([
			dogNameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
			dogNameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			dogNameLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
			dogNameLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
		])
	}
	
	func configure(_ dogName: String) {
		dogNameLabel.text = dogName
	}
}
