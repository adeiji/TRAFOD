//
//  TRAFODTests.swift
//  TRAFODTests
//
//  Created by adeiji on 6/7/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import XCTest
import GameKit
import StoreKit

@testable import TRAFOD

class TRAFODTests: XCTestCase {
    
    let world = World()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShowBook () {
        let bookChapter = self.world.getChapterScene(bookChapter: .Chapter1)
        XCTAssertNotNil(bookChapter)
        
        world.showChapter(bookChapter: bookChapter)
        XCTAssertEqual(world.view?.scene, bookChapter)
    }
    
    func testMoveCamera () {
        self.world.moveCameraToFollowPlayerXPos()
        XCTAssertEqual(self.world.camera?.position.x, self.world.player.position.x)
        
        self.world.moveCameraToFollowPlayerYPos()
        XCTAssertEqual(self.world.camera?.position.y, self.world.player.position.y)
    }
    
    func testMineralUsed () {
        let mineralCount = self.world.player.mineralCounts[.IMPULSE] ?? 1
        let mineral = AntiGravityMineral()
        let _ = mineral.mineralUsed(contactPosition: CGPoint(x: 0, y: 0), world: self.world)
        XCTAssertEqual(mineralCount - 1, self.world.player.mineralCounts[.IMPULSE])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetBuyButton () {
        let buyButton = self.world.getBuyButton(mineralType: .IMPULSE)
        XCTAssert(buyButton.mineralType == .IMPULSE)
    }
    
    func testGetPurchaseButton () {
        let buyButton = self.world.getPurchaseButton(mineralType: .IMPULSE)
        
        XCTAssert(buyButton.mineralType == .IMPULSE)
    }
    
    func testGetProductWithId () {
        let purchaseMineralsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Scenes.PurchaseMineralViewController) as? PurchaseMineralsViewController
        let purchaseExpectation = expectation(description: "product")
        var storeProducts:[SKProduct]?
        
        PKIAPHandler.shared.fetchAvailableProducts { (products) in
            storeProducts = products
            purchaseExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            let product = purchaseMineralsViewController?.getProductWithId(id: .FiveMinerals, products: storeProducts!)
            XCTAssert(product?.productIdentifier == ProductIds.FiveMinerals.rawValue)
        }
    }
    
    func testRemoveBuyButton () {
        self.world.getBuyButton(mineralType: .ANTIGRAV)
        self.world.removeBuyButton(mineralType: .ANTIGRAV)
        XCTAssertNil(self.world.buyMineralButtons?[.ANTIGRAV])
    }
    
    func testPurchaseMinerals () {
        let purchaseMineralsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Scenes.PurchaseMineralViewController) as? PurchaseMineralsViewController
        let purchaseExpectation = expectation(description: "product")
        var storeProducts:[SKProduct]?
        
        PKIAPHandler.shared.fetchAvailableProducts { (products) in
            storeProducts = products
            purchaseExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            let product = purchaseMineralsViewController?.getProductWithId(id: .FiveMinerals, products: storeProducts!)
            purchaseMineralsViewController?.purchaseProduct(product: product!, completion: { (success) in
                XCTAssertTrue(success)
            })
        }
    }
    
    func testShowPurchaseScreen () {
//        let _ = self.world.showPurchaseScreen(mineralType: .IMPULSE, world: self.world)
//        XCTAssertEqual(self.world.view?.subviews.last, self.world.purchaseScreen?.view)
    }
    
//    func testBuyButtonPressed () {
//        self.world.showBuyMineralButton(mineralType: .ANTIGRAV)
//        let buyButton = self.world.buyMineralButtons?[.ANTIGRAV]
//        self.world.touchDown(atPoint: CGPoint(x: 138.03558349609375, y: 246.8231201171875))
//        XCTAssertNotNil(self.world.purchaseScreen)
//        XCTAssertEqual(self.world.purchaseScreen?.mineralType, Minerals.ANTIGRAV)
//    }
    
    func testPurchaseService () {
        
        
    }
    
    func testCheckIfBuyMineralButtonPressed () {
        self.world.showBuyMineralButton(mineralType: .IMPULSE)
        let buyButton = self.world.buyMineralButtons?[.IMPULSE]
        
        var mineralBuyButton = self.world.checkIfBuyMineralButtonWasPressedAndReturnButtonIfTrue(touchPoint: CGPoint(x: -1000000, y: -1000000))
        XCTAssertNil(mineralBuyButton)
        
        mineralBuyButton = self.world.checkIfBuyMineralButtonWasPressedAndReturnButtonIfTrue(touchPoint: buyButton!.position)
        XCTAssertNotNil(mineralBuyButton)
    }
    
    func testShowBuyMineralButton () {
        _ = self.world.getBuyButton(mineralType: .IMPULSE)
        self.world.showBuyMineralButton(mineralType: .IMPULSE)
        XCTAssertNotNil(self.world.buyMineralButtons?[.IMPULSE])
    }
    
    func testGetPurchaseScreen () {
        let purchaseScreen = self.world.getPurchaseScreen(mineralType: .IMPULSE)
        XCTAssertNotNil(purchaseScreen)
        XCTAssertEqual(purchaseScreen.mineralType, Minerals.IMPULSE)
    }
    
}
