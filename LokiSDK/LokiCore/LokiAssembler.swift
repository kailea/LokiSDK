//
//  LokiAssembler.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 18/4/2023.
//

import Foundation
import Swinject

extension Assembler {
	static let shared: Assembler = {
		let container = Container()
		let assembler = Assembler([LokiServiceAssembly()], container: container)
		return assembler
	}()
}
