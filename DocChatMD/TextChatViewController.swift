//
//  TextChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-29.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController

enum TextChatError: ErrorType {
    
    case InvalidTextSession
    case MessageNotUpdated
}

typealias SessionTextCompletion     = (result: Result<OTSession>) -> Void
typealias UpdateMessagesCompletion  = (result: Result<UIViewController>) -> Void

final class TextChatViewController: JSQMessagesViewController {
    
    private var currentSession: OTSession?
    private var sessionTextCompletion: SessionTextCompletion?
    private var updateMessagesCompletion: UpdateMessagesCompletion?
    
    private var messages = [JSQMessage]()
    private var outgoingBubbleImageView: JSQMessagesBubbleImage!
    private var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // JSQMessagesViewController requires a sender id and display name for use
        self.senderId           = "localUser"
        self.senderDisplayName  = ""
        
        setupChatBubbles()
    }
    
    
    // MARK: OpenTok Session Methods
    
    func enableTextChatInSession(session: OTSession?) {
        
        guard let session = session else {
            
            sessionTextCompletion?(result: Result.failure(error: TextChatError.InvalidTextSession))
            sessionTextCompletion = nil
            return
        }
        
        currentSession = session
    }
    
    func updateMessagesWithController(controller: OpenTokController) {
        
        controller.messageReceivedClosure = { text, isLocal in
            
            guard let text = text else {
                
                self.updateMessagesCompletion?(result: Result.failure(error: TextChatError.MessageNotUpdated))
                self.updateMessagesCompletion = nil
                return
            }
            
            self.addMessage(self.senderId, text: text)
            self.finishReceivingMessage()
        }
    }
    
    
    // MARK: Message Display, Addition & Removal
    
    private func setupChatBubbles() {
        
        let factory             = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    private func addMessage(id: String, text: String) {
        
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    func removePreviousChatMessages() {
        
        if messages.count >= 1 {
            
            self.collectionView.performBatchUpdates({
                
                let indexPaths = self.collectionView.indexPathsForVisibleItems()
                self.messages.removeAll()
                self.collectionView.deleteItemsAtIndexPaths(indexPaths)
                
            }) { (Bool) in
                
                self.collectionView.reloadData()
            }
        }
    }
        
    
    // MARK: JSQMessagesViewController Overrides
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
       
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return nil
    }
        
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        // send message through OpenTok session
        OpenTokTextChatController().sendChatMessageInSession(currentSession!, message: text)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
}