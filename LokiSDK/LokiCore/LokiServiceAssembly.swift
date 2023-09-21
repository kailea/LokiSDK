//
//  LokiServiceAssembly.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 18/4/2023.
//

import Foundation
import Swinject

class LokiServiceAssembly: Assembly {
	func assemble(container: Container) {
		container.register(LokiNetwokEventMonitor.self) {_ in LokiNetworkLogger()
		}.inObjectScope(.container)
		
		container.register(LokiDataDecoder.self) {_ in LokiJsonDecoder()
		}.inObjectScope(.container)
		
		container.register(LokiApiManagerInterface.self) { r in
			LokiAPIManager(networkLogger: r.resolve(LokiNetwokEventMonitor.self)!, decoder: r.resolve(LokiDataDecoder.self)!)
		}.inObjectScope(.container)
		
		container.register(LokiLocationManagerInterface.self) {_ in LokiLocationManager()
		}.inObjectScope(.container)
	}
}
