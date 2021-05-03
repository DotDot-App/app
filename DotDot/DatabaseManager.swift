//
//  DatabaseManager.swift
//  DotDot
//
//  Created by Lily Sai on 4/21/21.
//

import FirebaseDatabase

public class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    // MARK: - Public
    
    public func canCreateUser(with email: String, username: String, completion: (Bool) -> Void) {
        completion(true)
    }
    
    public func insertUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
        let safeEmail = email.safeDatabaseKey()
        
        database.child(safeEmail).setValue(["username": username]) { error, _ in
            if error == nil {
                // succeeded
                completion(true)
                return
            } else {
                // failed
                completion(false)
                return
            }
        }
    }
    
    // MARK: - Private

}
