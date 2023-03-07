//
//  SettingViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit
import MessageUI

struct SettingCategory {
    let name : String
    let text : String
    let icon : String
    var type : SettingType
}

enum SettingType : Equatable {
    case listSetting
    case rateSetting
    case rating
    case sharing
    case sending
}


class SettingViewController : UIViewController {
    let adminUserDefault = AdminUserDefault.shared
    
    private var normalSettingList: [SettingCategory] = []
    private var audioSettingList: [SettingCategory] = []
    private var supportSettingList: [SettingCategory] = []
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 50
        
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "SettingTableViewCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGroupedBackground
        self.navigationItem.title = "설정"
        setData()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.reloadData()
    }
    
    func setData() {
        normalSettingList = [
            SettingCategory(name: "thema", text: "테마", icon: "moon", type: .listSetting),
            SettingCategory(name: "language", text: "언어", icon: "globe", type: .listSetting)
        ]
        audioSettingList = [
            SettingCategory(name: "startLocation", text: "시작 위치", icon: "play", type: .listSetting),
            SettingCategory(name: "rateSetting", text: "초기 재생 속도", icon: "forward.circle", type: .rateSetting),
            SettingCategory(name: "secondTerm", text: "초단위 이동", icon: "arrow.triangle.2.circlepath", type: .listSetting),
            SettingCategory(name: "repeatTerm", text: "반복 대기시간", icon: "repeat.circle", type: .listSetting)
            
        ]
        supportSettingList = [
            SettingCategory(name: "", text: "평가", icon: "star", type: .rating),
            SettingCategory(name: "", text: "앱공유", icon: "paperplane", type: .sharing),
            SettingCategory(name: "", text: "to 개발자", icon: "envelope", type: .sending)
        ]
    }
    
}


// layout Setting
private extension SettingViewController {
    
    func setLayout() {
        [tableView].forEach{
            view.addSubview($0)
        }
        
        tableView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalToSuperview()
        }


    }
    
}



extension SettingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var targetList : [SettingCategory] = []
        switch indexPath.section {
        case 0:
            targetList = normalSettingList
        case 1:
            targetList = audioSettingList
        case 2:
            targetList = supportSettingList
        default:
            return
        }
        
        let data = targetList[indexPath.row]
        switch data.type {
        case .listSetting:
            let subSettingVC = ListSettingViewController()
            
            subSettingVC.settingCategory = data
            subSettingVC.subSettingData = adminUserDefault.settingData[data.name] ?? []
            subSettingVC.selected = adminUserDefault.settingSelected[data.name] ?? 0
            subSettingVC.SettingindexPath = indexPath
            subSettingVC.delegate = self
            
            navigationController?.pushViewController(subSettingVC, animated: true)
        case .rateSetting:
            let rateSettingVC = RateSettingViewController()
            
            rateSettingVC.settingCategory = data
            rateSettingVC.selectedValue = adminUserDefault.rateSetting
            rateSettingVC.delegate = self
            
            navigationController?.pushViewController(rateSettingVC, animated: true)
        case .rating:
            let appId = "111"
            if let appstoreUrl = URL(string: "https://apps.apple.com/app/\(appId)") {
                var urlComp = URLComponents(url: appstoreUrl, resolvingAgainstBaseURL: false)
                urlComp?.queryItems = [
                    URLQueryItem(name: "action", value: "write-review")
                ]
                guard let reviewUrl = urlComp?.url else {
                    return
                }
                UIApplication.shared.open(reviewUrl, options: [:], completionHandler: nil)
            }
        case .sharing:
            let objectsToShare = ["영어 듣기 앱! 주소 뭐시기 ~ "]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            
            // 공유하기 기능 중 제외할 기능이 있을 때 사용
    //        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            
            self.present(activityVC, animated: true, completion: nil)
        case .sending:
            // 이메일 사용가능한지 체크하는 if문
            if MFMailComposeViewController.canSendMail() {
                
                let compseVC = MFMailComposeViewController()
                compseVC.mailComposeDelegate = self
                
                compseVC.setToRecipients(["본 메일을 전달받을 이메일주소"])
                compseVC.setSubject("메시지제목")
                compseVC.setMessageBody("메시지컨텐츠", isHTML: false)
                
                self.present(compseVC, animated: true, completion: nil)
                
            }
            else {
                self.showSendMailErrorAlert()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return normalSettingList.count
        case 1:
            return audioSettingList.count
        case 2:
            return supportSettingList.count

        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as? SettingTableViewCell else {return UITableViewCell() }
        
        let targetList : [SettingCategory]
        
        switch indexPath.section {
        case 0:
            targetList = normalSettingList
        case 1:
            targetList = audioSettingList
        case 2:
            targetList = supportSettingList
        default:
            return UITableViewCell()
        }
        SettingTableViewCell.setLayout(data : targetList[indexPath.row])
        SettingTableViewCell.selectionStyle = .none
        
        
        return SettingTableViewCell
    }
    
    
}

extension SettingViewController : ListSettingProtocol {
    func ChangeListSetting(indexPath: IndexPath, selectedInt: Int) {
        switch indexPath.section {
        case 0:
            adminUserDefault.saveListSettingData(name: normalSettingList[indexPath.row].name, new: selectedInt)
        case 1:
            adminUserDefault.saveListSettingData(name: audioSettingList[indexPath.row].name, new: selectedInt)
        case 2:
            adminUserDefault.saveListSettingData(name: supportSettingList[indexPath.row].name, new: selectedInt)
        default:
            return
        }
    }
}



extension SettingViewController : RateSettingProtocol {
    func ChangeRateSetting(selectedValue: Float) {
        adminUserDefault.saveRateSettingData(new: selectedValue)
        if PlayerController.playerController.player != nil {
            PlayerController.playerController.player.rate = AdminUserDefault.shared.rateSetting
        }
    }
}

extension SettingViewController : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func showSendMailErrorAlert() {
        let customAlerVC = CustomAlertViewController()
        
        customAlerVC.alertCategory = .errorSendMail
        
        customAlerVC.modalPresentationStyle = .overFullScreen
        customAlerVC.modalTransitionStyle = .crossDissolve
        self.present(customAlerVC, animated: true, completion: nil)
    }
}
