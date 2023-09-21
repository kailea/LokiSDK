//
//  NSSet+Array.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 17/4/2023.
//

import Foundation

extension Optional where Wrapped == NSSet {
	func array<T: Hashable>(of: T.Type) -> [T] {
		if let set = self as? Set<T> {
			return Array(set)
		}
		return [T]()
	}
}
