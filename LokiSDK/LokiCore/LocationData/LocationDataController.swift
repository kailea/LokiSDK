//
//  LocationDataController.swift
//  Lifestream
//
//  Created by Amandeep Kaile on 24/5/2023.
//  Copyright © 2023 Guardian Pty Ltd. All rights reserved.
//

import Foundation
import CoreData


class LocationDataController: ObservableObject {
	let container : NSPersistentContainer
	
	init(dbName: String) {
		container = NSPersistentContainer(name: dbName)
		container.loadPersistentStores{(description, error) in
			if let error = error{
				print ("unable to load data \(error)")
			}
		}
	}
	
	func clearLocationData() -> Bool{
		let fetchQuery: NSFetchRequest<NSFetchRequestResult> = LocationEntity.fetchRequest()
		let batchDeleteQuery = NSBatchDeleteRequest(fetchRequest: fetchQuery)
		let context = container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		var result = false
		context.performAndWait {
			do {
				_ = try context.execute(batchDeleteQuery)
				result =  true
			} catch {
				result = false
			}
		}
		return result
	}
	
	func getLocationData() -> [LocationEntity]? {
		let fetchQuery = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
		do {
			let users = try container.viewContext.fetch(fetchQuery)
			return users
		} catch {
			return nil
		}
	}
	
	func removeOldData() {
		let context = container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		let fetchQuery = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
		let dateSort = NSSortDescriptor(key:"recordedTime", ascending:true)
		fetchQuery.sortDescriptors = [dateSort]
		context.perform {
			do {
				let locations = try context.fetch(fetchQuery)
				if locations.count > 500 {
					let firstRecordToKeep = locations[500]
					let deleteQuery = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
					deleteQuery.predicate = NSPredicate(format: "recordedTime < %@", firstRecordToKeep.recordedTime! as NSDate)
					let objects = try context.fetch(deleteQuery)
					for object in objects {
						context.delete(object)
					}
					try context.save()
				}
			} catch {
				print("Location Data: Unable to remove Old Data")
			}
		}
	}
	
	func addLocation(locationInfo: LocationInfo) {
		let context = container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.perform {
			do {
				let location = LocationEntity(context: context)
				location.id = locationInfo.locationId
				location.latitude = locationInfo.location.coordinate.latitude
				location.longitude = locationInfo.location.coordinate.longitude
				location.horizontalAccuracy = locationInfo.location.horizontalAccuracy
				location.recordedTime = locationInfo.location.timestamp
				location.speed = locationInfo.location.speed
				location.sendStatus = SendStatus.ignored.rawValue
				try context.save()
			} catch {
				print("Location Data: Unable to Add Location")
			}
		}
	}
	
	func updateSendTime(locationId: String) {
		let fetchQuery = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
		let context = container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.perform {
			do {
				if let location = try context.fetch(fetchQuery).first(where: {$0.id == locationId}) {
					location.sendTime = Date.now
					try context.save()
				}
			} catch {
				print("Location Data: Unable to Update send time")
			}
		}
	}
	
	func updateResendTime(locationId: String) {
		let fetchQuery = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
		let context = container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.perform {
			do {
				if let location = try context.fetch(fetchQuery).first(where: {$0.id == locationId}) {
					location.resendTime = Date.now
					try context.save()
				}
			} catch {
				print("Location Data: Unable to Update resend time")
			}
		}
	}
	
	func updateSendStatus(locationId: String, status: SendStatus, error: String? = nil) {
		let fetchQuery = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
		let context = container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.perform {
			do {
				if let location = try context.fetch(fetchQuery).first(where: {$0.id == locationId}) {
					location.sendStatus = status.rawValue
					if let error = error {
						if status == .mqttFailed {
							location.mqttResponseError = error
						} else if status == .httpFailed {
							location.httpError = error
						}
					}
					try context.save()
				}
			} catch {
				print("Location Data: Unable to Update send status")
			}
		}
	}
	
	func updateResendStatus(locationId: String, status: SendStatus, error: String? = nil) {
		let fetchQuery = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
		let context = container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		context.perform {
			do {
				if let location = try context.fetch(fetchQuery).first(where: {$0.id == locationId}) {
					location.resendStatus = status.rawValue
					if let error = error {
						if status == .httpFailedEx {
							location.httpError = error
						}
					}
					try context.save()
				}
			} catch {
				print("Location Data: Unable to Update resend status")
			}
		}
	}
	
	func getSendStatus(locationId: String) -> SendStatus? {
		let fetchQuery = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
		let context = container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		var result: SendStatus? = nil
		context.performAndWait {
			do {
				if let location = try context.fetch(fetchQuery).first(where: {$0.id == locationId}) {
					
					let sendStatus = location.sendStatus
					let status = SendStatus(rawValue: sendStatus)
					if status == .unknown || status == .httpSend || status == .mqttSend {
						result = status
					} else if status == .httpFailed || status == .mqttFailed {
						let sendStatus = location.resendStatus
						result = SendStatus(rawValue: sendStatus)
					}
				} else {
					result = nil
				}
			} catch {
				result = nil
			}
		}
		return result
	}
}
