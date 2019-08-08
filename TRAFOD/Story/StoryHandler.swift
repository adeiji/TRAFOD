//
//  StoryHandler.swift
//  TRAFOD
//
//  Created by Adebayo Ijidakinro on 7/29/19.
//  Copyright © 2019 Dephyned. All rights reserved.
//

import Foundation
import GameKit

class Chapter {
    var title:String?
    var content:[Any] = [Any]()
}

class Chapter1 : Chapter {
    override init() {
        super.init()
        self.title = "The Bandits"
        self.content.append("Dawud hung in the frigid air of the woods!  The man was behind him, but he could not lay his eyes upon the source of the voice he heard.  A shrill fear crawled upon his back.  \"What is this strange mineral they've used.\", he thought to himself.  He was completely paralyzed, all he could control were his thoughts, which he tried to stay in order to think his way through his predicament")
        self.content.append("You \(StoryFeatures.Rhidahreuset) spy!  Speak thy purpose in our woods with hast before we force it from your lips with the lance")
        self.content.append("\(StoryFeatures.Rhidahreuset) spy!  I'm no cowards dog!")
        self.content.append("Don't taint these trees with your lies laddie!  A lone man, nay, a boy, rummaging through the forest of \(StoryFeatures.RathTo), and after a raid of the \(StoryFeatures.Rhidahreuset) at that!  Only one pint have I drunk today, and that's nay enough to hide the truth, from the all-seeing eyes of Borothir the wise!")
        self.content.append("I tell you old man, I've no love for the \(StoryFeatures.Rhidahreuset), I come from \(StoryFeatures.Stilgar) in search of me mum and sister.  I have no other intentions in these woods.")
        self.content.append("OLD MAN!!  Now you speak lies, and disrespect! \(StoryFeatures.Borothir) the Wise knows all child!")
        self.content.append("\"\(StoryFeatures.Borothir) the Wise?  I've yet to encounter anyone I would dare label as wise!  Fetch this Borothir the Wise so I may speak my peace with him, for as of yet I've only met Borothir the Fool!\"")
        self.content.append("\(StoryFeatures.Dawud) snapped back, hoping that if any others were nearby, his sharp remarks would draw them out from wherever they were hiding.  A plan which he quickly realized worked with brilliance.")
        self.content.append("A cry of laughter filled the air!  \"\(StoryFeatures.Borothir) the Fool!  Ha ha ha ha!  Oh he's found you out all right you old Bogger!\"")
        self.content.append("\"Leave him alone you drunk fool!  He clearly means no harm.\"  The laughter continued.")
        self.content.append("\"Drunk! Why I've never walked with a crooked step in me life!\"")
        self.content.append("\"Oh but you've stumbled plenty!\"  A man shouted from behind the woods.  Followed by another enormous rupture in laughter.  Dawud continued lifeless in the air.")
        self.content.append("\"Aye shut up John! Use that hole in your face less for talkin' and more for drinkin'. I told you I'm not drunk.\"  \(StoryFeatures.Borothir) paused and his mouth curved into a smile. \"I'm enlightened.\"  Laughter erupted once again")
        self.content.append("\(StoryFeatures.Dawud), seeing the mood change so quickly and realizing the effectiveness of his plan, continued his earlier quips.")
        self.content.append("\"And are you \'enlightened\' often?\" At this, the men all came out the forest bellying over in hearty laughter.  A smile even appeared on the face of \(StoryFeatures.Dawud)")
        self.content.append("\"I like this boy!\" shouted an old, fat man looking at \(StoryFeatures.Dawud).  He's as tough as the stones of Ravenhall!  Let him down so we can hear more of his quest, and the love that impels him.")
        self.content.append("\(StoryFeatures.Dawud) heard the sound of a mineral crash behind him, and he quickly dropped to the ground, landing on his hands and knees.")
        self.content.append("\"What was that?\" \(StoryFeatures.Dawud) asked.")
        self.content.append("\"Ah, it's a Freeze mineral.  Powerful little bugger in't?\"")
        self.content.append("\"I've never seen it before.\"")
        self.content.append("\"The woods contain many wonders me boy. You've yet to see what exists beyond the gates and amidst the trees.  Now, after your mum and sister, eh ladie.  A fine quest.  Ya seem a brave child.")
        self.content.append("\"My family was taken during the last raid of \(StoryFeatures.Stilgar).\"")
        self.content.append("\"Blasted \(StoryFeatures.Rhidahreuset)!\"  \(StoryFeatures.Borothir) bellowed. \"Preying on the innocent like wild animals.  And they call us Bandits the barbarians! We're up to me, I'd wring the necks of each one of 'em!")
        self.content.append("\"The Bandits! \(StoryFeatures.Dawud) thought he had excitedly only thought these words, but he soon realized he shouted them out loud in surprise.")
        self.content.append("\"Aye laddie, the Bandits.\"  \(StoryFeatures.Borothir) said with a confused look on his face.")
        self.content.append("\"I've been looking for you! I've heard so much about the brave Bandits.  My father says you are the last hope for the Free Kingdoms of Eldron!")
        self.content.append("After \(StoryFeatures.Dawud) spoke these words there was a long, awkward pause.  Almost as if they were all in thought.  And then suddenly, all erupted into a rucous laughter, more intense and genuine than all the other times before.")
        self.content.append("\"The last hope for the Free Kingdoms the boy says!  Aye, perhaps I have had one too many pints.  Ha ha ha ha\" shouted Borothir. \"Tell me boy, your father, did he say this after he reached the bottom of a keg of fine brew!?\"  All erupted into laughter again.  \(StoryFeatures.Dawud) didn't understand.  These were the people his father spoke so highly of, but they seemed to him just a reckless rabble, a rabble that he had no intention of wasting his precious time with.")
        self.content.append("\"Did you see the \(StoryFeatures.Rhidahreuset) come this way?\"  \(StoryFeatures.Dawud) asked in irritance.")
        self.content.append("\"Aye, not more 'en two days ago.\"  The Bandit said in between laughs.")
        self.content.append("\"Where we're they going?\"  The laughter almost ended as quickly as it began.  \(StoryFeatures.Dawud) could tell that his question and hit a nerve he was not aware existed.  Another long silence filled the air.")
        self.content.append("\"The mines.\"  A boy dressed in all black stepped out of the shadows. \"They're on their way to the mines.\"")
        self.content.append("A shudder crept down \(StoryFeatures.Dawud)'s spine. \"The Mines of Moore?\"")
        self.content.append("\"Yes ladie.  You've heard of these mines I take it.\"  Dawud nodded his head in agreement. \"Where are these mines?\"")
        self.content.append("\"Deep in the forest, where the sounds of minerals breaking are scarce, and laughter scarcer. None of us has seen the mines.  Only heard stories like your yourself. But we know one thing, those who go, don't ever come back.  That boy there, \(StoryFeatures.Drust) is his name.  His family too was taken to the mines, many cold winters ago.")
        self.content.append("\"You seek no easy task.\"")
        self.content.append("\"But it is a task I must seek.\"")
        self.content.append("\(StoryFeatures.Borothir) smiled.")
        self.content.append("\"It's suicide.\" Drust said.")
        self.content.append("\"My father used to say, \'Only by failing to try can one gurantee failure. Until you've given up, the chance of success still reigns.\'")
        self.content.append("\"A wise man your father.\" \"The wisest.\"")
        self.content.append("You're bravery moves me.  Perhaps I can be of help.  I know these woods better than anyone.")
        self.content.append("The old fat man piped in. \"No Drust, we need you here.  We have young ones to protect.  Your hearts in the right place, but right now, we need your sword.\"")
        self.content.append("\"It's getting late lad. How about we get a pint of fine brew and some roasted Boar and call it a night, and we can speak more of your journey in the mornin'.  Sound good?")
        self.content.append("The days activity had fatigued \(StoryFeatures.Dawud) and he was ready to get some rest.")
        self.content.append("\"Okay\" he said, \"And thank you, Borothir the Wise.\"  The Bandits all smiled.")
    }
}

