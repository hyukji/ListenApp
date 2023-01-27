//
//  CustomAlertViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/24.
//

import UIKit

protocol CustomAlertDelegate : AnyObject {
    func confirmRename(text : String)
    func confirmNewFolder(text : String)
    func confirmAddWifiFile()
}

enum AlertType {
    case onlyConfirm    // 확인 버튼
    case canCancel      // 확인 + 취소 버튼
}

enum AlertCategory {
    case rename
    case newFolder
    case addWifiFile
    case addCableFile
}

class CustomAlertViewController: UIViewController {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 12
        
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 14
        view.distribution = .fillEqually
        
        view.addArrangedSubview(cancelButton)
        view.addArrangedSubview(confirmButton)
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = alertCategory.alertTitle
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        
        return label
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = alertCategory.alertText
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var IPadderssLabel: UILabel = {
        let label = UILabel()
        label.text = IPaddress
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.text = defaultName
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .always
        
        return textField
    }()
        
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.setTitle(cancelButtonText, for: .normal)
        button.setTitleColor(.label, for: .normal)
        
        button.addTarget(self, action: #selector(tapcancelButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.setTitleColor(.label, for: .normal)
        button.setTitle(confirmButtonText, for: .normal)
        
        button.addTarget(self, action: #selector(tapconfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    
    
    weak var delegate : CustomAlertDelegate?
    
    var alertCategory : AlertCategory!
    
    var defaultName = "새로운 파일"
    
    var IPaddress = ""
    var confirmButtonText = "확인"
    var cancelButtonText = "취소"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        
        // alertType에 따른 디자인 처리
        switch alertCategory.alerttype {
        case .onlyConfirm:
            cancelButton.isHidden = true
            confirmButton.isHidden = false
        case .canCancel:
            cancelButton.isHidden = false
            confirmButton.isHidden = false
        }
        
        switch alertCategory {
        case .rename, .newFolder:
            textField.isHidden = false
            IPadderssLabel.isHidden = true
        case .addWifiFile:
            textField.isHidden = true
            IPadderssLabel.isHidden = false
        default:
            textField.isHidden = true
            IPadderssLabel.isHidden = true
        }
        
    }
    
    @objc func tapconfirmButton(_ sender: Any) {
        // confirm button touch event
        switch alertCategory {
        case .rename:
            let text = textField.text ?? ""
            self.delegate?.confirmRename(text: text)
        case .newFolder:
            let text = textField.text ?? ""
            self.delegate?.confirmNewFolder(text: text)
        case .addWifiFile:
            self.delegate?.confirmAddWifiFile()
        default:
            break
        }
        
        self.dismiss(animated: true)
    }
    
    @objc func tapcancelButton(_ sender: Any) {
        // cancel button touch
        self.dismiss(animated: true)
    }
    
    
    private func setLayout() {
        /// customAlertView 둥글기 적용
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        
        containerView.addSubview(contentStackView)
        containerView.addSubview(buttonStackView)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(textLabel)
        contentStackView.addArrangedSubview(textField)
        contentStackView.addArrangedSubview(IPadderssLabel)
        
        
        if alertCategory.alerttype == .canCancel {
            buttonStackView.addArrangedSubview(cancelButton)
            buttonStackView.addArrangedSubview(confirmButton)
        }
        else {
            buttonStackView.addArrangedSubview(confirmButton)
        }
        
        
        containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.top.greaterThanOrEqualToSuperview().inset(50)
            $0.bottom.lessThanOrEqualToSuperview().inset(50)
        }

        contentStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(containerView).inset(30)
            $0.bottom.equalToSuperview().offset(-100)
        }
        
        textField.snp.makeConstraints{
            $0.width.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentStackView.snp.width)
        }
    }
}


    
extension AlertCategory {
    var alerttype : AlertType {
        switch self {
        case .rename: return .canCancel
        case .newFolder: return .canCancel
        case .addWifiFile: return .onlyConfirm
        case .addCableFile: return .onlyConfirm
        }
    }
    
    var alertTitle: String {
        switch self {
        case .rename:
            return "이름 변경"
        case .newFolder:
            return "새로운 폴더"
        case .addWifiFile:
            return "Wifi 파일 추가"
        case .addCableFile:
            return "USB 파일 추가"
        }
    }
    
    var alertText: String {
        switch self {
        case .rename:
            return "변경할 이름을 적어주세요"
        case .newFolder:
            return "새로운 파일 이름을 적어주세요"
        case .addWifiFile:
            return "기기와 동일한 와이파이에 연결한 후에 하단의 주소로 접속해주세요"
        case .addCableFile:
            return "연결 후에 파일로 이도애주세요"
        }
    }
}
