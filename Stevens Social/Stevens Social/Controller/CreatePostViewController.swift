//
//  CreatePostViewController.swift
//  Stevens Social
//
//  Created by Vincent Porta on 3/14/18.
//  Copyright © 2018 Stevens. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import MobileCoreServices


class CreatePostViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    let imagePickerController = UIImagePickerController()
    
    @IBOutlet var postBody: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Allows us to use the delegate
        postBody.delegate = self

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPost(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func confirmPost(_ sender: UIButton) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                if self.postBody?.text != "" {
                    let myAPI = API(customRoute: "https://stevens-social-app.herokuapp.com/api/new/post", customMethod: "POST")
                    myAPI.sendRequest(parameters: ["uuid": user.uid, "text": self.postBody!.text!]) // insert real uuid from firebase
                } else {
                    print("Please enter text in the Post Box!")
                }
            }
        }
        performSegue(withIdentifier: "postSuccess", sender: self)
        

    }

}

