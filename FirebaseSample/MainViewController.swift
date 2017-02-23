//
//  MainViewController.swift
//  FirebaseSample
//
//  Created by Moritz Sternemann on 23.02.17.
//  Copyright © 2017 Moritz Sternemann. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MainViewController: UITableViewController {
    
    var handle: FIRAuthStateDidChangeListenerHandle?
    var ref: FIRDatabaseReference!
    
    var myData: [String: String] = [:] {
        didSet {
            myData_keys = Array(myData.keys)
        }
    }
    var myData_keys: [String] = []
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userUIDLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRDatabase.database().persistenceEnabled = true
        
        ref = FIRDatabase.database().reference()
        
        // Auth stuff
        handle = FIRAuth.auth()?.addStateDidChangeListener() { auth, user in
            if user == nil {
                self.navigationController?.performSegue(withIdentifier: "signin", sender: self)
            } else {
                self.setupData(withUser: user!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupData(withUser user: FIRUser) {
        guard let user = FIRAuth.auth()?.currentUser else { return }
        
        ref.child("myData").child(user.uid).observe(.value, with: { snapshot in
            self.myData = snapshot.value as? [String: String] ?? [:]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        userEmailLabel.text = user.email!
        userUIDLabel.text = user.uid
        
        if let photoURL = user.photoURL {
            DispatchQueue.global(qos: .default).async {
                let data = try? Data.init(contentsOf: photoURL)
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                    }
                }
            }
        }
    }
    
    @IBAction func didTapSignout(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let error {
            print("Error on signout: \(error.localizedDescription)")
        }
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        let alert = UIAlertController(title: "Add Data", message: "Enter some data", preferredStyle: .alert)
        
        alert.addTextField() { textfield in
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak alert] _ in
            guard let textField = alert?.textFields?[0] else { return }
            guard let text = textField.text else { return }
            guard !text.isEmpty else { return }
            guard let user = FIRAuth.auth()?.currentUser else { return }
            
            // Save text
            self.ref.child("myData").child(user.uid).childByAutoId().setValue(text)
        })
        
        self.present(alert, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData_keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let key = myData_keys[indexPath.row]
        let data = myData[key]
        
        cell.textLabel?.text = data ?? ""
        cell.detailTextLabel?.text = key

        return cell
    }

}
