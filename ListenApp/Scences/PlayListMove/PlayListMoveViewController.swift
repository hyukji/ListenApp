//
//  PlayListMoveViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/25.
//

import UIKit

protocol AfterMoveActionProtocol : AnyObject {
    func afterMoveAction(text : String)
}


class PlayListMoveViewController : UIViewController {
    var playList : [DocumentItem] = []
    var filemanager = MyFileManager()
    var selectedURLs : [URL] = []
    var url : URL!
    
    var sortOrder = ComparisonResult.orderedAscending
    var selectedSort = SelectedSort.category
    
    weak var delegate : AfterMoveActionProtocol?
    
    private lazy var header = PlayListMoveHeader(frame: .zero, headerTitle: url.deletingPathExtension().lastPathComponent)
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
//        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PlayListMoveTableViewCell.self, forCellReuseIdentifier: "PlayListMoveTableViewCell")
        
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setFuncInHeaderBtn()
        playList = filemanager.getAudioFileListFromDocument(folderurl : url)
        sortPlayList()
        checkCanMove()
    }
    
    func checkCanMove() {
        if selectedURLs.contains(url) {
            header.moveBtn.isEnabled = false
        }
    }
    
    func refreshPlayListVC() {
        playList = filemanager.getAudioFileListFromDocument(folderurl : url)
        sortPlayList()
        tableView.reloadData()
    }


}


// TableView
extension PlayListMoveViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListMoveTableViewCell", for: indexPath) as? PlayListMoveTableViewCell else {return UITableViewCell()}
        
        let item = playList[indexPath.row]
        if selectedURLs.contains(item.url) {
            cell.isCanMoveFolder = false
        }
        cell.setLayout(item: item)
    
        return cell
        
    }
    
    func tableView(_ : UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = playList[indexPath.row]
        if item.type == .folder {
            let playListMoveVC = PlayListMoveViewController()
            playListMoveVC.delegate = self.delegate
            playListMoveVC.url = item.url
            playListMoveVC.selectedURLs = selectedURLs
            
            navigationController?.pushViewController(playListMoveVC, animated: true)
        }
    }
    
    // 위 아래 드래그 시에 sectionheader 색상이 회색으로 바뀌는 것을 막고자 SectionHeaderView를 따로 삽입
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView() //set these values as necessary
        view.backgroundColor = .systemBackground
        view.frame.size = CGSize(width: tableView.frame.width, height: 100)

        let label = UILabel()
        label.text = "총 \(playList.count)개 파일"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        
        view.addSubview(label)
        
        label.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(2)
        }

        return view
    }

}

// header btn functions
extension PlayListMoveViewController {
    
    @objc func tapBackBtn() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tapMoveBtn() {
        filemanager.moveFileInDocument(selectedURLs: selectedURLs, newUrl: url)
        self.delegate?.afterMoveAction(text : url.path)
        
        self.dismiss(animated: true)
    }
    
