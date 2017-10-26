//
//  User.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 21/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding  {
    
    struct Keys {
        static let name = "name"
        static let height = "height"
        static let photo = "photo"
        static let email = "email"
        static let password = "password"
    }
    
    private var _name = ""
    private var _height = ""
    private var _photo = ""
    private var _email = ""
    private var _password = ""
    
    override init() {}
    
    init(name: String, height: String, photo: String, email: String, password: String) {
        self._name = name
        self._height = height
        self._photo = photo
        self._email = email
        self._password = password
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        if let nameObject = aDecoder.decodeObject(forKey: Keys.name) as? String,
            let heightObject = aDecoder.decodeObject(forKey: Keys.height) as? String,
            let photoObject = aDecoder.decodeObject(forKey: Keys.photo) as? String,
            let emailObject = aDecoder.decodeObject(forKey: Keys.email) as? String,
            let passwordObject = aDecoder.decodeObject(forKey: Keys.password) as? String {
            
            _name = nameObject
            _height = heightObject
            _photo = photoObject
            _email = emailObject
            _password = passwordObject
        }
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(_name, forKey: Keys.name)
        aCoder.encode(_height, forKey: Keys.height)
        aCoder.encode(_photo, forKey: Keys.photo)
        aCoder.encode(_email, forKey: Keys.email)
        aCoder.encode(_password, forKey: Keys.password)
    }
    
    var name: String {
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }
    
    var height: String {
        get {
            return _height
        }
        set {
            _height = newValue
        }
    }
    
    var photo: String {
        get {
            return _photo
        }
        set {
            _photo = newValue
        }
    }
    
    var email: String {
        get {
            return _email
        }
        set {
            _email = newValue
        }
    }
    
    var password: String {
        get {
            return _password
        }
        set {
            _password = newValue
        }
    }
}
