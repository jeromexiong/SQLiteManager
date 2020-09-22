//
//  SQLMirrorModel.swift
//  
//  Created by Jerome Xiong on 2020/9/22.
//

import Foundation

/// 反射保存属性的model
public struct SQLMirrorModel {
    public var tableName: String
    public var props: [SQLitePropModel] = []
    public var primaryKey: String?
    
    public init(_ tableName: String, props: [SQLitePropModel], primaryKey: String?) {
        var name = tableName.trimmingCharacters(in: .whitespacesAndNewlines)
        name = name.replacingOccurrences(of: " ", with: "")
        let pred = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z_\\x7f-\\xff][a-zA-Z0-9_\\x7f-\\xff]*$")
        if !pred.evaluate(with: name) {
            assert(true, "表名校验不通过")
        }
        
        self.tableName = tableName
        self.props = props
        self.primaryKey = primaryKey
    }
    
    public static func operateByMirror(object: SQLiteProtocol) -> SQLMirrorModel {
        let mirror = Mirror(reflecting: object)
        var props = [SQLitePropModel]()
        for case let (key?, value) in mirror.children {
            let model = SQLitePropModel(key, value: value, primary: object.primaryKey == key)
            guard object.ignoreKeys?.contains(key) == false else {
                continue
            }
            props.append(model)
        }
        
        if mirror.displayStyle != .class || mirror.displayStyle != .struct {
            assert(true, "operateByMirror:不支持的类型")
        }
        return SQLMirrorModel(type(of: object).tableName, props: props, primaryKey: object.primaryKey)
    }
}
