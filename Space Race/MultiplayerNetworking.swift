//
//  MultiplayerNetworking.swift
//  CatRaceStarter
//
//  Created by Jason Wong on 11/20/14.
//  Copyright (c) 2014 Raywenderlich. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

let playerIDKey = "PlayerID"
let randomNumberKey = "randomNumber"

protocol MultiplayerNetworkingProtocol {
    func matchEnded()
    func setCurrentPlayerIndex(index : Int)
    func movePlayerAtIndex(index : Int)
    func gameOver(player1Won : Bool)
    func movePlayerTo(x:UInt32, distance:Int, accel: Double)
    func sendSKSpriteNodes()
    func setSKSpriteNodes(arr:NSMutableArray)
    func setSyncLock(time: UInt32)
    func setWait(wait: Bool)
    func processCollision(type: Collision, index : Int)
    
    func setShipType(shipType: String)
}

enum MessageType : Int {
    case kMessageTypeRandomNumber = 0
    case kMessageTypeGameBegin
    case kMessageTypeMove
    case kMessageTypeGameOver
    case kMessageTypeSyncLock
    case kMessageTypeCollision
    case kMessageTypeWait
    case kMessageTypeShipType
}

enum GameState : Int {
    case kGameStateWaitingForMatch = 0
    case kGameStateWaitingForRandomNumber
    case kGameStateWaitingForStart
    case kGameStateActive
    case kGameStateDone
}

enum ShipType : Int {
    case ship1
    case ship2
    case ship3
    case ship4
    case ship5
    case ship6
}

enum Collision : Int {
    case star
    case energy
    case asteroid
}

struct Message {
    var messageType : MessageType
}

struct MessageRandomNumber {
    var message : Message
    var randomNumber : UInt32
}

struct MessageGameBegin {
    var message : Message
}

struct MessageMove {
    var message: Message
    var x : UInt32
    // THIS IS ACTUALLY SPEED
    var distance : Int
    var accel : Double
}

struct MessageSyncLock {
    var message: Message
    var time : UInt32
}

struct MessageCollision {
    var message: Message
    var type : Collision
    var index : Int
}

struct MessageWait {
    var message: Message
    var wait: Bool
}
struct MessageGameOver {
    var message : Message
    var player1Won : Bool
}
struct MessageShipType {
    var message : Message
    var shipType : ShipType
}


@objc class MultiplayerNetworking : NSObject, GameKitHelperDelegate {
    var delegate : MultiplayerNetworkingProtocol?
    var _ourRandomNumber : UInt32!
    var _gameState : GameState?
    var _isPlayer1 = false
    var _receivedAllRandomNumbers = false
    var _orderOfPlayers : NSMutableArray!
    var previousTime : UInt32 = 0
    
    
    override init() {
        super.init()
        
        _ourRandomNumber = arc4random()
        _gameState = GameState.kGameStateWaitingForMatch
        _orderOfPlayers = NSMutableArray()
        
        // Create a dictionary and add it to the orderOfPlayers array
        var dict = ["\(playerIDKey)":"\(GKLocalPlayer.localPlayer().playerID)", "\(randomNumberKey)":"\(_ourRandomNumber)"]
        _orderOfPlayers.addObject(dict)
    }
    
    
    func sendRandomNumber() {
        var message = Message(messageType: MessageType.kMessageTypeRandomNumber)
        
        var MessageRandomNum =  MessageRandomNumber(message: message, randomNumber: _ourRandomNumber!)
        
        let data = NSData(bytes: &MessageRandomNum, length: sizeof(MessageRandomNumber))
        self.sendData(data)
    }
    
    func sendGameBegin() {
        var message = Message(messageType: MessageType.kMessageTypeGameBegin)
        var MessageGameBeg = MessageGameBegin(message: message)
        var data = NSData(bytes: &MessageGameBeg, length: sizeof(MessageGameBegin))
        self.sendData(data)
    }
    
    func sendGameEnd(player1Won : Bool) {
        println("SENDING END GAME!!!")
        var message = Message(messageType: MessageType.kMessageTypeGameOver)
        var messageGameOver = MessageGameOver(message: message, player1Won: player1Won)
        var data = NSData(bytes: &messageGameOver, length: sizeof(MessageGameOver))
        self.sendData(data)
    }
    
    func sendMove(x:UInt32, distance:Int, accel: Double) {
        var message = Message(messageType: MessageType.kMessageTypeMove)
        var messageMove = MessageMove(message: message, x: x, distance: distance, accel: accel)
        var data = NSData(bytes: &messageMove, length: sizeof(MessageMove))
        self.sendData(data)
    }
    
