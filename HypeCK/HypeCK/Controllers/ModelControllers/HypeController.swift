//
//  HypeController.swift
//  HypeCK
//
//  Created by Marcus Armstrong on 2/4/20.
//  Copyright © 2020 Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

class HypeController {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    static let sharedInstance = HypeController()
    
    var hypes: [Hype] = []
    
    // MARK: - CRUD
    
    func saveHype(with bodyText: String, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        
        let newHype = Hype(body: bodyText)
        
        let hypeRecord = CKRecord(hype: newHype)
        
        publicDB.save(hypeRecord) { (record, error) in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let savedHype = Hype(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap)) }
            print("Saved Hype successfully")
            
            completion(.success(savedHype))
        }
    }
    
    func fetchAllHypes(completion: @escaping (Result<[Hype], HypeError>) ->Void) {
    
        let queryAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: queryAllPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { return completion(.failure(.couldNotUnwrap)) }
            
            let hypes = records.compactMap( { Hype(ckRecord: $0)})
            
            completion(.success(hypes))
        }
    }
    
    func update(_ hype: Hype, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        // Create a CKRecord from the passed in Hype
        let record = CKRecord(hype: hype)
        
        // Create an Operation
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        // Set the properties on the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            // handle the optional error
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first,
                let updatedHype = Hype(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap)) }
            completion(.success(updatedHype))
            
        }
        publicDB.add(operation)
    }
    
    func delete(_ hype: Hype, completion: @escaping (Result<Bool, HypeError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {records, _, error in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                completion(.success(true))
            } else {
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        publicDB.add(operation)
    }
    
    func subscribeForRemoteNotifications(completion: @escaping (_ error: Error?) -> Void) {
        
        // Step 2 - Create the needed predicate to pass into the subscription
            // This one just pulls all objects matching the recordType
        let predicate = NSPredicate(value: true)
        
        // Step 1 - Create CKQuerySubscription object
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        // Step 3 - Create a notification and set it's properties
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "CHOO CHOO"
        notificationInfo.alertBody = "Can't Stop the Hype Train!!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        
        subscription.notificationInfo = notificationInfo
        
        // Step 4 - Save the subscription to the database
        publicDB.save(subscription) { (_, error) in
            
            if let error = error {
                completion(error)
            }
            
            completion(nil)
        }
    }
    
}
