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
    var filemanager = MyFileManager()
    var url : URL!
    
    var sortOrder = ComparisonResult.orderedAscending
    var selectedSort = SelectedSort.name
    
    private lazy var header = PlayListHeaderView(frame: .zero, headerTitle: url.deletingPathExtension().lastPathComponent)
    
    private lazy var nowPlayingView = NowPlayingView() // nowPlayingView를 UIButton으로 하려고 했지만, 버튼 크기 유지하면서 내부 요소들을 정렬할 수 가 없어 UIView에 UITapGestureRecognizer를 사용해 구현함
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PlayListTableViewCell.self, forCellReuseIdentifier: "PlayListTableViewCell")
        
        return tableView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        setFuncInHeaderBtn()
        addActionToNowPlayingView()
        playList = filemanager.getAudioFileListFromDocument(url : url)
        
//        playList = CoreDataFunc().fetchAudio()
        
    }
    
    func refreshPlayListVC() {
        playList = filemanager.getAudioFileListFromDocument(url : url)
        tableView.reloadData()
    }
    
    
    
    // when NowPlayeringView was tapped, push PlayerVC to navigation
    private func addActionToNowPlayingView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PushPlayerVC(_:)))
        nowPlayingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func PushPlayerVC(_ sender: UITapGestureRecognizer) {
        if playerController.audio == nil { return }
        
        let playerVC = PlayerViewController()
        navigationController?.pushViewController(playerVC, animated: true)
    }

    
}


// TableView
extension PlayListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListTableViewCell", for: indexPath) as? PlayListTableViewCell else {return UITableViewCell()}
        
        cell.setLayout(item : playList[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = playList[indexPath.row]
        
        if item.type == .file {
            if playerController.audio?.title != item.title {
                playerController.audio = NowAudio(waveImage: UIImage(),
                                                  mainImage: UIImage(),
                                                  title: item.title,
                                                  currentTime: 0.0)
                playerController.isNewAudio = true
                playerController.configurePlayer()
            }
            
            let playerVC = PlayerViewController()
            navigationController?.pushViewController(playerVC, animated: true)
        }
        else {
            let playListVC = PlayListViewController()
            playListVC.url = item.url
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
    
    
    
}


// header btn functions
extension PlayListViewController {
    
    @objc func tapBackBtn() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setFuncInHeaderBtn(){
        header.backBtn.addTarget(self, action: #selector(tapBackBtn), for: .touchUpInside)
        
        header.editBtn.menu = createMenus(selectedSort: self.selectedSort, sortOrder: self.sortOrder)
        header.editBtn.showsMenuAsPrimaryAction = true
        
    }
    
    func createMenus(selectedSort : SelectedSort, sortOrder : ComparisonResult) -> UIMenu {
        let select = UIAction(title: "선택", image: UIImage(systemName: "checkmark.circle"), handler: { _ in print("선택") })
        let newFolder = UIAction(title: "새로운 폴더", image: UIImage(systemName: "folder.badge.plus"), handler: {_ in
            self.filemanager.createForderInDocument(title: "새로운 폴더", documentsURL: self.url)
            self.refreshPlayListVC()
        })
        
        let wifi = UIAction(title: "와이파이 파일 추가", image: UIImage(systemName: "wifi"), handler: { _ in print("와이파이") })
        let cable = UIAction(title: "USB 파일 추가", image: UIImage(systemName: "cable.connector.horizontal"), handler: { _ in print("usb") })
        
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


// layout Setting
extension PlayListViewController {
    
    private func setLayout() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        [header, tableView, nowPlayingView].forEach{
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
            $0.bottom.equalToSuperview()
        }

        nowPlayingView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.width.equalTo(170)
            $0.height.equalTo(50)
            $0.bottom.equalTo(tableView).inset(30)
        }

    }
}