struct StoryHandler {
    var storyNodes:[SKNode]?
    var chapter:Chapter
    
    init(chapter: BookChapters) {
        self.chapter = Chapter1()
        for level in BookChapters.allCases {
            switch level {
            case .Chapter1:
                if chapter == .Chapter1 {
                    self.chapter = Chapter1();
                    self.setupStoryNodes(chapter: self.chapter)
                }
            }
        }
    }
    
    private mutating func setupStoryNodes (chapter: Chapter) {
        self.storyNodes = [SKSpriteNode]()
        chapter.content.forEach { (content) in
            switch content {
            case is String:
                let labelNode = SKLabelNode(text: content as? String)
                labelNode.lineBreakMode = .byWordWrapping
                labelNode.numberOfLines = 0
                labelNode.preferredMaxLayoutWidth = 500
                labelNode.fontSize = 45;
                labelNode.fontName = "SignPainter"
                self.storyNodes?.append(labelNode)
            case is UIImage:
                let imageNode = SKSpriteNode(texture: SKTexture(image: content as! UIImage))
                self.storyNodes?.append(imageNode)
            default:
                fatalError("Cannot have objects other than type UIImage or String within Chapter Content Array")
            }
        }
    }
}

class Book : World {
    
    private var storyHandler:StoryHandler?
    private var chapter:BookChapters?
    
