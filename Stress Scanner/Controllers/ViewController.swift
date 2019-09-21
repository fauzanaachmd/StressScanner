//
//  ViewController.swift
//  Stress Scanner
//
//  Created by Fauzan Achmad on 19/09/19.
//  Copyright © 2019 Fauzan Achmad. All rights reserved.
//

import UIKit
import HealthKit
import LocalAuthentication
import UserNotifications
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var stressScanBtn: UIButton!
    @IBOutlet weak var heartRateText: UITextView!
    @IBOutlet weak var sleepAnalysisText: UITextView!
    @IBOutlet weak var moodImageView: UIImageView!
    
    let healthStore = HKHealthStore()
    let mood = ["flat", "happy", "stressful"]
    let notificationCenter = UNUserNotificationCenter.current()
    var stressLevel : String = "Normal"
//    var stressLog : [StressLog] = []
    var hr : Double = 40.0
    var listStress: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        checkIfHealthKitAvailable()
        
        readHealthData() // init read health data
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(readHealthData), userInfo: nil, repeats: true)
        
        readSleepAnalysis() // init read sleep analysis
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(readSleepAnalysis), userInfo: nil, repeats: true)
        
        imageAnimation() // init image animation
        Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(imageAnimation), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    @IBAction func addToLogBtn(_ sender: Any) {
        saveToCoreData()
    }
    
    func saveToCoreData()
    {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else
        {
            return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "StressLog",
                                       in: managedContext)!
        
        let aktivitasKeCoreData = NSManagedObject(entity: entity,
                                                  insertInto: managedContext)
        
        // 3
        aktivitasKeCoreData.setValue(hr, forKeyPath: "heartRate")
        aktivitasKeCoreData.setValue(stressLevel, forKeyPath: "stressLevel")
        aktivitasKeCoreData.setValue(Date(), forKeyPath: "date")
        
        // 4
        do
        {
            try managedContext.save()
            listStress.append(aktivitasKeCoreData)
            print("Core Data Masuk")
        }
        catch let error as NSError
        {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func scheduleNotification(notificationType: String, notifBody: String) {
        
        let content = UNMutableNotificationContent()
        
        content.title = notificationType
        content.subtitle = "Stress Alert"
        content.body = notifBody
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    @objc func imageAnimation()
    {
        UIView.animate(withDuration: 3) {
            self.moodImageView.frame = CGRect(x: 87, y: 301, width: 250, height: 250)
        }
        UIView.animateKeyframes(withDuration: 3, delay: 3, animations: {
            self.moodImageView.frame = CGRect(x: 102, y: 316, width: 210, height: 210)
        })
    }
    
    func checkIfHealthKitAvailable()
    {
        if HKHealthStore.isHealthDataAvailable() {
            
            let allTypes = Set(
                [
                    HKObjectType.quantityType(forIdentifier: .heartRate)!,
                    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
                ]
            )
            
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                }
            }
        }
    }
    
    @objc func readHealthData()
    {
        //sample type
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .heartRate) else { return }
        
        //predicate boleh nil
        
        //limit
        let limit = 1
        
        //sortDescriptor bisa nil
        let sortDescriptors = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: limit, sortDescriptors: [sortDescriptors]) { (sampleQuery, results, error) in
            
            guard let samples = results as? [HKQuantitySample] else { return }
            
            for sample in samples {
                DispatchQueue.main.async {
                    let heartRateUnit = HKUnit(from: "count/min")
                    let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                    self.heartRateText.text = String("\(Int(heartRate))")
                    self.hr = heartRate
                    
                    if heartRate >= 87 {
                        self.moodImageView.image = UIImage(named: self.mood[2])
                        self.scheduleNotification(notificationType: "You're getting stress", notifBody: "Stop for awhile is good too")
                        self.stressLevel = "Stressed"
                    } else if heartRate >= 70 {
                        self.stressLevel = "Happy"
                        self.moodImageView.image = UIImage(named: self.mood[1])
                    } else {
                        self.stressLevel = "Flat"
                        self.moodImageView.image = UIImage(named: self.mood[0])
                    }
                }
            }
        }
        
        healthStore.execute(sampleQuery)
    }
    
    @objc func readSleepAnalysis()
    {
        //sample type
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        //predicate boleh nil
        
        //limit
        let limit = 1
        
        //sortDescriptor bisa nil
        let sortDescriptors = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: limit, sortDescriptors: [sortDescriptors]) { (sampleQuery, results, error) in
            
            guard let samples = results as? [HKCategorySample] else { return }
            
            for sample in samples {
                DispatchQueue.main.async {
                    let difference = Calendar.current.dateComponents([.hour, .minute], from: sample.startDate, to: sample.endDate)
                    self.sleepAnalysisText.text = "\(difference.hour as! Int)hr(s) \(difference.minute as! Int)min"
                }
            }
        }
        
        healthStore.execute(sampleQuery)
    }

}
