//
//  LogViewController.swift
//  Stress Scanner
//
//  Created by Fauzan Achmad on 19/09/19.
//  Copyright © 2019 Fauzan Achmad. All rights reserved.
//

import UIKit
import CoreData

class LogViewController : UIViewController, UITableViewDelegate
{
    @IBOutlet weak var stressLogTableView: UITableView!
    
    var listItem: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stressLogTableView.delegate = self
        self.stressLogTableView.dataSource = self
        stressLogTableView.register(UINib(nibName: "StressLogTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else
        {
            return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "StressLog")
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        //3
        do
        {
            listItem = try managedContext.fetch(fetchRequest)
            print("Core Data Item Berhasil Fetch")
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

extension LogViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let heartRate = listItem[indexPath.row]
        let stressCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! StressLogTableViewCell
        
        let getHeartDouble : Double = heartRate.value(forKey: "heartRate") as! Double
        let healthConvert: String = String(format: "%.1f",getHeartDouble)
        
        stressCell.stressLevel.text = heartRate.value(forKey: "stressLevel") as? String
        stressCell.healthRate.text = healthConvert
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        stressCell.dateLabel.text = dateFormatter.string(from: heartRate.value(forKey: "date") as! Date)
        
        print(heartRate.value(forKey: "heartRate") as Any)
        
        return stressCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItem.count
    }
    
    
}