    private var groundNodeLocation:SKNode?
    private var contentBottom:SKNode?
    private var contentTop:SKNode?
    
    private let kGroundNodeName = "GROUND_LEVEL"
    private let kContentBottom = "CONTENT_BOTTOM"
    private let kContentTop = "CONTENT_TOP"
    
    func setChapter (chapter: BookChapters) {
        self.chapter = chapter
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
    }
    
    func setup () {
        guard let chapter = self.chapter else {
            fatalError("The chapter object of Book cannot be nil!")
        }
        
        self.groundNodeLocation = self.childNode(withName: self.kGroundNodeName)
        self.contentBottom = self.childNode(withName: self.kContentBottom)
        self.contentTop = self.childNode(withName: self.kContentTop)
        
        self.storyHandler = StoryHandler(chapter: chapter)
        self.addStoryNodes(nodes: self.storyHandler?.storyNodes)
    }
    
    func addStoryNodes (nodes: [SKNode]?) {
        guard let yMax = self.contentTop?.position.y else { fatalError("There is no child node with name CONTENT_TOP and therefore contentTop object is not set") }
        guard let yMin = self.contentBottom?.position.y else { fatalError("There is no child node with name CONTENT_BOTTOM and therefore contentBottom object is not set") }
        guard let yGround = self.groundNodeLocation?.position.y else { fatalError("There is no child node with name GROUND_LEVEL and therefore groundLevel object is not set") }
        guard let nodes = nodes else { return }
        
        // Check to see if the node is going to fit on the screen in the proper place when added.  If not, than go to the new line
        var yPos:CGFloat = yMax
        var xPos:CGFloat = 0
        
        let cameraMinX = SKNode()
        cameraMinX.name = "cameraMinX"
        cameraMinX.position = self.camera!.position
        self.addChild(cameraMinX)
        
        nodes.forEach { (node) in
            if yPos - node.frame.size.height - 20 < yMin {
                yPos = yMax
                xPos += 600
            }
            
            yPos = yPos - node.frame.size.height - 20
            node.position = CGPoint(x: xPos, y: yPos)
            self.addChild(node)
        }
        
        let ground = Ground(size: CGSize(width: xPos + 600, height: 100), anchorPoint: CGPoint(x: 0, y: 0.5))
        ground.pinIt()
        ground.position = CGPoint(x: 0, y: yGround)
        self.addChild(ground)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        self.moveCameraToFollowPlayerXPos()
    }
}