    func sendSKSpriteNodes(arr: NSMutableArray) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(arr)
        println("Sending data of length: \(data.length)")
        self.sendData(data)
    }
    
    func sendSyncLock(time:UInt32) {
        var message = Message(messageType: MessageType.kMessageTypeSyncLock)
        var messageSyncLock = MessageSyncLock(message: message, time: time)
        var data = NSData(bytes: &messageSyncLock, length: sizeof(MessageSyncLock))
        
        self.sendData(data)
    }
    
    func sendCollision(type: Collision, index : Int) {
        var message = Message(messageType: MessageType.kMessageTypeCollision)
        var messageCollision = MessageCollision(message: message, type: type, index: index)
        var data = NSData(bytes: &messageCollision, length: sizeof(MessageCollision))
        self.sendData(data)
    }
    
    func sendWait(wait: Bool) {
        var message = Message(messageType: MessageType.kMessageTypeWait)
        var messageWait = MessageWait(message: message, wait: wait)
        var data = NSData(bytes: &messageWait, length: sizeof(MessageWait))
        self.sendData(data)
    }
    
    func sendShipType(shipType: String) {
        var message = Message(messageType: MessageType.kMessageTypeShipType)
        
        var name:ShipType!
        
        if shipType == "Ship1" {
            name = ShipType.ship1
        } else if shipType == "Ship2" {
            name = ShipType.ship2
        } else if shipType == "Ship3" {
            name = ShipType.ship3
        } else if shipType == "Ship4" {
            name = ShipType.ship4
        } else if shipType == "Ship5" {
            name = ShipType.ship5
        } else if shipType == "Ship6" {
            name = ShipType.ship6
        }
        
        var messageShipType = MessageShipType(message: message, shipType: name)
        
        var data = NSData(bytes: &messageShipType, length: sizeof(MessageShipType))
        self.sendData(data)
    }
    
    func sendData(data : NSData) {
        
        var error : NSError?
        
        let gameKitHelper = GameKitHelper.SharedGameKitHelper
        if(gameKitHelper._match == nil) {
            return
        }
        
        var success = gameKitHelper._match.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Reliable, error: &error)
        /*CHECK HERE IF ERROR */
        if(success == false) {
            println("Error sending data: \(error?.localizedDescription)")
            self.matchEnded()
        }
    }
    
    
    
    func indexForLocalPlayer() -> Int {
        var playerID = GKLocalPlayer.localPlayer().playerID
        return self.indexForPlayerWithId(playerID)
    }
    func indexForPlayerWithId(playerId : String) -> Int {
        var index = -1
        _orderOfPlayers.enumerateObjectsUsingBlock( {object, ind, stop in
            
            var pId = object[playerIDKey] as String
            
            if(pId == playerId) {
                index = ind
                stop.initialize(true)
            }
            
            
        })
        return index
    }
    
    func setCurrentPlayerIndex(index : Int) {
        
    }
    
    func tryStartGame() {
        if(_isPlayer1 && _gameState == GameState.kGameStateWaitingForStart) {
            _gameState = GameState.kGameStateActive
            self.delegate?.sendSKSpriteNodes()
        }
    }
    
    func matchStarted() {
        println("Match has started successfully")
        if(_receivedAllRandomNumbers) {
            _gameState = GameState.kGameStateWaitingForStart
        }
        else {
            _gameState = GameState.kGameStateWaitingForRandomNumber;
            
        }
        self.sendRandomNumber()
        
        self.tryStartGame()
        
    }
    
    func matchEnded() {
        println("Match has ended")
        delegate?.matchEnded()
    }
    
    func match(match:GKMatch, didReceiveData data: NSData!, fromPlayer playerID: NSString!) {
        
        if(data.length > 200) {
            let arr = NSKeyedUnarchiver.unarchiveObjectWithData(data) as NSMutableArray
            self.delegate?.setSKSpriteNodes(arr)
            self.sendGameBegin()
            self.delegate?.setCurrentPlayerIndex(0)
            
            return
        }
        
        let message = UnsafePointer<Message>(data.bytes).memory
        
        if(message.messageType == MessageType.kMessageTypeRandomNumber) {
            let messageRandomNumber = UnsafePointer<MessageRandomNumber>(data.bytes).memory
            
            var tie = false
            
            if(messageRandomNumber.randomNumber == _ourRandomNumber) {
                println("Tie")
                tie = true
                _ourRandomNumber = arc4random()
                self.sendRandomNumber()
            }
            else {
                var dictionary = ["\(playerIDKey)":"\(playerID)", "\(randomNumberKey)":"\(messageRandomNumber.randomNumber)"]
                self.processReceivedRandomNumber(dictionary)
            }
            
            if(_receivedAllRandomNumbers) {
                _isPlayer1 = self.isLocalPlayerPlayer1()
            }
            
            if(!tie && _receivedAllRandomNumbers) {
                if(_gameState == GameState.kGameStateWaitingForRandomNumber) {
                    _gameState = GameState.kGameStateWaitingForStart
                }
                self.tryStartGame()
            }
        }
        else if(message.messageType == MessageType.kMessageTypeGameBegin) {
            println("Begin game message received")
            _gameState = GameState.kGameStateActive
            self.delegate?.setCurrentPlayerIndex(self.indexForLocalPlayer())
        }
        else if(message.messageType == MessageType.kMessageTypeMove) {
            let messageMove = UnsafePointer<MessageMove>(data.bytes).memory
            let x = messageMove.x
            let distance = messageMove.distance
            let accel = messageMove.accel
            self.delegate?.movePlayerTo(x, distance: distance, accel: accel)
        }
        else if(message.messageType == MessageType.kMessageTypeSyncLock) {
            let messageSyncLock = UnsafePointer<MessageSyncLock>(data.bytes).memory
            var time = messageSyncLock.time
            if (time == previousTime){
                time = previousTime + 1
                previousTime = time
            }
            println(messageSyncLock)
            println("RECEIVED SYNCLOCK: \(time)")
            self.delegate?.setSyncLock(time)
        }
        else if(message.messageType == MessageType.kMessageTypeCollision) {
            let messageCollision = UnsafePointer<MessageCollision>(data.bytes).memory
            let type = messageCollision.type
            let index = messageCollision.index
            self.delegate?.processCollision(type, index: index)
        }
        else if(message.messageType == MessageType.kMessageTypeWait) {
            let messageWait = UnsafePointer<MessageWait>(data.bytes).memory
            let wait = messageWait.wait
            self.delegate?.setWait(wait)
        }
        else if(message.messageType == MessageType.kMessageTypeShipType) {
            println("Ship Type message received")
            let messageShipType = UnsafePointer<MessageShipType>(data.bytes).memory
           
            var shipName:String!
            let type = messageShipType.shipType
            if type == ShipType.ship1 {
                shipName = "Ship1"
            } else if type == ShipType.ship2 {
                shipName = "Ship2"
            } else if type == ShipType.ship3 {
                shipName = "Ship3"
            } else if type == ShipType.ship4 {
                shipName = "Ship4"
            } else if type == ShipType.ship5 {
                shipName = "Ship5"
            } else if type == ShipType.ship6 {
                shipName = "Ship6"
            }
            
            self.delegate?.setShipType(shipName)
        }
        else if(message.messageType == MessageType.kMessageTypeGameOver) {
            println("Game over message received")
            let messageGameOver = UnsafePointer<MessageGameOver>(data.bytes).memory
            self.delegate?.gameOver(messageGameOver.player1Won)
        }
    }
    
    func processReceivedRandomNumber(randomNumberDetails:NSDictionary) {
        
        if(_orderOfPlayers.containsObject(randomNumberDetails)) {
            _orderOfPlayers.removeObjectAtIndex(_orderOfPlayers.indexOfObject(randomNumberDetails))
        }
        _orderOfPlayers.addObject(randomNumberDetails)
        
        var sortByRandomNumber = NSSortDescriptor(key:randomNumberKey, ascending: false)
        var sortDescriptors = [sortByRandomNumber]
        _orderOfPlayers.sortUsingDescriptors(sortDescriptors)
        
        if(self.allRandomNumbersAreReceived()) {
            _receivedAllRandomNumbers = true
        }
    }
    
    func allRandomNumbersAreReceived() -> Bool {
        var receivedRandomNumbers = NSMutableArray()
        
        for dict in _orderOfPlayers {
            receivedRandomNumbers.addObject(dict[randomNumberKey] as String)
        }
        
        var set = NSSet()
        
        var arrayOfUniqueRandomNumbers = set.setByAddingObjectsFromArray(receivedRandomNumbers).allObjects
        
        if(arrayOfUniqueRandomNumbers.count == GameKitHelper.SharedGameKitHelper._match.playerIDs.count + 1) {
            return true
        }
        return false
        
    }
    
    func isLocalPlayerPlayer1() -> Bool {
        var dictionary = _orderOfPlayers[0] as NSDictionary
        if((dictionary[playerIDKey] as String) ==  (GKLocalPlayer.localPlayer().playerID)) {
            println("I am player 1")
            return true
        }
        return false
    }
    
}

