//
//  Profile.swift
//  TrackPoint
//
//  Created by Taylor Traviss on 2018-10-25.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class Profile: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    var array = [String]()
    //var medicationName: String
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        
        array.append("testing data")
        array.append("testing data")
        array.append("testing data")
    
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = array[indexPath.row]
        return cell
    }
    

}
