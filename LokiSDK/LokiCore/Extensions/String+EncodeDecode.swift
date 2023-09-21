//
//  String+EncodeDecode.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

extension String {
	func encodeBase64() -> String? {
		if let data = self.data(using: .utf8) {
			return data.base64EncodedString()
		}
		return nil
	}
	
	func decodeBase64() -> String? {
		if let data = Data(base64Encoded: self) {
			return String(data: data, encoding: .utf8)
		}
		return nil
	}
}
