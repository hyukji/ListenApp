//
//  CustomAlertViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/24.
//

import UIKit

protocol CustomAlertDelegate : AnyObject {
    func confirmRename(newTitle : String)
    func confirmNewFolder(text : String)
    func confirmAddWifiFile()
    func confirmAddCableFile()
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
    case errorSendMail
}

class CustomAlertViewController: UIViewController {
    private lazy var mainImgView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = alertCategory.mainImage
        
        return imageView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 40
        
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 10
        
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 14
        view.distribution = .fillEqually
        
        view.addArrangedSubview(confirmButton)
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = alertCategory.alertTitle
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = alertCategory.alertText
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var IPadderssLabel: UILabel = {
        let label = UILabel()
        label.text = IPaddress
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        
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
        
//        button.layer.cornerRadius = 25
//        button.layer.borderWidth = 1
        
//        button.setTitle(cancelButtonText, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 13, weight: .semibold), scale: .default)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: imageConfig)!, for: .normal)
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(tapcancelButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
//        button.setTitleColor(.systemBackground, for: .normal)
//        button.setTitle(confirmButtonText, for: .normal)
//        button.backgroundColor = .tintColor
        
        
        button.layer.borderColor = UIColor.tintColor.cgColor
        button.setTitleColor(.tintColor, for: .normal)
        button.setTitle(confirmButtonText, for: .normal)
        button.backgroundColor = .systemBackground
        
        
        button.addTarget(self, action: #selector(tapconfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    
    private lazy var additionalLabel: UILabel = {
        let label = UILabel()
        label.text = "파일 이동 후에 창을 닫아주세요."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    
    weak var delegate : CustomAlertDelegate?
    
    var alertCategory : AlertCategory!
    
    var defaultName = "새로운 파일"
    
    var IPaddress = ""
    var confirmButtonText = "확인"
    
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
            additionalLabel.isHidden = true
        case .addWifiFile:
            textField.isHidden = true
            IPadderssLabel.isHidden = false
            additionalLabel.isHidden = false
        case .addCableFile:
            textField.isHidden = true
            IPadderssLabel.isHidden = true
            additionalLabel.isHidden = false
        default:
            textField.isHidden = true
            IPadderssLabel.isHidden = true
            additionalLabel.isHidden = true
        }
        
    }
    
    @objc func tapconfirmButton(_ sender: Any) {
        // confirm button touch event
        switch alertCategory {
        case .rename:
            let text = textField.text ?? ""
            self.delegate?.confirmRename(newTitle: text)
        case .newFolder:
            let text = textField.text ?? ""
            self.delegate?.confirmNewFolder(text: text)
        case .addWifiFile:
            self.delegate?.confirmAddWifiFile()
        case .addCableFile:
            self.delegate?.confirmAddCableFile()
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
        containerView.addSubview(mainImgView)
        containerView.addSubview(cancelButton)
        
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.setCustomSpacing(15, after: titleLabel)
        contentStackView.addArrangedSubview(textLabel)
        contentStackView.addArrangedSubview(textField)
        contentStackView.addArrangedSubview(IPadderssLabel)
        contentStackView.addArrangedSubview(additionalLabel)
        
        buttonStackView.addArrangedSubview(confirmButton)
        
        containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.top.greaterThanOrEqualToSuperview().inset(50)
            $0.bottom.lessThanOrEqualToSuperview().inset(50)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(25)
            $0.leading.trailing.equalTo(containerView).inset(25)
            $0.centerX.equalToSuperview()
        }
        
        mainImgView.snp.makeConstraints {
            $0.top.equalTo(containerView).inset(25)
            $0.centerX.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(mainImgView.snp.bottom).offset(15)
            $0.leading.trailing.equalTo(containerView).inset(25)
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-25)
        }

        cancelButton.snp.makeConstraints {
            $0.top.equalTo(containerView).inset(25)
            $0.trailing.equalTo(containerView).inset(25)
        }
        
        IPadderssLabel.snp.makeConstraints{
            $0.height.equalTo(40)
        }
        
        textField.snp.makeConstraints{
            $0.width.equalToSuperview()
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
        case .errorSendMail: return .onlyConfirm
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
        case .errorSendMail:
            return "메일 전송 실패"
        }
    }
    
    var alertText: String {
        switch self {
        case .rename:
            return "변경할 이름을 적어주세요."
        case .newFolder:
            return "새로운 파일 이름을 적어주세요."
        case .addWifiFile:
            return "기기와 동일한 와이파이에 연결한 후에 하단의 주소로 접속해주세요."
        case .addCableFile:
            return "케이블 연결 후에 파일을 이동해주세요."
        case .errorSendMail:
            return "아이폰 이메일 설정을 확인하고 다시 시도해주세요."
        }
    }
    
    
    var mainImage: UIImage {
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 50, weight: .regular), scale: .default)
        switch self {
        case .addWifiFile:
            return UIImage(systemName: "wifi", withConfiguration: imageConfig)!
        case .addCableFile:
            return UIImage(systemName: "tray.and.arrow.down", withConfiguration: imageConfig)!
        case .errorSendMail:
            return UIImage(systemName: "envelope.badge.shield.half.filled", withConfiguration: imageConfig)!
        default:
            return UIImage()
        }
    }
    
    
    
}
