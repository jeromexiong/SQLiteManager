//
//  SQLiteManager.swift
//
//  Created by Jerome Xiong on 2020/9/22.
//
//

import SQLite

public class SQLiteManager {
    public static let `default` = SQLiteManager()
    public private(set) lazy var databasePath: String = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return "\(path)/db.sqlite3"
    }()
    public private(set) var db: Connection!
    public var enableLog = true
    
    private init() {
        db = try! Connection(databasePath)
        printLog(databasePath)
    }
    
    /// 插入行
    /// - Parameter model: 行模型
    public func insert<E>(_ model: E) where E : SQLiteProtocol {
        let mirrorModel = SQLMirrorModel.operateByMirror(object: model)
        create(mirrorModel)
        
        let (isExists, filter) = exists(model)
        let tableName = E.tableName
        
        var updates = [String]()
        var inserts = [String: String]()
        for prop in mirrorModel.props {
            if isExists {
                addColumn(tableName, prop: prop)
                updates.append("\(prop.key) = '\(prop.value)'")
            }else {
                inserts[prop.key] = "'\(prop.value)'"
            }
        }
        
        var sql: String
        if isExists {
            sql = "UPDATE \(tableName) SET \(updates.joined(separator: ", "))\(filter)"
        }else {
            sql = "INSERT INTO \(tableName) (\(inserts.keys.joined(separator: ", "))) VALUES (\(inserts.values.joined(separator: ", ")))"
        }
        
        printLog(sql)
        prepare(sql)
    }
    
    /// 更新行
    /// - Parameter model: 模型数据
    public func update<E>(_ model: E) where E : SQLiteProtocol {
        insert(model)
    }
    
    /// 查询行，返回模型
    /// - Parameter filter: 筛选条件
    /// - Returns: 查询结果
    public func select<E>(_ filter: [String: Any] = [:]) -> [E] where E : SQLiteProtocol {
        let rows = select(E.tableName, filter: filter)
        return rows.map({ E($0) })
    }
    
    /// 查询行，直接返回
    /// - Parameters:
    ///   - tableName: 表名
    ///   - filter: 筛选条件
    /// - Returns: 查询结果
    public func select(_ tableName: String, filter: [String: Any] = [:]) -> [[String: Any]] {
        if !exists(tableName) {
            return []
        }
        var wheres = [String]()
        for (key, value) in filter {
            wheres.append("\(key) = '\(value)'")
        }
        let str = wheres.joined(separator: " AND ")
        let filter = str.count > 0 ? " WHERE \(str)" : str
        let sql = "SELECT * FROM \(tableName)\(filter)"
        
        printLog(sql)
        let rows = prepare(sql)
        return rows
    }
    
    /// 以模型方式删除行数据
    /// - Parameter model: 需要删除的模型
    public func delete<E>(_ model: E) where E : SQLiteProtocol {
        let sql = "DELETE FROM \(E.tableName)\(exists(model))"
        prepare(sql)
    }
    
    /// 直接删除行数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - filter: 筛选条件
    public func delete(_ tableName: String, filter: [String: Any]) {
        var wheres = [String]()
        for (key, value) in filter {
            wheres.append("\(key) = '\(value)'")
        }
        let str = wheres.joined(separator: " AND ")
        let filter = str.count > 0 ? " WHERE \(str)" : str
        let sql = "DELETE FROM \(tableName)\(filter)"
        
        printLog(sql)
        prepare(sql)
    }
    
    /// 删除数据表
    /// - Parameter tableName:表名
    public func drop(_ tableName: String) {
        let sql = "DROP TABLE \(tableName)"
        printLog(sql)
        prepare(sql)
    }
    
    /// 执行数据库语句
    @discardableResult
    public func prepare(_ sql: String) -> [[String: Any]] {
        var elements: [[String: Any]] = []
        do {
            let result = try db.prepare(sql)
            for row in result {
                var record: [String: Any] = [:]
                for (idx, column) in result.columnNames.enumerated() {
                    record[column] = row[idx]
                }
                elements.append(record)
            }
            return elements
        } catch {
            printLog(error)
            return []
        }
    }
}
private extension SQLiteManager {
    func printLog(_ items: Any..., file: String = #file, method: String = #function, line: Int = #line) {
        #if DEBUG
        if enableLog {
            print("\((file as NSString).lastPathComponent)[\(line)], \(method): ", items)
        }
        #endif
    }
    /// 创建数据表
    /// - Parameter model: 反射模型
    @discardableResult
    private func create(_ model: SQLMirrorModel) -> Bool {
        if exists(model.tableName) {
            return true
        }
        
        var sql = "CREATE TABLE IF NOT EXISTS \(model.tableName) "
        let columns = model.props.map({ $0.column }).joined(separator: ", ")
        sql += "(\(columns))"
        
        do {
            try db.run(sql)
        } catch {
            printLog(error)
            return false
        }
        return true
    }
    
    /// 是否存在数据表
    /// - Parameter tableName: 表名
    /// - Returns: 是否存在
    private func exists(_ tableName: String) -> Bool {
        let exists = try? db.scalar(Table(tableName).exists)
        let isExist = exists != nil
        printLog("数据库表: \(isExist ? "存在" : "不存在")")
        return isExist
    }
    
    /// 是否存在该行数据
    /// - Parameter object: 行数据模型
    /// - Returns: (是否存在， 筛选条件)
    private func exists<E: SQLiteProtocol>(_ object: E) -> (exists: Bool, filter: String) {
        let mirrorModel = SQLMirrorModel.operateByMirror(object: object)
        var wheres = [String]()
        if let prop = mirrorModel.props.filter({ $0.primary }).first {
            wheres.append("\(prop.key) = '\(prop.value)'")
        }else if let keys = object.uniqueKeys, keys.count > 0 {
            for key in keys {
                for prop in mirrorModel.props {
                    if prop.key != key {
                        continue
                    }
                    wheres.append("\(prop.key) = '\(prop.value)'")
                }
            }
        }else {
            for prop in mirrorModel.props {
                wheres.append("\(prop.key) = '\(prop.value)'")
            }
        }
        let str = wheres.joined(separator: " AND ")
        let filter = str.count > 0 ? " WHERE \(str)" : str
        let sql = "SELECT * FROM \(E.tableName)\(filter)"
        return (prepare(sql).count == 1, filter)
    }
    
    /// 如果字段不存在，则创建
    /// - Parameters:
    ///   - tableName: 字段表名
    ///   - prop: 字段属性
    private func addColumn(_ tableName: String, prop: SQLitePropModel) {
        let columns = prepare("PRAGMA table_info(\(tableName))").map({ $0["name"] as! String })
        let exist = columns.contains(prop.key)
        if !exist {
            prepare("ALTER TABLE \(tableName) ADD \(prop.column)")
        }
    }
}
