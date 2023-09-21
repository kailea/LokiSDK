//
//  Bundle+AppName.swift
//  Lifestream
//
//  Created by Amandeep Kaile on 19/5/2023.
//  Copyright © 2023 Guardian Pty Ltd. All rights reserved.
//

import Foundation

extension Bundle {
	var appName: String {
		if let retValue = (object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)?.trimming(spaces: .leadingAndTrailing) ?? (object(forInfoDictionaryKey: "CFBundleName") as? String)?.trimming(spaces: .leadingAndTrailing), retValue.count > 0 {
			let updatedRetVal = retValue.replacingOccurrences(of: " ", with: "_")
			return String("\(updatedRetVal)_")
		}
		return ""
	}
}
