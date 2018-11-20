// File: Progress.swift
// Authors: Taylor Traviss
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit
import MessageUI
import Charts
import Foundation

class Progress: UIViewController, MFMailComposeViewControllerDelegate {

    //MARK: Outlets
    @IBOutlet weak var ShareButton: UIButton!
    @IBOutlet weak var lineChart: LineChartView!
    
    //MARK: Variables
    var all_data : [(Date, Double)] = [] //will be the (x,y) coordinates to graph
    let DB = Database.DB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        setChart()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func ShareClicked(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            //mail.delegate = self
            mail.setToRecipients(["sample@someEmail.com"])
            mail.setMessageBody("<p>Here's my progress!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            let alertController = UIAlertController(title: "Error", message: "Email has not been configured", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            //and finally presenting our alert using this method
            present(alertController, animated: true, completion: nil)
            print("Email configuration not setup")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //this function will fetch the necessary data from the database and put it in all_data
    //for now it will provide test data
    func fetchData()
    {
        //entering dummy data for now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        if (DB.dateArray.count == 0)
        {
            return
        }
        
        for i in 0...(DB.dateArray.count - 1)
        {
            all_data.append((dateFormatter.date(from:DB.dateArray[i]!)!, DB.scoreArray[i]!))
        }
        
        
        
        
        /*var added_date = "01/11/2018"
        all_data.append((dateFormatter.date(from:added_date)!, 10))
        added_date = "05/11/2018"
        all_data.append((dateFormatter.date(from:added_date)!, 5))
        added_date = "07/11/2018"
        all_data.append((dateFormatter.date(from:added_date)!, 20))
        added_date = "11/11/2018"
        all_data.append((dateFormatter.date(from:added_date)!, 15))*/
        
    }
    
    //this function will setup the chart to be displayed to the user
    func setChart()
    {
        lineChart.backgroundColor = UIColor.clear //do we want clear or white?
        lineChart.noDataText = "No data to display."
        lineChart.noDataTextColor = UIColor.orange
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.avoidFirstLastClippingEnabled = true
        
        if (all_data.count == 0)
        {
            return
        }
        
        lineChart.xAxis.labelCount = 2
        lineChart.xAxis.setLabelCount(2, force:true)
        
        lineChart.xAxis.granularity = 1.0
        lineChart.xAxis.valueFormatter = DateValueFormatter()
        
        lineChart.rightAxis.drawAxisLineEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.leftAxis.drawAxisLineEnabled = false
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.legend.enabled = true
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<all_data.count {
            let dataEntry = ChartDataEntry(x: (all_data[i].0).timeIntervalSince1970, y: all_data[i].1)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Tremor Severity")
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        chartDataSet.setCircleColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        chartDataSet.lineWidth = 1.5
        chartDataSet.drawValuesEnabled = false
        chartDataSet.drawCircleHoleEnabled = false
        chartDataSet.circleRadius = 3.5
        let chartData = LineChartData(dataSets: [chartDataSet])
        lineChart.data = chartData
        
    }
    
}

//date formatter for x-axis of plot (converts double to dd/MM/yyyy)
public class DateValueFormatter: NSObject, IAxisValueFormatter{
    private let dateFormatter = DateFormatter()
    
    override init(){
        super.init()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        //dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String{
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
