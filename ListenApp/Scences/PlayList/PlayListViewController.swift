//
//  PlayListViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit
import SnapKit


class PlayListViewController : UIViewController {
    
    private lazy var header = PlayListHeaderView(frame: .zero)
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
        tapNowPlayingView()
    }
    
    
    
    // when NowPlayeringView was tapped, push PlayerVC to navigation
    private func tapNowPlayingView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PushPlayerVC(_:)))
        nowPlayingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func PushPlayerVC(_ sender: UITapGestureRecognizer) {
        let playerVC = PlayerViewController()
        navigationController?.pushViewController(playerVC, animated: true)
    }

    
}




// TableView
extension PlayListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListTableViewCell", for: indexPath) as? PlayListTableViewCell else {return UITableViewCell()}
        
        cell.setLayout()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playerVC = PlayerViewController()
        navigationController?.pushViewController(playerVC, animated: true)
        
    }
    
    // 위 아래 드래그 시에 sectionheader 색상이 회색으로 바뀌는 것을 막고자 SectionHeaderView를 따로 삽입
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView() //set these values as necessary
        view.backgroundColor = .systemBackground
        view.frame.size = CGSize(width: tableView.frame.width, height: 100)

        let label = UILabel()
        label.text = "총 20개 파일"
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
    
    private func setLayout() {
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
