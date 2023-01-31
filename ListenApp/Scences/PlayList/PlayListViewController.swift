//
//  PlayListViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit
import SnapKit
import AVFoundation

class PlayListViewController : UIViewController {
    var playList : [DocumentItem] = []
    
    let playerController = PlayerController.playerController
    let CoreAudioData = CoreDataFunc.shared
    
    var filemanager = MyFileManager()
    var webUploader = MyWebUploader()
    
    var url : URL!
    var location : String!
    
    private lazy var header = PlayListHeaderView(frame: .zero, headerTitle: url.lastPathComponent)
    
    private lazy var renameButton = UIButton()
    private lazy var moveButton = UIButton()
    private lazy var deleteButton = UIButton()
    
    private lazy var editingFooter : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.tintColor = .label
        
        return stackView
    }()
    
    private lazy var nowPlayingView = NowPlayingView() // nowPlayingView를 UIButton으로 하려고 했지만, 버튼 크기 유지하면서 내부 요소들을 정렬할 수 가 없어 UIView에 UITapGestureRecognizer를 사용해 구현함
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
//        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PlayListTableViewCell.self, forCellReuseIdentifier: "PlayListTableViewCell")
        
        return tableView
    }()
    
    
    var sortOrder = ComparisonResult.orderedAscending
    var selectedSort = SelectedSort.name
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        setFuncInHeaderBtn()
        addActionToNowPlayingView()
//        CoreAudioData.resetAllRecords()
        setPlayList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPlayListVC()
    }
    
    // 맨 처음 viewload할때 playlist값 set
    func setPlayList() {
        print("set")
        playList = sortPlayList(targetList: filemanager.getAudioFileListFromFolder(location: location))
        tableView.reloadData()
    }
    
    // Document에서 파일 가져온 후 기존 playList랑 다르다면 playList 및 audioList 업데이트
    func refreshPlayListVC() {
        print("refresh")
        var newPlayList = filemanager.getAudioFileListFromFolder(location: location)
        newPlayList = sortPlayList(targetList: newPlayList)
        
        if playList != newPlayList {
            print("playList has some changed")
            playList = newPlayList
            CoreAudioData.synchronizeAudioListAndPlayList()
            tableView.reloadData()
        }
    }
    
    // when NowPlayeringView was tapped, push PlayerVC to navigation
    private func addActionToNowPlayingView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PushPlayerVC(_:)))
        nowPlayingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func PushPlayerVC(_ sender: UITapGestureRecognizer) {
        if playerController.audio == nil { return }
        
        let playerVC = NewPlayerVIewController()
        navigationController?.pushViewController(playerVC, animated: true)
    }

    
}


// TableView
extension PlayListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListTableViewCell", for: indexPath) as? PlayListTableViewCell else {return UITableViewCell()}
        
        cell.setLayout(item: playList[indexPath.row])
        cell.tag = indexPath.row            
        
        return cell
        
    }
    
    func tableView(_ : UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            changeEditingFooterButtonStatus()
            return
        }
        
        let item = playList[indexPath.row]
        
        if item.type == .file {
//            if playerController.audio?.title != item.title {
//                guard let idx = CoreAudioData.audioList.firstIndex(where: {$0.title == item.title && $0.location == item.location }) else {
//                    print("This audio is not exist in CoreData")
//                    return
//                }
//
//                playerController.isNewAudio = true
//                playerController.audio = CoreAudioData.audioList[idx]
//                playerController.url = item.url
//                playerController.configurePlayer(url : item.url)
//            }
//
//            let playerVC = NewPlayerVIewController()
//            navigationController?.pushViewController(playerVC, animated: true)
        }
        else {
            let playListVC = PlayListViewController()
            playListVC.url = item.url
            playListVC.location = item.location
            navigationController?.pushViewController(playListVC, animated: true)
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        changeEditingFooterButtonStatus()
    }

}

