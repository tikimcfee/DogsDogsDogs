//
//  MainDogListTableViewCells.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation
import UIKit


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
