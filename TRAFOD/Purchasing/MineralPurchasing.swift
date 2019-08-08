//
//  MineralPurchasing.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 8/1/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit
import StoreKit

protocol MineralPurchasing {
    
    var buyMineralButtons:[Minerals:BuyButton]? { get set }
    var purchaseScreen:PurchaseMineralsViewController? { get set }
    
    func getPurchaseButton (mineralType: Minerals) -> BuyButton
    
    /**
     When the user presses the purchase button than a dialog box will appear that will ask them how m
     any of the mineral they would like to purchase.
     */
    func getPurchaseScreen (mineralType: Minerals) -> PurchaseMineralsViewController
    
    func getBuyButton (mineralType: Minerals) -> BuyButton
    
    func showPurchaseScreen (mineralType: Minerals, world: World) -> PurchaseMineralsViewController?
}

class BuyButton: SKSpriteNode {
    var mineralType:Minerals = .ANTIGRAV
}

extension MineralPurchasing {

    internal func getBuyButton (mineralType: Minerals) -> BuyButton {
        let button = BuyButton(texture: SKTexture(imageNamed: ImageNames.BuyButton.rawValue))
        button.mineralType = mineralType
        button.size = CGSize(width: 180, height: 90)
        return button
    }
    
    func getPurchaseButton (mineralType: Minerals) -> BuyButton {
        // Return a sprite node that will be displayed beneath the corresponding mineral button
        let button = self.getBuyButton(mineralType: mineralType)
        
        switch mineralType {
        case .ANTIGRAV:
            button.position.x = ScreenButtonPositions.AntiGravCounterNode.x + 120
            button.position.y = ScreenButtonPositions.AntiGravCounterNode.y
            button.zPosition = 100
        case .IMPULSE:
            break
        case .TELEPORT:
            break
        case .USED_TELEPORT:
            break
        case .FLIPGRAVITY:
            break
        case .MAGNETIC:
            break
        }
        
        return button
    }
    
    internal func getPurchaseScreen (mineralType: Minerals) -> PurchaseMineralsViewController {
        
        guard let purchaseScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Scenes.PurchaseMineralViewController) as? PurchaseMineralsViewController else {
            fatalError("View Controller with name \(Scenes.PurchaseMineralViewController) does not exist in storyboard Main")
        }
        
        purchaseScreen.mineralType = mineralType
        return purchaseScreen
    }
    
    func showPurchaseScreen (mineralType: Minerals, world: World) -> PurchaseMineralsViewController? {
        
        let purchaseScreen = self.getPurchaseScreen(mineralType: mineralType)
        let navViewController = UIApplication.shared.keyWindow?.rootViewController
        navViewController?.present(purchaseScreen, animated: true, completion: nil)
        
        return purchaseScreen
    }
}

class PurchaseMineralsViewController: UIViewController {
    
    var mineralType:Minerals?
    var products:[SKProduct]?
    var errorPurchasingView:UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        PKIAPHandler.shared.fetchAvailableProducts { (products) in
            self.products = products
        }                
    }
    
    func getProductWithId (id: ProductIds, products: [SKProduct]) -> SKProduct? {
        return products.filter { $0.productIdentifier == id.rawValue }.first
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func purchase5MineralsPressed(_ sender: Any) {
        guard let products = self.products else { return }
        guard let product = self.getProductWithId(id: .FiveMinerals, products: products) else {
            return
        }
        
        self.purchaseProduct(product: product) { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                
            }
        }
        
    }
    
    func purchaseProduct (product: SKProduct, completion: @escaping (Bool) -> ()) {
        PKIAPHandler.shared.purchase(product: product) { (alertType, product, transaction) in
            if let product = product, let transaction = transaction {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    @IBAction func purchase40MineralsPressed(_ sender: Any) {
        
    }
    
    @IBAction func purchase100MineralsPressed(_ sender: Any) {
        
    }
    
    @IBAction func purchase1000MineralsPressed(_ sender: Any) {
        
    }
    
    @IBAction func purchase5000MineralsPressed(_ sender: Any) {
        
    }
    
}


