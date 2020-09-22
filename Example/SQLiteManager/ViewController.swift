//
//  ViewController.swift
//  SQLiteManager
//
//  Created by 1540428743@qq.com on 09/22/2020.
//  Copyright (c) 2020 1540428743@qq.com. All rights reserved.
//

import UIKit
import SQLiteManager

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    lazy var testModel: TestModel = {
        var testModel =  TestModel()
        testModel.age       = 18
        testModel.name      = "Tony"
        testModel.ignore    = "ignore"
        testModel.weight    = 140
        testModel.newAge    = 19
        testModel.uuid      = "testuuid1"
        testModel.create_time = Int(Date().timeIntervalSince1970)
        
        testModel.optionalInt = 1
        testModel.optionalFloat = 2.0
        testModel.optionalDouble = 3.0
        testModel.optionalisTest = true
        testModel.optionalString = "optionalString"
        
        return testModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func action(_ sender: UIButton) {
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
    }
    
}

