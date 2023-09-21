//
//  DeviceInfo.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation
import UIKit
import DeviceKit

// MARK: - Device
public struct DeviceInfo: Codable {
	public let id: String
	public let manufacturer: String?
	public let make: String?
	public let operatingSystem: String?
	public let operatingSystemVersion: String?
	public let model: String?
	
	enum CodingKeys: String, CodingKey {
		case id = "Id"
		case manufacturer = "manufacturer"
		case make = "make"
		case operatingSystem = "operatingSystem"
		case operatingSystemVersion = "operatingSystemVersion"
		case model = "model"
	}
	
	public init(id: String) {
		let device = DeviceKit.Device.current
		self.id = id
		self.manufacturer = "Apple"
		self.make = device.safeDescription
		self.operatingSystem = device.systemName
		self.operatingSystemVersion = device.systemVersion
		self.model = device.model
	}
}
