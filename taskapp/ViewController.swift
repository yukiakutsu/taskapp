//
//  ViewController.swift
//  taskapp
//
//  Created by Classtream on 2018/04/12.
//  Copyright © 2018年 yuki.akutsu. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    // 検索結果を入れるリスト
    var taskSearch : Results<Task>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        // サーチバーに何も入力されていなくてもReturnボタンを押せるようにする
        searchBar.enablesReturnKeyAutomatically = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if taskSearch != nil{
            return taskSearch!.count
        }
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // 再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task: Task
        
        // Cellに値を設定する
        // 文字列検索しているか
        if taskSearch != nil {
            task = taskSearch![indexPath.row]
        }else{
           task = taskArray[indexPath.row] // データを取得
        }
        
        cell.textLabel?.text = task.title   // キーtitleから値を取得し、Cellのtitleに入れる
        
        let formatter = DateFormatter()     // 日付をフォーマットするための宣言
        formatter.dateFormat = "yyyy-MM-dd HH:mm"   //日付表示形式を決める
        
        let dateString:String = formatter.string(from: task.date)   // キーdateから値を取得し、それをフォーマットする
        cell.detailTextLabel?.text = dateString // Cellのtextに値を代入
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            
            let task : Task
            // 文字列検索しているか
            if taskSearch == nil{
                // 削除されたタスクを取得する
                task = self.taskArray[indexPath.row]
            }else{
                // 削除されたタスクを取得する
                task = self.taskSearch![indexPath.row]
            }
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                // データベースから削除
                self.realm.delete(task)
                // テーブルビューからアニメーションさせながら削除
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
                for request in requests{
                    print("/--------------")
                    print(request)
                    print("--------------/")
                }
            }
        }
    }
    
    // 検索バーの検索ボタンをタッチした時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        searchBar.endEditing(true)
        
        // 何か文字列が入力されていれば
        if searchBar.text != ""{
            // 検索結果一覧を取得
            taskSearch = try! Realm().objects(Task.self).filter("category like %@", searchBar.text!).sorted(byKeyPath: "date", ascending: false)
        }else{
            taskSearch = nil
        }
        // テーブルビュー再読み込み
        tableView.reloadData()
    }
    // segue で画面遷移すると呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        // セルを選択した
        if segue.identifier == "cellSegue"{
            // 選ばれたセルのタスク内容を取得
            let indexPath = self.tableView.indexPathForSelectedRow
            
            if taskSearch == nil{
                inputViewController.task = taskArray[indexPath!.row]
            }else{
                inputViewController.task = taskSearch?[indexPath!.row]
            }
        // 追加を選択した
        } else {
            let task = Task()
            // 今日の日付をタスクに入れる
            task.date = Date()
            
            // タスクのIDを決める
            let taskArray = realm.objects(Task.self)
            if taskArray.count != 0{
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
}

