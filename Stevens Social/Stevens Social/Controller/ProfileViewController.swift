//
//  ProfileViewController.swift
//  Stevens Social
//
//  Created by Vincent Porta on 4/13/18.
//  Copyright © 2018 Stevens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var nameHere: UILabel!
    @IBOutlet var profileViewImage: UIImageView!
    @IBOutlet var bioProfileView: UILabel!
    @IBOutlet var numOfFollowers: UILabel!
    @IBOutlet var numOfFollowing: UILabel!
    @IBOutlet var profileViewTableView: UITableView!
    @IBOutlet var followBtnText: UIButton!
    
    var data = ""
    var userPhoto: UIImage?
    var postsArray:[Post] = []
    var isFollowing: Bool = false
    var uid: String?
    var foreignUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            self.uid = user?.uid
        }
        nameHere.text = data
        profileViewImage.contentMode = UIViewContentMode.scaleAspectFit
        profileViewImage.image = userPhoto
        
        profileViewTableView.delegate = self
        profileViewTableView.dataSource = self
        
        self.fetchData()
        self.profileViewTableView.reloadData()
        
        configureTableView()
        self.getFollowing()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postTableCell", for: indexPath) as! PostTableViewCell
        cell.selectionStyle = .none
        
        let post = postsArray[indexPath.row]
        cell.postBody!.text = post.text
        cell.postName!.text = post.created_by
        cell.avatarImageView.contentMode = UIViewContentMode.scaleAspectFit
        cell.avatarImageView!.image = userPhoto
        cell.postBody!.alpha = 0
        cell.postName!.alpha = 0
        cell.avatarImageView!.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            cell.postBody!.alpha = 1
            cell.postName!.alpha = 1
            cell.avatarImageView!.alpha = 1
        })
        
        return cell
    }
    
    func configureTableView() {
        profileViewTableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postTableCell")
        profileViewTableView.rowHeight = UITableViewAutomaticDimension
        profileViewTableView.estimatedRowHeight = 350.0
        
    }
    
    func fetchData(){
        // Search for posts based on created_by field
        let params: Parameters = ["created_by": self.data] //
        Alamofire.request("http://localhost:5000/api/posts/get-username", parameters: params).responseJSON { response in
            
            if (response.result.error != nil) {
                print(response.result.error!)
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                for (_, subJson) in json["result"] {
                    print(subJson)
                    let id: String = subJson["_id"].stringValue
                    let text: String = subJson["text"].stringValue
                    let uid: String = subJson["uuid"].stringValue
                    let likes: Array<Any> = []
                    let created_by: String = subJson["created_by"].stringValue
                    
                    self.postsArray.append(Post(_id: id, text: text, image: nil, uuid: uid, likes: likes, created_by: created_by))
                    
                    self.foreignUid = uid
                    print("foreign id is here: " + self.foreignUid!)
                }
                
                DispatchQueue.main.async {
                    self.profileViewTableView.reloadData()
                }
                print(self.postsArray.reverse())
            }
        }
        
    }
    
    func followUser() {
        
        let parameters: Parameters = [
            "uuid": self.uid!,
            "foreign_uuid": self.foreignUid!
//            "uuid": "000002",
//            "foreign_uuid": "000001"
        ]
        
        Alamofire.request("http://localhost:5000/api/follow", method: .put, parameters: parameters, encoding: JSONEncoding.default)

    }
    
    func unfollowUser() {
        
        let parameters: Parameters = [
            "uuid": self.uid!,
            "foreign_uuid": self.foreignUid!
//            "uuid": "000002",
//            "foreign_uuid": "000001"
        ]
        
        Alamofire.request("http://localhost:5000/api/unfollow", method: .put, parameters: parameters, encoding: JSONEncoding.default)
        
    }
    
    func getFollowing() {
        let params: Parameters = ["uuid": self.uid!] // replace string with Firebase uid!
        Alamofire.request("http://localhost:5000/api/get/follow", parameters: params).responseJSON { response in
            
            if (response.result.error != nil) {
                print(response.result.error!)
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                
                let arr = json["result"]["follow"]
                print("getFollowing")
                
                for id in arr {

                    if (id.1.stringValue == self.foreignUid) {
                        print("true")
                        self.isFollowing = true

                    } else {
                        print("false")
                        self.isFollowing = false

                    }
                    
                }
            }
        }
    }
    
    @IBAction func profileViewFollowBtn(_ sender: UIButton) {
        print("follow button pressed")
        if isFollowing == false {
            followBtnText.setTitle("Following", for: UIControlState.normal)
            isFollowing = true
            followUser()
        } else if isFollowing == true {
            followBtnText.setTitle("Follow", for: UIControlState.normal)
            isFollowing = false
            unfollowUser()
        }
    }
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
