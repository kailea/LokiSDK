//
//  ObjectSavable.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 18/4/2023.
//

import Foundation

protocol ObjectSavable {
	func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
	func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}