// editingFooter button functions
extension PlayListViewController {
    func setEditingFooterButton() {
        let repeatImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .light), scale: .default)
        
        renameButton.setImage(UIImage(systemName: "a.square", withConfiguration: repeatImageConfig), for: .normal)
        moveButton.setImage(UIImage(systemName: "folder", withConfiguration: repeatImageConfig), for: .normal)
        deleteButton.setImage(UIImage(systemName: "trash", withConfiguration: repeatImageConfig), for: .normal)
        
        renameButton.addTarget(self, action: #selector(tapRenameButton), for: .touchUpInside)
        moveButton.addTarget(self, action: #selector(tapMoveButton), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(tapDeleteButton), for: .touchUpInside)
        
        [renameButton, moveButton, deleteButton].forEach{
            editingFooter.addArrangedSubview($0)
        }
    }
    
    @objc func tapRenameButton(){
        let indexPath = tableView.indexPathForSelectedRow ?? IndexPath()
        
        let customAlerVC = CustomAlertViewController()
        
        customAlerVC.alertCategory = .rename
        customAlerVC.defaultName = self.playList[indexPath.row].title

        customAlerVC.delegate = self
        
        customAlerVC.modalPresentationStyle = .overFullScreen
        customAlerVC.modalTransitionStyle = .crossDissolve
        self.present(customAlerVC, animated: true, completion: nil)
    }
    
    @objc func tapMoveButton(){
        let PlayListMoveVC = PlayListMoveViewController()
        PlayListMoveVC.url = filemanager.documentURL
        PlayListMoveVC.location = ""
        
        let selectedIndexPath = tableView.indexPathsForSelectedRows ?? []
        var cannotMoveUrls : [URL] = [self.url]
        var selectedItems : [DocumentItem] = []
        for indexPath in selectedIndexPath {
            cannotMoveUrls.append(self.playList[indexPath.row].url)
            selectedItems.append(self.playList[indexPath.row])
        }
        PlayListMoveVC.cannotMoveUrls = cannotMoveUrls
        PlayListMoveVC.selectedItems = selectedItems
        PlayListMoveVC.delegate = self
        
        let navigationContoller = UINavigationController(rootViewController: PlayListMoveVC)
        
        self.present(navigationContoller, animated: true)
    }
    
    @objc func tapDeleteButton(){
        let selectedIndexPath = tableView.indexPathsForSelectedRows ?? []
        var selectedItems : [DocumentItem] = []
        for indexPath in selectedIndexPath {
            selectedItems.append(self.playList[indexPath.row])
        }
        
        filemanager.deleteFilesInDocument(items: selectedItems)
        CoreAudioData.synchronizeAudioListAndPlayList()
        setPlayList()
        
        changeTableViewEditingAndLayout()
    }
    
    func changeEditingFooterButtonStatus() {
        let selectedIndexPath = tableView.indexPathsForSelectedRows ?? []
        
        switch selectedIndexPath.count {
        case 0:
            [renameButton, moveButton, deleteButton].forEach{
                $0.isEnabled = false
            }
        case 1:
            [renameButton, moveButton, deleteButton].forEach{
                $0.isEnabled = true
            }
        default:
            renameButton.isEnabled = false
            [moveButton, deleteButton].forEach{
                $0.isEnabled = true
            }
        }
        
    }
    
}


// editing multiselection
extension PlayListViewController {
    
    @objc func changeTableViewEditingAndLayout(){
        self.tableView.isEditing = !self.tableView.isEditing
        self.tableView.isEditing == true ? setLayoutForBeginEditing() : setLayoutForEndEditing()
    }
    
    func setLayoutForBeginEditing() {
        self.header.setBtnHiddenForBeginEditing()
        
        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.isHidden = true
        
        self.editingFooter.isHidden = false
        self.nowPlayingView.isHidden = true
    }
    
    func setLayoutForEndEditing() {
        self.header.setBtnHiddenForEndEditing()
        
        tabBarController?.tabBar.isHidden = false
        
        self.editingFooter.isHidden = true
        self.nowPlayingView.isHidden = false
        
    }
}


// header btn functions
extension PlayListViewController {
    
    @objc func tapBackBtn() {
        if tableView.isEditing == true { return }
        navigationController?.popViewController(animated: true)
    }
    
