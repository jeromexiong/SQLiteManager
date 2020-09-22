//
//  TestModel.swift
//  SQLiteManager_Example
//
//  Created by Jerome Xiong on 2020/9/22.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import HandyJSON
import SQLiteManager

class TestModel1: NSObject, SQLiteProtocol, HandyJSON {
    static var tableName: String {
        return "TestModel1"
    }
    
    required init(_ dict: [String : Any]) {
        
    }
    
    required override init() {
        super.init()
    }
}
struct TestModel: SQLiteProtocol, HandyJSON {
    
    var name: String = ""
    var age: Int = 0
    var uuid: String?
    var ignore: String = ""
    var weight: Float = 0
    var newAge: Int = 0
    var create_time: Int = 0
    
    var optionalString : String?
    var optionalInt : Int?

    var optionalisTest:Bool?
    var optionalDouble:Double?
    var optionalFloat:Float?
    
    static var tableName: String {
        return "TestModel"
    }
    init(_ dict: [String : Any]) {}
    init() {}
    
    var ignoreKeys: [String]? {
        return ["ignore"]
    }
    
    var uniqueKeys: [String]? {
        return ["uuid"]
    }
}
