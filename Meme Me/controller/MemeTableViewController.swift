//
//  MemeTableViewController.swift
//  Meme Me
//
//  Created by João Leite on 03/12/18.
//  Copyright © 2018 João Leite. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController {
    
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     var memesArray = [Meme]()

    @IBOutlet weak var tblMemes: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMemes.delegate = self
        tblMemes.dataSource = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        retrieveSavedMemes()
        tblMemes.reloadData()
    }
    
    func retrieveSavedMemes(){
        self.memesArray = self.appDelegate.memes
    }

}

// MARK: - UITableViewDelegate and DataSource Methods
extension MemeTableViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "MemeTableViewRow") as! MemeTableViewCell
        
        cell.imgMeme.image = memesArray[indexPath.row].memeImage
        cell.lblText.text = "\(memesArray[indexPath.row].topLabel) \(memesArray[indexPath.row].bottomLabel)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "TableViewToMemeDetailSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TableViewToMemeDetailSegue"){
            let view = segue.destination as! MemeEditorViewController
            if let index = self.tblMemes.indexPathForSelectedRow?.row {
                view.meme = memesArray[index]
            }
        }
    }
}
