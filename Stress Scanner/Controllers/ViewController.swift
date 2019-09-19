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

class ViewController: UIViewController {
    @IBOutlet weak var stressScanBtn: UIButton!
    @IBOutlet weak var heartRateText: UITextView!
    @IBOutlet weak var sleepAnalysisText: UITextView!
    @IBOutlet weak var moodImageView: UIImageView!
    
    let healthStore = HKHealthStore()
    let mood = ["flat", "happy", "stressful"]
    
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
            
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
            
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
                    
                    if heartRate > 85 {
                        self.moodImageView.image = UIImage(named: self.mood[2])
                    } else if heartRate > 70 {
                        self.moodImageView.image = UIImage(named: self.mood[1])
                    } else {
                        self.moodImageView.image = UIImage(named: self.mood[2])
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

