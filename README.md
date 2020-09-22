# SQLiteManager
对SQLite.swift的封装，使用swift的反射原理，Model直接存储.获取. 无需再转换,增删改查. 脱离sql语句,不需要添加相关的绑定操作，直接完成转换。

### 使用方法
* 1. 导入
>A. Pod导入（推荐）
```
  pod 'SQLiteManager'
```

>B. 引入SQLiteManager目录下的文件文件:
```
SQLMirrorModel.swift
SQLitePropModel.swift
SQLiteManager.swift
```

- 2. 使用

创建的模型实现`SQLiteProtocol`协议即可
```
class TestModel: NSObject, SQLiteProtocol {}
struct TestModel: SQLiteProtocol {}
```

```
switch sender.tag {
    case 0:
    SQLiteManager.default.insert(testModel)
    case 1:
    SQLiteManager.default.delete(testModel)
    case 2:
    testModel.name = "Ree"
    testModel.create_time = Int(Date().timeIntervalSince1970)
    SQLiteManager.default.update(testModel)
    case 3:
    let arr = SQLiteManager.default.select(TestModel.tableName)
    let models = arr.map({ TestModel.deserialize(from: $0) })
    print("查询到数据: \(models)")
    case 4:
    SQLiteManager.default.drop(TestModel.tableName)
    default:
    break
}
```

