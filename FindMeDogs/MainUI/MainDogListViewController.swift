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

class MainDogListViewController: UIViewController, DogListView {
	
	// MARK: DogListView
	var currentDogNames: [String] = []
	
	var presenter: DogListPresenter?
	
	func displayDogNames(names: [String]) {
		self.currentDogNames = names
		self.tableView.reloadData()
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

	override func viewDidLoad() {
		super.viewDidLoad()	
		
		// Add and constrain tableview
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
		])
		
		presenter?.viewLoaded()
	}
}

extension MainDogListViewController: UITableViewDelegate {
	
}

extension MainDogListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currentDogNames.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = (tableView.dequeueReusableCell(withIdentifier: TableCells.mainDogListCell.rawValue)
				?? MainDogListTableViewCell()) as! MainDogListTableViewCell
		
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


