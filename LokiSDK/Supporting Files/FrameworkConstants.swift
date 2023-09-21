//
//  FrameworkConstants.swift
//  LokiSDK
//
//  Created by Amandeep Kaile on 19/9/2023.
//

import Foundation

struct FrameworkConstants {
	static var trackingServiceUrl: String = {
		guard let url = Bundle.main.object(forInfoDictionaryKey: "TRACKING_SERVICE_URL") as? String else {
			return ""
		}
		return url
	}()
}