    private func setFuncInHeaderBtn(){
        header.backBtn.addTarget(self, action: #selector(tapBackBtn), for: .touchUpInside)
        
        header.moveBtn.addTarget(self, action: #selector(tapMoveBtn), for: .touchUpInside)
        
        header.editBtn.menu = createMenus(selectedSort: self.selectedSort, sortOrder: self.sortOrder)
        header.editBtn.showsMenuAsPrimaryAction = true
    }
    
    // menu 목록들: adminDocumentMenu, newFileMenu, sortingMenu
    func createMenus(selectedSort : SelectedSort, sortOrder : ComparisonResult) -> UIMenu {
        let newFolder = UIAction(title: "새로운 폴더", image: UIImage(systemName: "folder.badge.plus"), handler: {_ in
            let customAlerVC = CustomAlertViewController()
            
            customAlerVC.alertCategory = .newFolder
            
            // 새로운 폴더 라는 이름을 가진 파일 or 폴더 가 있다면 1을 추가
            var defaultName = "새로운 폴더"
            while self.playList.contains(where: {$0.title == defaultName}) {
                defaultName += "1"
            }
            customAlerVC.defaultName = defaultName

            customAlerVC.delegate = self
            
            customAlerVC.modalPresentationStyle = .overFullScreen
            customAlerVC.modalTransitionStyle = .crossDissolve
            self.present(customAlerVC, animated: true, completion: nil)
        })
        
        let adminDocumentMenu = UIMenu(title: "", options: .displayInline, children: [newFolder])
        let sortingMenu = createSortMenu(selectedSort : self.selectedSort, sortOrder : self.sortOrder)
        
        return UIMenu(title: "", options: .displayInline, children: [adminDocumentMenu, sortingMenu])
    }
    
    func createSortMenu(selectedSort : SelectedSort, sortOrder : ComparisonResult) -> UIMenu {
        let selectedOrderImg = sortOrder == .orderedAscending ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
        
        var name = UIAction(title: "이름", image: nil, state: .off, handler: { _ in
            self.tapSortMenu(selectedSort : .name)})
        var category = UIAction(title: "종류", image: nil, state: .off, handler: { _ in
            self.tapSortMenu(selectedSort : .category)})
        var date = UIAction(title: "날짜", image: nil, state: .off, handler: { _ in self.tapSortMenu(selectedSort : .date)})
        var size = UIAction(title: "크기", image: nil, state: .off, handler: { _ in self.tapSortMenu(selectedSort : .size)})
            
        switch selectedSort {
        case .name:
            name = UIAction(title: "이름", image: selectedOrderImg, state: .on, handler: { _ in self.tapSortMenu(selectedSort : .name)})
        case .category:
            category = UIAction(title: "종류", image: selectedOrderImg, state: .on, handler: { _ in self.tapSortMenu(selectedSort : .category)})
        case .date:
            date = UIAction(title: "날짜", image: selectedOrderImg, state: .on, handler: { _ in self.tapSortMenu(selectedSort : .date)})
        case .size:
            size = UIAction(title: "크기", image: selectedOrderImg, state: .on, handler: { _ in self.tapSortMenu(selectedSort : .size)})
        }
                
        return UIMenu(title: "", options: .displayInline, children: [name, category, date, size])
    }
    
    func tapSortMenu(selectedSort : SelectedSort) {
        if self.selectedSort == selectedSort {
            self.sortOrder = self.sortOrder == .orderedAscending ? .orderedDescending : .orderedAscending
        }
        self.selectedSort = selectedSort
        header.editBtn.menu = self.createMenus(selectedSort: self.selectedSort, sortOrder: self.sortOrder)
        
        sortPlayList()
        self.tableView.reloadData()
    }
    
    func sortPlayList() {
        let isAscending = self.sortOrder == .orderedAscending ? true : false
        
        switch self.selectedSort {
        case .name:
            self.playList.sort{
                return ($0.title < $1.title) == isAscending
            }
        case .category:
            self.playList.sort{
                return ($0.type < $1.type) == isAscending
            }
        case .date:
            self.playList.sort{
                return ($0.creationDate < $1.creationDate) == isAscending
            }
        case .size:
            self.playList.sort{
                return ($0.size < $1.size) == isAscending
            }
        }
    
    }
}


extension PlayListMoveViewController : CustomAlertDelegate {
    func confirmRename(text: String) {}
    func confirmAddWifiFile() {}
    
    func confirmNewFolder(text: String) {
        self.filemanager.createForderInDocument(title: text, documentsURL: self.url)
        refreshPlayListVC()
    }
}


// layout Setting
extension PlayListMoveViewController {
    private func setLayout() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        view.backgroundColor = .systemBackground
        
        [header, tableView].forEach{
            view.addSubview($0)
        }
        
        header.snp.makeConstraints{
            $0.leading.trailing.equalTo(view)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }

        tableView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(header.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
}

