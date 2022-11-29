//
//  CAChatViewController.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 26.10.2022.
//



import UIKit

private let reuseIdentifier = "MessageCell"

class CAChatViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    let sender = PushNotificationSender()

    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
        
    private let user: User
    private var messages = [Message]()
    var fromCurrentUser = false

    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: view.frame.width,
                                                        height: 50))
        iv.delegate = self
        return iv
    }()
    
    // MARK: - LifeCycle

    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages()
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - API
    
    func fetchMessages() {
        
        showLoader(true)
        
        Service.fetchMessage(forUser: user) { message in
            self.showLoader(false)
            self.messages = message
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.messages.count - 1],
                                             at: .bottom,
                                             animated: true)
            self.collectionView.alwaysBounceVertical = true
            self.collectionView.keyboardDismissMode  = .interactive
        }
        self.showLoader(false)
        
    }
        
    // MARK: - Helpers
    
    func configureUI() {
        collectionView.backgroundColor = .systemBackground
        configureNavigationBar(withTitle: user.username, prefLargeTitles: false)
        
        collectionView.register(CAMessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
    }
}

// MARK: - UICollectionViewDataSource

extension CAChatViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CAMessageCell
        cell.delegate = self
        cell.message = messages[indexPath.row]
        
        print("Heyyo: \( messages[indexPath.row].imageUrl.isEmpty)")
        let messagee = messages[indexPath.row]

        if !messagee.imageUrl.isEmpty {
            cell.message?.user = user
            cell.messageImageView.isHidden = false
            cell.messageImageView.backgroundColor = .clear
        } else {
            cell.message?.user = user
            cell.messageImageView.isHidden = true
            

        }
        return cell
    }
}

// MARK: -UICollectionViewDelegateFlowLayout

extension CAChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                        
        let message = messages[indexPath.item]
        
        if !message.imageUrl.isEmpty {
            let frame = CGRect(x: 0,
                               y: 0,
                               width: view.frame.width,
                               height: view.frame.height)
            
            let estimateCell = CAMessageCell(frame: frame)
            estimateCell.bubbleContainer.setDimensions(width: 250, height: 180)
            estimateCell.messageImageView.setHeight(height: 180)
            estimateCell.layoutIfNeeded()
            
            let targetSize = CGSize(width: view.frame.width, height: 180)
            let estimatedSize = estimateCell.systemLayoutSizeFitting(targetSize)

            return .init(width: view.frame.width, height: estimatedSize.height)
        } else {
            let frame = CGRect(x: 0,
                               y: 0,
                               width: view.frame.width,
                               height: 50)
            let estimatedSizeCell     = CAMessageCell(frame: frame)
            estimatedSizeCell.message = messages[indexPath.row]
            estimatedSizeCell.layoutIfNeeded()

            let targetSize = CGSize(width: view.frame.width, height: 1000)
            let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)

            return .init(width: view.frame.width, height: estimatedSize.height)
        }
    }
}

// MARK: - CustomInputAccessoryViewDelegate

extension CAChatViewController: CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        Service.uploadMessage(message, to: user) { error in
            if let error = error {
                print("DBUGE: fails to upload message with error: \(error.localizedDescription)")
                return
            }
            
            self.sender.sendPushNotification(to: self.user.fcmToken, title: self.user.username, body: message)
            inputView.clearMessageText()
            
        }
    }
    
    func inputImageView(wantsToSendImage image: UIImage){
        
        Service.sendImageMessage(image, to: user) { error in
            if let error = error {
                print("DBUGE: fails to upload image with error: \(error.localizedDescription)")
                return
            }
            
            self.sender.sendPushNotification(to: self.user.fcmToken, title: self.user.username, body: NSLocalizedString("Bir fotoğraf gönderdi.", comment: ""))
        }
    }
}

// MARK: - MessageCellViewDelegate

extension CAChatViewController: MessageCellViewDelegate {
    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
            
            self.startingImageView = startingImageView
            self.startingImageView?.isHidden = true
            
            startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
            
            let zoomingImageView = UIImageView(frame: startingFrame!)
            zoomingImageView.backgroundColor = UIColor.red
            zoomingImageView.image = startingImageView.image
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
            if let keyWindow = UIApplication.shared.keyWindow {
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = UIColor.black
                blackBackgroundView?.alpha = 0
                keyWindow.addSubview(blackBackgroundView!)
                
                keyWindow.addSubview(zoomingImageView)
                
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: 1,
                               options: .curveEaseOut,
                               animations: {
                                
                                self.blackBackgroundView?.alpha = 1
                                self.customInputView.alpha = 0
                    
                                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                    
                                zoomingImageView.frame = CGRect(x: 0,
                                                                y: 0,
                                                                width: keyWindow.frame.width,
                                                                height: height)
                    
                                zoomingImageView.center = keyWindow.center
                    
                               }, completion: { (completed) in
                                
                               }
                )
            }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                           animations: {
                
                            zoomOutImageView.frame = self.startingFrame!
                            self.blackBackgroundView?.alpha = 0
                            self.customInputView.alpha = 1
                
                           }, completion: { (completed) in
                            zoomOutImageView.removeFromSuperview()
                            self.startingImageView?.isHidden = false
                           }
            )
        }
    }
}
