//
//  String+Pointer.swift
//  Loki
//
//  Created by Amandeep Kaile on 13/4/2023.
//

import Foundation


extension String {
	func toUnsafePointer() -> UnsafePointer<UInt8>? {
		guard let data = self.data(using: .utf8) else {
			return nil
		}
		
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
		let stream = OutputStream(toBuffer: buffer, capacity: data.count)
		stream.open()
		let value = data.withUnsafeBytes {
			$0.baseAddress?.assumingMemoryBound(to: UInt8.self)
		}
		guard let val = value else {
			return nil
		}
		stream.write(val, maxLength: data.count)
		stream.close()
		
		return UnsafePointer<UInt8>(buffer)
	}
	
	func toUnsafeMutablePointer() -> (UnsafeMutablePointer<UInt8>?, Int)? {
		guard let data = self.data(using: .utf8) else {
			return nil
		}
		
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
		let stream = OutputStream(toBuffer: buffer, capacity: data.count)
		stream.open()
		let value = data.withUnsafeBytes {
			$0.baseAddress?.assumingMemoryBound(to: UInt8.self)
		}
		guard let val = value else {
			return nil
		}
		stream.write(val, maxLength: data.count)
		stream.close()
		
		return (buffer, data.count)
	}
}
