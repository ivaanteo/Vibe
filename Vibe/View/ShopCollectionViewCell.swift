//
//  ShopCollectionViewCell.swift
//  Vibe
//
//  Created by Ivan Teo on 23/6/21.
//

import UIKit

class ShopCollectionViewCell: UICollectionViewCell{
    
    // View Components
    var purchaseButton: PurchaseButton!
    private var nameLabel: UILabel!
    private var waveImageView: UIImageView!
    
    // View Dimensions
    private let margin: CGFloat = 20
    private lazy var buttonWidth: CGFloat = {
        return contentView.frame.width * 0.25
    }()
    private var buttonHeight:CGFloat = 35
    
    // Bool
    var vibrationOwned = false
    var vibrationIsSelected: Bool?{
        didSet{
            if vibrationIsSelected!{
                DispatchQueue.main.async {
                    // darken because is selected
                    self.purchaseButton.isHidden = true
                    self.backgroundColor = .init(white: 0.1, alpha: 0.4)
                }
            }else{
                DispatchQueue.main.async {
                    // reset to normal colour for reuse cell
                    self.purchaseButton.isHidden = false
                    self.backgroundColor = .init(white: 0.35, alpha: 0.5)
                }
            }
        }
    }

    
    // View Model
    var backgroundVibration: BackgroundVibrationViewModel?{
        didSet{
            vibrationOwned = BackgroundVibrationManager.shared.vibrationsOwned.contains(backgroundVibration!.id)
            if vibrationOwned{
                purchaseButton.setTitle("Select", for: .normal)
            }
            else{
//            }else if backgroundVibration?.id != BackgroundVibrationManager.shared.getBackgroundChoice(){
                purchaseButton.setTitle("$\(backgroundVibration!.price)", for: .normal)
            }
            nameLabel.text = backgroundVibration?.title
            waveImageView.image = backgroundVibration?.img
        }
    }
    
    
    // Button Actions
    
    
    // Layout Views
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        setupBackground()
        setupImageView()
        setupNameLabel()
        setupPurchaseButton()
    }
    func setupBackground(){
        backgroundColor = .init(white: 0.35, alpha: 0.5)
        layer.cornerRadius = contentView.frame.height / 4
        layer.shadowOffset = CGSize(width: 4, height: 8)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.5
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
    }
    
    func setupPurchaseButton(){
        purchaseButton = PurchaseButton()
        purchaseButton.backgroundColor = .clear
        purchaseButton.layer.cornerRadius = buttonHeight/2
        purchaseButton.titleLabel?.font = UIFont(name: "Futura", size: 16)
        contentView.addSubview(purchaseButton)
        setupPurchaseButtonConstraints()
    }
    
    func setupPurchaseButtonConstraints(){
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        purchaseButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        purchaseButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        purchaseButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        purchaseButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: margin).isActive = true
        purchaseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin).isActive = true
    }
    
    func setupNameLabel(){
        nameLabel = UILabel()
        nameLabel.numberOfLines = 2
        nameLabel.textColor = . white
        nameLabel.font = UIFont(name: "Futura", size: 16)
        contentView.addSubview(nameLabel)
        setupNameLabelConstraints()
    }
    
    func setupNameLabelConstraints(){
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: waveImageView.trailingAnchor, constant: margin).isActive = true
    }
   
    func setupImageView(){
        waveImageView = UIImageView()
        waveImageView.tintColor = UIColor(named: "orange")
        contentView.addSubview(waveImageView)
        setupImageViewConstraints()
    }
    
    func setupImageViewConstraints(){
        waveImageView.translatesAutoresizingMaskIntoConstraints = false
        waveImageView.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        waveImageView.widthAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        waveImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        waveImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin).isActive = true
    }
    
}
