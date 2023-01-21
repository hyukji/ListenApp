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
        setFuncInheaderBtn()
        addActionToNowPlayingView()
        playList = filemanager.getAudioFileListFromDocument(url : url)
        
//        playList = CoreDataFunc().fetchAudio()
        
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



// layout Setting
extension PlayListViewController {
    
    @objc func tapEditBtn() {
        print("tapEditBtn")
    }
    
    
    @objc func tapBackBtn() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setFuncInheaderBtn(){
        header.backBtn.addTarget(self, action: #selector(tapBackBtn), for: .touchUpInside)
        header.editBtn.addTarget(self, action: #selector(tapEditBtn), for: .touchUpInside)
    }
    
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
