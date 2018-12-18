//
//  MemeCollectionViewController.swift
//  Meme Me
//
//  Created by João Leite on 10/12/18.
//  Copyright © 2018 João Leite. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var memesArray = [Meme]()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveSavedMemes()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveSavedMemes()
        collectionView.reloadData()
    }
    
    func retrieveSavedMemes(){
        self.memesArray = self.appDelegate.memes
    }
    
}

extension MemeCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionCell", for: indexPath) as! MemeCollectionViewCell
        
        cell.imgMemePreview.image = memesArray[indexPath.row].memeImage
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CollectionViewToMemeDetailSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CollectionViewToMemeDetailSegue"){
            if let index = self.collectionView.indexPathsForSelectedItems?.startIndex {
                let view = segue.destination as! MemeEditorViewController
                view.meme = memesArray[index]
            }
        }
    }
    
}
