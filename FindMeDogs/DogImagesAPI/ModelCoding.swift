//
//  ModelCoding.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import Foundation

class ModelCoding {
	
	public static let shared = ModelCoding()
	private let jsonDecoder = JSONDecoder()
	
	private init() { }
	
	// We make things a little simpler error-handling wise by assuming we will
	// always return an instance of the expected type, even if it's an empty instance.
	// This is a bit double edged, as it can 'hide' potential mapping errors,
	// but relieves the burden of constant unwrapping at higher abstraction layers
	func decode<T: Codable & Constructible>(data: Data?, asModel: T.Type) -> T {
		guard let data = data else { return asModel.init() }
		let maybeModel = try? jsonDecoder.decode(asModel, from: data)
		return maybeModel ?? asModel.init()
	}
}