// old
//
//  MultiplayerNetworking.swift
//  CatRaceStarter
//
//  Created by Jason Wong on 11/20/14.
//  Copyright (c) 2014 Raywenderlich. All rights reserved.
//

/*import Foundation
import GameKit

let playerIDKey = "PlayerID"
let randomNumberKey = "randomNumber"

@objc protocol MultiplayerNetworkingProtocol {
    func matchEnded()
    func setCurrentPlayerIndex(index : Int)
    func movePlayerAtIndex(index : Int)
    func gameOver(player1Won : Bool)
    func movePlayerTo(x:UInt32, distance:Double)
//    func startMatch()
}

enum MessageType : Int {
    case kMessageTypeRandomNumber = 0
    case kMessageTypeGameBegin
    case kMessageTypeMove
    case kMessageTypeGameOver
}

enum GameState : Int {
    case kGameStateWaitingForMatch = 0
    case kGameStateWaitingForRandomNumber
    case kGameStateWaitingForStart
    case kGameStateActive
    case kGameStateDone
}

struct Message {
    var messageType : MessageType
}

struct MessageRandomNumber {
    var message : Message
    var randomNumber : UInt32
}

struct MessageGameBegin {
    var message : Message
}

struct MessageMove {
    var message: Message
    var x : UInt32
    var distance : Double
}

struct MessageGameOver {
    var message : Message
    var player1Won : Bool
}


@objc class MultiplayerNetworking : NSObject, GameKitHelperDelegate {
    var delegate : MultiplayerNetworkingProtocol?
    var _ourRandomNumber : UInt32!
    var _gameState : GameState?
    var _isPlayer1 = false
    var _receivedAllRandomNumbers = false
    var _orderOfPlayers : NSMutableArray!

    
    override init() {
        super.init()
        
        _ourRandomNumber = arc4random()
        _gameState = GameState.kGameStateWaitingForMatch
        _orderOfPlayers = NSMutableArray()
        
        // Create a dictionary and add it to the orderOfPlayers array
        var dict = ["\(playerIDKey)":"\(GKLocalPlayer.localPlayer().playerID)", "\(randomNumberKey)":"\(_ourRandomNumber)"]
        _orderOfPlayers.addObject(dict)
    }
    
    
    func sendRandomNumber() {
        var message = Message(messageType: MessageType.kMessageTypeRandomNumber)
        
        var MessageRandomNum =  MessageRandomNumber(message: message, randomNumber: _ourRandomNumber!)
        
        let data = NSData(bytes: &MessageRandomNum, length: sizeof(MessageRandomNumber))
        self.sendData(data)
    }
    
    func sendGameBegin() {
        var message = Message(messageType: MessageType.kMessageTypeGameBegin)
        var MessageGameBeg = MessageGameBegin(message: message)
        var data = NSData(bytes: &MessageGameBeg, length: sizeof(MessageGameBegin))
        self.sendData(data)
    }
    
    func sendGameEnd(player1Won : Bool) {
        var message = Message(messageType: MessageType.kMessageTypeGameOver)
        var messageGameOver = MessageGameOver(message: message, player1Won: player1Won)
        var data = NSData(bytes: &messageGameOver, length: sizeof(MessageGameOver))
        self.sendData(data)
    }
    
    func sendMove(x:UInt32, distance:Double) {
        var message = Message(messageType: MessageType.kMessageTypeMove)
        var messageMove = MessageMove(message: message, x: x, distance: distance)
        var data = NSData(bytes: &messageMove, length: sizeof(MessageMove))
        self.sendData(data)
    }
    
    func sendData(data : NSData) {

        var error : NSError?
        
        let gameKitHelper = GameKitHelper.SharedGameKitHelper
        if(gameKitHelper._match == nil) {
            return
        }
        
        var success = gameKitHelper._match.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Reliable, error: &error)
        /*CHECK HERE IF ERROR */
        if(success == false) {
            println("Error sending data: \(error?.localizedDescription)")
            self.matchEnded()
        }
    }
    
    func indexForLocalPlayer() -> Int {
        var playerID = GKLocalPlayer.localPlayer().playerID
        return self.indexForPlayerWithId(playerID)
    }
    func indexForPlayerWithId(playerId : String) -> Int {
        var index = -1
        _orderOfPlayers.enumerateObjectsUsingBlock( {object, ind, stop in
            
            var pId = object[playerIDKey] as String
            
            if(pId == playerId) {
                index = ind
                stop.initialize(true)
            }
            
            
        })
        return index
    }
    
    func setCurrentPlayerIndex(index : Int) {
        
    }
    
    func tryStartGame() {
        if(_isPlayer1 && _gameState == GameState.kGameStateWaitingForStart) {
            _gameState = GameState.kGameStateActive
            self.sendGameBegin()
            self.delegate?.setCurrentPlayerIndex(0)
        }
        
    }
    
    func matchStarted() {
        println("Match has started successfully")
        if(_receivedAllRandomNumbers) {
            _gameState = GameState.kGameStateWaitingForStart
        }
        else {
            _gameState = GameState.kGameStateWaitingForRandomNumber;

        }
        self.sendRandomNumber()

        self.tryStartGame()

    }

    func matchEnded() {
        println("Match has ended")
        delegate?.matchEnded()
    }
    
    func match(match:GKMatch, didReceiveData data: NSData!, fromPlayer playerID: NSString!) {
        
        let message = UnsafePointer<Message>(data.bytes).memory

        if(message.messageType == MessageType.kMessageTypeRandomNumber) {
            let messageRandomNumber = UnsafePointer<MessageRandomNumber>(data.bytes).memory
            
            println("Received random number: \(messageRandomNumber.randomNumber)")
            
            var tie = false
            
            if(messageRandomNumber.randomNumber == _ourRandomNumber) {
                println("Tie")
                tie = true
                _ourRandomNumber = arc4random()
                self.sendRandomNumber()
            }
            else {
                var dictionary = ["\(playerIDKey)":"\(playerID)", "\(randomNumberKey)":"\(messageRandomNumber.randomNumber)"]
                self.processReceivedRandomNumber(dictionary)
            }
            
            if(_receivedAllRandomNumbers) {
                _isPlayer1 = self.isLocalPlayerPlayer1()
            }
            
            if(!tie && _receivedAllRandomNumbers) {
                if(_gameState == GameState.kGameStateWaitingForRandomNumber) {
                    _gameState = GameState.kGameStateWaitingForStart
                }
                self.tryStartGame()
            }
        }
        else if(message.messageType == MessageType.kMessageTypeGameBegin) {
            println("Begin game message received")
            _gameState = GameState.kGameStateActive
            self.delegate?.setCurrentPlayerIndex(self.indexForLocalPlayer())
        }
        else if(message.messageType == MessageType.kMessageTypeMove) {
            //println("Move message received")
            let messageMove = UnsafePointer<MessageMove>(data.bytes).memory
            let x = messageMove.x
            let distance = messageMove.distance
            //self.delegate?.movePlayerAtIndex(self.indexForPlayerWithId(playerID))
            self.delegate?.movePlayerTo(x, distance: distance)
        }
        else if(message.messageType == MessageType.kMessageTypeGameOver) {
            println("Game over message received")
            let messageGameOver = UnsafePointer<MessageGameOver>(data.bytes).memory
            self.delegate?.gameOver(messageGameOver.player1Won)
        }
        
        //(message as Message).messageType
        
    }
    
    func processReceivedRandomNumber(randomNumberDetails:NSDictionary) {
        
        if(_orderOfPlayers.containsObject(randomNumberDetails)) {
            _orderOfPlayers.removeObjectAtIndex(_orderOfPlayers.indexOfObject(randomNumberDetails))
        }
        _orderOfPlayers.addObject(randomNumberDetails)
        
        var sortByRandomNumber = NSSortDescriptor(key:randomNumberKey, ascending: false)
        var sortDescriptors = [sortByRandomNumber]
        _orderOfPlayers.sortUsingDescriptors(sortDescriptors)
        
        if(self.allRandomNumbersAreReceived()) {
            _receivedAllRandomNumbers = true
        }
    }
    
    func allRandomNumbersAreReceived() -> Bool {
        var receivedRandomNumbers = NSMutableArray()
        
        for dict in _orderOfPlayers {
            receivedRandomNumbers.addObject(dict[randomNumberKey] as String)
        }
        
        var set = NSSet()
        
        var arrayOfUniqueRandomNumbers = set.setByAddingObjectsFromArray(receivedRandomNumbers).allObjects
        
        if(arrayOfUniqueRandomNumbers.count == GameKitHelper.SharedGameKitHelper._match.playerIDs.count + 1) {
            return true
        }
        return false

    }
    
    func isLocalPlayerPlayer1() -> Bool {
        var dictionary = _orderOfPlayers[0] as NSDictionary
        if((dictionary[playerIDKey] as String) ==  (GKLocalPlayer.localPlayer().playerID)) {
            println("I am player 1")
            return true
        }
        return false
    }
}*/