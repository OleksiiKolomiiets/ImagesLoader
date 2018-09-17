//
//  ImagesViewController+Drand&Drop.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 9/17/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit
import MobileCoreServices

// MARK: - Drop interaction delegate extension

extension ImagesViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            print(nsurls)
        }
    }
}

// MARK: - Drag interaction delegate extension

extension ImagesViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
    
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        let url = ImageService.getUrlForPhoto(using: (dataSource![indexPath.section].data![indexPath.row]))
        let dragItem = UIDragItem(itemProvider: NSItemProvider(contentsOf: url)!)
        dragItem.localObject = url
        return [dragItem]
    }
}
