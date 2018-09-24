//
//  ImagesViewController+Drand&Drop.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/17/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MobileCoreServices

//===================================
// MARK: - Drop interaction delegate:
//===================================

extension ImagesViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {  
        session.loadObjects(ofClass: NSString.self) { nsstrings in
            // parsing sended string
            let string = nsstrings.first as! String
            let stringArray = string.split(separator: " ")
            let section = Int(String(stringArray.first!))
            let row = Int(String(stringArray.last!))
            self.draggedItem = IndexPath(row: row!, section: section!)
        }
    }
}

//===================================
// MARK: - Drag interaction delegate:
//===================================

extension ImagesViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        dropZoneView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        dropZoneView.isHidden = false
    }
    
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        let item = "\(indexPath.section) \(indexPath.row)" // create string to send via drag
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}



