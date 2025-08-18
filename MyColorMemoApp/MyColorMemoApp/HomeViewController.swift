import Foundation
import UIKit // UIに関するクラスが格納されたモジュール
import RealmSwift

// HomeViewControllerにUIViewControllerを「クラス継承」する
class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var memoDataList: [MemoDataModel] = []
    
    override func viewDidLoad() {
        // このクラスの画面が表示される際に呼び出されるメソッド
        // 画面の表示・非表示に応じて実行されるメソッドを「ライフサイクルメソッド」と呼ぶ

        //UITableViewの罫線を表示
        tableView.separatorColor = .lightGray
        tableView.separatorStyle = .singleLine
        if #available(iOS 15.0, *) {
            tableView.fillerRowHeight = 50
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        setNavigationBarButton()
        setLeftNavigationBarButton()
        setThemeColor(type: .default)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMemoData()
        tableView.reloadData()
    }
    
    func setMemoData() {
        let realm = try! Realm()
        let result = realm.objects(MemoDataModel.self)
        memoDataList = Array(result)
    }
    
    @objc func tapAddButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let memoDetailViewController = storyboard.instantiateViewController(identifier: "MemoDetailViewController") as! MemoDetailViewController
        navigationController?.pushViewController(memoDetailViewController, animated: true)
    }
    
    func setNavigationBarButton() {
        let buttonActionSelector: Selector = #selector(tapAddButton)
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: buttonActionSelector)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setLeftNavigationBarButton() {
        let buttonActionSelector: Selector = #selector(didTapColorSettingButton)
        let leftButtonImage = UIImage(named: "colorSettingIcon")
        let leftButton = UIBarButtonItem(image: leftButtonImage, style: .plain, target: self, action: buttonActionSelector)
        navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func didTapColorSettingButton() {
        let defaultAction = UIAlertAction(title: "デフォルト", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .default)
        })
        let orangeAction = UIAlertAction(title: "オレンジ", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .orange)
        })
        let redAction = UIAlertAction(title: "レッド", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .red)
        })
        let blueAction = UIAlertAction(title: "ブルー", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .blue)
        })
        let pinkAction = UIAlertAction(title: "ピンク", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .pink)
        })
        let greenAction = UIAlertAction(title: "グリーン", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .green)
        })
        let purpleAction = UIAlertAction(title: "パープル", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .purple)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let alert = UIAlertController(title: "テーマカラーを選択してください", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(defaultAction)
        alert.addAction(orangeAction)
        alert.addAction(redAction)
        alert.addAction(cancelAction)
        alert.addAction(blueAction)
        alert.addAction(pinkAction)
        alert.addAction(greenAction)
        alert.addAction(purpleAction)
        
        present(alert, animated: true)
    }
    
    func setThemeColor(type: MyColorType) {
        let isDefault = type == .default
        let tintColor: UIColor = isDefault ? .black : .white
        navigationController?.navigationBar.tintColor = tintColor
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = type.color
        // Dictionary型→[Key: Value]
        appearance.titleTextAttributes = [.foregroundColor: tintColor]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoDataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        // indexPath.row→UITableViewに表示されるCellの(0から始まる)通し番号が順番に渡される
        let memoDataModel: MemoDataModel = memoDataList[indexPath.row]
        cell.textLabel?.text = memoDataModel.text
        cell.detailTextLabel?.text = "(memoDataModel.recordDate)"
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let memoDetailViewController = storyboard.instantiateViewController(identifier: "MemoDetailViewController") as! MemoDetailViewController
        let memoData = memoDataList[indexPath.row]
        memoDetailViewController.configure(memo: memoData)
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(memoDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let targetMemo = memoDataList[indexPath.row]
        let realm = try! Realm()
        try! realm.write {
            realm.delete(targetMemo)
        }
        memoDataList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
