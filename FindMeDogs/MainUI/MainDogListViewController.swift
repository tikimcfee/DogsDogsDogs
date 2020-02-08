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
}

class MainDogListViewController: UIViewController {
	
	// MARK: DogListView
	var currentDogNames: [String] = []
	var presenter: DogListPresenter?
	
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
		
		return tableView
	}()
	
	lazy var inputField: UITextField = {
		let textField = UITextField()
		textField.text = "Enter some dogs here"
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
		self.currentDogNames = names
		self.tableView.reloadData()
	}
	
}

extension MainDogListViewController: UITableViewDelegate {
	
}

extension MainDogListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currentDogNames.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = (tableView.dequeueReusableCell(withIdentifier: TableCells.mainDogListCell.rawValue) ?? MainDogListTableViewCell()) as! MainDogListTableViewCell
		
		cell.configure(currentDogNames[indexPath.row])
		
		return cell
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


