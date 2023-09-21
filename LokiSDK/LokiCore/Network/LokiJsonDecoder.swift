//
//  LokiJsonDecoder.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 18/4/2023.
//

import Foundation

class LokiJsonDecoder : JSONDecoder {
	override init() {
		super.init()
		dateDecodingStrategy =  .customISO8601
	}
}

extension LokiJsonDecoder : LokiDataDecoder {
	
}
