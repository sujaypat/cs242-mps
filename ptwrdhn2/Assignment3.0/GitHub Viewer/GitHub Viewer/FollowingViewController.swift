//
//  SecondViewController.swift
//  GitHub Viewer
//
//  Created by Sujay Patwardhan on 10/19/17.
//  Copyright © 2017 Sujay Patwardhan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FollowingViewController: UITableViewController {

    struct Person {
        let userName : String
        let url : URL
        let img : URL
    }
    var people = [Person]()
    var json : JSON = JSON.null;
    var user : String = USER + "/following";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserData(url: user)
    }
    
    func getUserData(url: String) {
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                self.json = JSON(value)
//                print("JSON: \(self.json)")
                self.parseJSON()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func parseJSON(){
        let repoArray = self.json.arrayValue
        for repo in repoArray {
            let name = repo["login"].stringValue
            let url = URL(string: repo["url"].stringValue)
            let imgURL = URL(string: repo["avatar_url"].stringValue)
            let cell = Person(userName: name, url: url!, img: imgURL!)
            people.append(cell)
        }
        
        self.tableView.reloadData()
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let person = people[indexPath.row]
        cell.imageView!.image = UIImage(data: try! Data(contentsOf: person.img))
        cell.textLabel!.text = person.userName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        UIApplication.shared.openURL(people[indexPath.row].url)
    }

}

