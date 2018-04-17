//
//  Task.swift
//  taskapp
//
//  Created by Classtream on 2018/04/13.
//  Copyright © 2018年 yuki.akutsu. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理者用　ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // 内容
    @objc dynamic var contents = ""
    
    // 日時
    @objc dynamic var date = Date()
    
    // カテゴリ
    @objc dynamic var category : String = ""
    /**
     idをプライマリーキーとして設定
    */
    override static func primaryKey() -> String?{
        return "id"
    }
}
