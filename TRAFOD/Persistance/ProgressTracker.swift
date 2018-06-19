//
//  ProgressTracker.swift
//  TRAFOD
//
//  Created by adeiji on 6/18/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import RealmSwift

class ProgressTracker {
    
    // Removes all progress and starts the game anew
    public class func reset () {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    public class func updateProgress (currentLevel: String?, player: Player) {
        let realm = try! Realm()
        let progresses = realm.objects(Progress.self)
        if progresses.count > 0 {
            if let progress = progresses.first {
                try! realm.write {
                    
                    if let currentLevel = currentLevel {
                        progress.currentLevel = currentLevel
                    }
                    progress.hasAntigrav = player.hasAntigrav
                    progress.hasImpulse = player.hasImpulse
                }
            }
        } else {
            let progress = Progress()
            try! realm.write {
                if let currentLevel = currentLevel {
                    progress.currentLevel = currentLevel
                }
                
                progress.hasAntigrav = player.hasAntigrav
                progress.hasImpulse = player.hasImpulse
                
                realm.add(progress)
            }
        }
    }
    
    public class func getProgress () -> Progress? {
        let realm = try! Realm()
        if let progress = realm.objects(Progress.self).first {
            return progress
        }
        
        return nil
    }
    
    public class func updateMineralCount (myMineral: String, count: Int) {
        let realm = try! Realm()
        if let mineralCount = realm.objects(MineralCount.self).filter("mineral == %@", myMineral).first {
            try! realm.write {
                mineralCount.count = count
            }
        } else {
            let mineralCount = MineralCount()
            mineralCount.count = count
            mineralCount.mineral = myMineral
            
            try! realm.write {
                realm.add(mineralCount)
            }
        }
    }
    
    public class func getElementsCollected () -> Results<Elements>? {
        let realm = try! Realm()
        let elements = realm.objects(Elements.self)
        if elements.count > 0 {
            return elements
        }
        
        return nil
    }
    
    public class func updateElementsCollected (level: String, node: String) {
        let realm = try! Realm()
        if let elements = realm.objects(Elements.self).filter("level == %@", level).first {
            try! realm.write {
                elements.nodes.append(node)
            }
        } else {
            let elements = Elements()
            elements.level = level
            elements.nodes.append(node)
            try! realm.write {
                realm.add(elements)
            }
        }
    }
    
    public class func getMineralCounts () -> Results<MineralCount>? {
        let realm = try! Realm()
        let mineralCounts = realm.objects(MineralCount.self)
        if mineralCounts.count > 0 {
            return mineralCounts
        }
            
        return nil
    }
}

class MineralCount: Object {
    @objc dynamic var mineral = ""
    @objc dynamic var count = 0
}

class Progress: Object {
    @objc dynamic var currentLevel = ""
    @objc dynamic var hasAntigrav = false
    @objc dynamic var hasImpulse = false
}

class Elements: Object {
    @objc dynamic var level = ""
    let nodes = List<String>()
}
