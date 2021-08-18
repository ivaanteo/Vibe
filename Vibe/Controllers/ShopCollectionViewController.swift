//
//  ShopViewController.swift
//  Vibe
//
//  Created by Ivan Teo on 23/6/21.
//

import UIKit
import StoreKit

class ShopCollectionViewController:UICollectionViewController{
    private let cellId = "ShopCell"
    private let headerId = "HeaderView"
    // from apple developer
    private let productId = "com.ivaanteo-.Vibe"
    var currentBackgroundChoice = BackgroundVibrationManager.shared.getBackgroundChoice()
    weak var delegate: ShopCollectionViewDelegate?
    var usedTestSamples = [Int]()
    var idToBuy: Int = 0
    
    deinit {
        print("shopvc did deinit")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if usedTestSamples != []{
            print("delegate methods called")
            delegate?.didSelectBgVibration(sender: self)
            delegate?.didDismissVC(sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Background
        collectionView.backgroundColor = .none
        configureGradientBackground()
        
        // Register Cell and Header
        collectionView.register(ShopCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(ShopCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        // StoreKit Delegate
        SKPaymentQueue.default().add(self)
    }
    
    func purchaseVibration(id: Int){
        if SKPaymentQueue.canMakePayments(){
            let paymentRequest = SKMutablePayment()
//            paymentRequest.productIdentifier = productIDs[id]
            paymentRequest.productIdentifier = BackgroundVibrationManager.backgroundVibrations[id].productID
            SKPaymentQueue.default().add(paymentRequest)
        }else{
            
        }
    }
    
    @objc func purchaseButtonTapped(_ sender: UIButton){
        // check if purchased
//        let backgroundVibration = BackgroundVibrationManager.backgroundVibrations[sender.tag]
//        let vibrationId = backgroundVibration!.id
        print("buttonTapped")
        let vibrationOwned = BackgroundVibrationManager.shared.vibrationsOwned.contains(sender.tag)
        if vibrationOwned{
            UserDefaults.standard.setValue(sender.tag, forKey: Constants.backgroundChoice)
            self.delegate?.didSelectBgVibration(sender: self)
            self.currentBackgroundChoice = sender.tag
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.delegate?.didDismissVC(sender: self)
                }
            }
        }else{
            // store kit purchase request
            idToBuy = sender.tag
            purchaseVibration(id: sender.tag)
            
            // temporary
//            BackgroundVibrationManager.shared.updateVibrationsOwned(vibrationId: sender.tag)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func restoreButtonTapped(_ sender: UIButton){
        print("restore button tapped")
        //restore vibration
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> ShopCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ShopCollectionViewCell
        let backgroundVibration = BackgroundVibrationManager.backgroundVibrations[indexPath.row]
        
        // set selected background colour
        cell.vibrationIsSelected = (backgroundVibration.id == currentBackgroundChoice)
        
        if usedTestSamples.contains(backgroundVibration.id){
            DispatchQueue.main.async {
                cell.backgroundColor = .init(white: 0.5, alpha: 0.3)
            }
        }
        
        cell.backgroundVibration = BackgroundVibrationViewModel(id: backgroundVibration.id,
                                                                title: backgroundVibration.title,
                                                                price: backgroundVibration.price,
                                                                img: backgroundVibration.img)
        cell.purchaseButton.tag = backgroundVibration.id
        cell.purchaseButton.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BackgroundVibrationManager.backgroundVibrations.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // play engine
        if !usedTestSamples.contains(indexPath.row){
            delegate?.didTestSample(id: indexPath.row)
            usedTestSamples.append(indexPath.row)
//            DispatchQueue.main.async {
//                collectionView.reloadData()
//            }
//            let cell = collectionView.cellForItem(at: indexPath)
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
            print("didselectitemat")
        }
    }
    
    
}

extension ShopCollectionViewController: UICollectionViewDelegateFlowLayout{
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! ShopCollectionViewHeader
        headerView.restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width * 0.9,
                      height:140)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}

extension ShopCollectionViewController: SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState {
            case .purchased:
                print("purchased")
                // update user defaults
                // update backgroundvibrations
                BackgroundVibrationManager.shared.updateVibrationsOwned(vibrationId: self.idToBuy)
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .purchasing:
                print("purchasing")
            case .failed:
                if let error = transaction.error{
                    print("Error: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                print("restored")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                print("deferred")
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                print("default")
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    
}

protocol ShopCollectionViewDelegate : AnyObject{
    func didSelectBgVibration(sender: ShopCollectionViewController)
    func didDismissVC(sender: ShopCollectionViewController)
    func didTestSample(id: Int)
}