    private func setFuncInHeaderBtn(){
        header.backBtn.addTarget(self, action: #selector(tapBackBtn), for: .touchUpInside)
        
        header.completeBtn.addTarget(self, action: #selector(changeTableViewEditingAndLayout), for: .touchUpInside)
        
        header.editBtn.menu = createMenus(selectedSort: self.selectedSort, sortOrder: self.sortOrder)
        header.editBtn.showsMenuAsPrimaryAction = true
        
    }
    
    // menu 목록들: adminDocumentMenu, newFileMenu, sortingMenu
    func createMenus(selectedSort : SelectedSort, sortOrder : ComparisonResult) -> UIMenu {
        let select = UIAction(title: "선택", image: UIImage(systemName: "checkmark.circle"), handler: { _ in
            self.tableView.allowsMultipleSelectionDuringEditing = true
            
            //PlayList menu's "selection uiaction" has 'perform(afterdelay)' for removing [ASSERT] about hiding editBtn when it's menu is working
            self.perform(#selector(self.changeTableViewEditingAndLayout), with: nil, afterDelay: 0.1)
            self.changeEditingFooterButtonStatus()
        })
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
        
        let wifi = UIAction(title: "와이파이 파일 추가", image: UIImage(systemName: "wifi"), handler: { _ in
            let customAlerVC = CustomAlertViewController()
            customAlerVC.alertCategory = .addWifiFile
            
            customAlerVC.IPaddress = self.webUploader.initWebUploader()
            customAlerVC.delegate = self
            
            customAlerVC.modalPresentationStyle = .overFullScreen
            customAlerVC.modalTransitionStyle = .crossDissolve
            self.present(customAlerVC, animated: true, completion: nil)
            
            
        })
        let cable = UIAction(title: "USB 파일 추가", image: UIImage(systemName: "cable.connector.horizontal"), handler: { _ in
            let customAlerVC = CustomAlertViewController()
            customAlerVC.alertCategory = .addCableFile
            
//            customAlerVC.delegate = self
            
            customAlerVC.modalPresentationStyle = .overFullScreen
            customAlerVC.modalTransitionStyle = .crossDissolve
            self.present(customAlerVC, animated: true, completion: nil)
        })
        
        let adminDocumentMenu = UIMenu(title: "", options: .displayInline, children: [select, newFolder])
        let newFileMenu = UIMenu(title: "", options: .displayInline, children: [wifi, cable])
        let sortingMenu = createSortMenu(selectedSort : self.selectedSort, sortOrder : self.sortOrder)
        
        return UIMenu(title: "", options: .displayInline, children: [adminDocumentMenu, newFileMenu, sortingMenu])
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
        
        self.playList = sortPlayList(targetList : self.playList)
        self.tableView.reloadData()
    }
    
    func sortPlayList(targetList : [DocumentItem]) -> [DocumentItem] {
        let isAscending = self.sortOrder == .orderedAscending ? true : false
        var list = targetList
        
        switch self.selectedSort {
        case .name:
            list.sort{
                return ($0.title < $1.title) == isAscending
            }
        case .category:
            list.sort{
                return ($0.type < $1.type) == isAscending
            }
        case .date:
            list.sort{
                return ($0.creationDate < $1.creationDate) == isAscending
            }
        case .size:
            list.sort{
                return ($0.size < $1.size) == isAscending
            }
        }
        return list
    
    }
}


extension PlayListViewController : CustomAlertDelegate {
    func confirmRename(newTitle : String) {
        let indexPath = tableView.indexPathForSelectedRow ?? IndexPath()
        let item = self.playList[indexPath.row]
        
//        CoreAudioData.updateTitleOfSelectedDocumentItem(newtitle: newTitle, item: item)
        filemanager.renameFileInDocument(item : item, newTitle: newTitle, url: url)
        changeTableViewEditingAndLayout()
        setPlayList()
    }
    
    func confirmNewFolder(text: String) {
        self.filemanager.createForderInDocument(title: text, documentsURL: self.url)
        setPlayList()
    }
    
    func confirmAddWifiFile() {
        webUploader.stopWebUploader()
        CoreAudioData.synchronizeAudioListAndPlayList()
        setPlayList()
    }
    
    func confirmAddCableFile() {
        CoreAudioData.synchronizeAudioListAndPlayList()
        setPlayList()
    }
    
}


extension PlayListViewController : AfterMoveActionProtocol {
    func afterMoveAction(text : String) {
        self.changeTableViewEditingAndLayout()
        self.refreshPlayListVC()
    }
}


// layout Setting
extension PlayListViewController {
    
    private func setLayout() {
        setEditingFooterButton()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        [header, tableView, nowPlayingView, editingFooter].forEach{
            view.addSubview($0)
        }
        
        editingFooter.isHidden = true
        
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

        nowPlayingView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.width.equalTo(170)
            $0.height.equalTo(50)
            $0.bottom.equalTo(tableView).inset(30)
        }

        editingFooter.snp.makeConstraints{
            $0.top.equalTo(tableView.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.snp.width).multipliedBy(1)
        }
        
        
    }
}
