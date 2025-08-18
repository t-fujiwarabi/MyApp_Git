//
//  MemoDataModel.swift
//  MyColorMemoApp
//
//  Created by 藤原崇志 on 2024/03/31.
//

import Foundation
import RealmSwift

class MemoDataModel: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var text: String = ""
    @Persisted var recordDate: Date = Date()
}
