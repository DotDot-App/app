//
//  AuthManager.swift
//  DotDot
//
//  Created by Lily Sai on 4/21/21.
//

import FirebaseAuth

public class AuthManager {
    static let shared = AuthManager()
    
    // MARK: - Public
    
    public func createUser(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        // check if username is available
        // check if email is available
        DatabaseManager.shared.canCreateUser(with: email, username: username) { canCreate in
            if canCreate {
                // create account
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil else {
                        // firebase auth could not create account
                        completion(false)
                        return
                    }
                                        
                    // insert account to database
                    DatabaseManager.shared.insertUser(with: email, username: username) { inserted in
                        if inserted {
                            completion(true)
                            return
                        } else {
                            completion(false)
                            return
                        }
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    public func signinUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        if let email = email {
            // email sign in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        } else if let username = username {
            // username sign in
            print(username)
        }
    }
    
    public func signoutUser(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        } catch {
            print(error)
            completion(false)
            return
        }
    }
}
