// File: Progress.swift
// Authors: Taylor Traviss, Anysa Manhas
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
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var weeksButton: UIButton!
    @IBOutlet weak var monthsButton: UIButton!
    @IBOutlet weak var yearsButton: UIButton!
    
    //MARK: Variables
    var all_data : [(Date, Double)] = [] //will be the (x,y) coordinates to graph
    var meds : [(String, Date)] = [] //will be used for the horizontal markers on the graph
    let DB = Database.DB
    let medColours = [UIColor.red, UIColor.blue, UIColor.purple, UIColor.orange, UIColor.magenta, UIColor.green] //colours that will be used for the limitlines on the graph
    var chartDataSet : LineChartDataSet?
    var chartData : LineChartData?
    var dataEntries: [ChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderColour = UIColor(red: 125/255, green: 18/255, blue: 81/255, alpha: 1)
        ShareButton.layer.borderColor = borderColour.cgColor
        ShareButton.layer.borderWidth = 2
        menuButton.layer.borderColor = borderColour.cgColor
        menuButton.layer.borderWidth = 2
        profileButton.layer.borderColor = borderColour.cgColor
        profileButton.layer.borderWidth = 2
        weeksButton.layer.borderColor = borderColour.cgColor
        weeksButton.layer.borderWidth = 2
        monthsButton.layer.borderColor = borderColour.cgColor
        monthsButton.layer.borderWidth = 2
        yearsButton.layer.borderColor = borderColour.cgColor
        yearsButton.layer.borderWidth = 2
        
        //for testing purposes
       /* DB.dateArray.append("30/12/2016 00:00")
        DB.scoreArray.append(10)
        DB.dateArray.append("30/12/2017 00:00")
        DB.scoreArray.append(15.0)
        DB.dateArray.append("15/01/2018 00:00")
        DB.scoreArray.append(22.0)
        DB.dateArray.append("26/05/2018 00:00")
        DB.scoreArray.append(24.0)
        DB.dateArray.append("28/09/2018 00:00")
        DB.scoreArray.append(27.0)
        DB.dateArray.append("28/10/2018 00:00")
        DB.scoreArray.append(30.0)
        DB.dateArray.append("13/11/2018 00:00")
        DB.scoreArray.append(38.3)
        DB.dateArray.append("18/11/2018 00:00")
        DB.scoreArray.append(40.0)
        DB.dateArray.append("22/11/2018 00:00")
        DB.scoreArray.append(42.3)
        DB.dateArray.append("24/11/2018 00:00")
        DB.scoreArray.append(45.5)
        DB.dateArray.append("26/11/2018 00:00")
        DB.scoreArray.append(47.0)
        DB.dateArray.append("28/11/2018 00:00")
        DB.scoreArray.append(50.0)*/
        //DB.saveScore()
        //fetchData()
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
            
            //mail.setToRecipients(["sample@someEmail.com"])
            
            mail.setSubject("TrackPoint Progress")
            mail.setMessageBody("<p>Here's my tremor progress using TrackPoint:</p>", isHTML: true)
            let imageView = lineChart.getChartImage(transparent:false)!
            let imageData = imageView.pngData()!
            mail.addAttachmentData(imageData, mimeType: "image/png", fileName: "tremorProgress.png")
            
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
    
    @IBAction func plotWeek(_ sender: Any) {
        //upon clicking the "weeks" button we will only display data from the past week
        fetchWeek()
        setChart()
    }
    
    
    @IBAction func plotMonth(_ sender: Any) {
        //upon clicking the "months" button we will only display data from the past month
        fetchMonth()
        setChart()
    }
    
    
    @IBAction func plotYear(_ sender: Any) {
        //upon clicking the "years" button we will only display data from the past year
        fetchYear()
        setChart()
    }
    
    
    //MARK: Functions
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //this function will fetch the necessary data from the database and put it in all_data and meds
    func fetchData()
    {
        //declare date formatter
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
        
        if (all_data.count <= 1)
        {
            return
        }
        
        let first_date = dateFormatter.date(from:DB.dateArray[0]!)
        let last_date = dateFormatter.date(from:DB.dateArray[DB.dateArray.count - 1]!)
        
        //reset dateFormat for medication
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if (DB.medicationArray.count == 0)
        {
            return
        }
        
        
        for i in 0...(DB.medicationArray.count - 1)
        {
            let split_med = (DB.medicationArray[i])?.split(separator: ",")
            let temp_med = String((split_med?[0])!)
            let temp_date = dateFormatter.date(from:((split_med?[1])?.trimmingCharacters(in: .whitespacesAndNewlines))!)
            
            if ((temp_date!.timeIntervalSince1970 > first_date!.timeIntervalSince1970) && (temp_date!.timeIntervalSince1970 < last_date!.timeIntervalSince1970))
            {
                meds.append((temp_med, temp_date!))
            }
            
        }
        
    }
    
    //this function will fetch data of the previous year from the database and put it in all_data and meds
    func fetchYear()
    {
        //clear the data previously in these arrays
        all_data.removeAll()
        meds.removeAll()
        
        //declare date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let currentDate = Date()
        
        if (DB.dateArray.count == 0)
        {
            return
        }
        
        for i in 0...(DB.dateArray.count - 1)
        {
            let tempDate = dateFormatter.date(from:DB.dateArray[i]!)!
            if (((currentDate.timeIntervalSince1970) - (tempDate.timeIntervalSince1970)) < 31536000)
            {
                all_data.append((tempDate, DB.scoreArray[i]!))
            }
        }
        
        //reset dateFormat for medication
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if (all_data.count <= 1)
        {
            return
        }
        
        if (DB.medicationArray.count == 0)
        {
            return
        }
        
        let first_date = all_data[0].0
        let last_date = all_data[all_data.count - 1].0
        
        for i in 0...(DB.medicationArray.count - 1)
        {
            let split_med = (DB.medicationArray[i])?.split(separator: ",")
            let temp_med = String((split_med?[0])!)
            let temp_date = dateFormatter.date(from:((split_med?[1])?.trimmingCharacters(in: .whitespacesAndNewlines))!)
            
            if ((temp_date!.timeIntervalSince1970 > first_date.timeIntervalSince1970) && (temp_date!.timeIntervalSince1970 < last_date.timeIntervalSince1970))
            {
                meds.append((temp_med, temp_date!))
            }
        
        }
        
    }
    
    //this function will fetch data of the previous month from the database and put it in all_data and meds
    func fetchMonth()
    {
        //clear the data previously in these arrays
        all_data.removeAll()
        meds.removeAll()
        
        //declare date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let currentDate = Date()
        
        if (DB.dateArray.count == 0)
        {
            return
        }
        
        for i in 0...(DB.dateArray.count - 1)
        {
            let tempDate = dateFormatter.date(from:DB.dateArray[i]!)!
            if (((currentDate.timeIntervalSince1970) - (tempDate.timeIntervalSince1970)) < 2628000)
            {
                all_data.append((tempDate, DB.scoreArray[i]!))
            }
        }
        
        //reset dateFormat for medication
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if (all_data.count <= 1)
        {
            return
        }
        
        if (DB.medicationArray.count == 0)
        {
            return
        }
        
        let first_date = all_data[0].0
        let last_date = all_data[all_data.count - 1].0
        
        for i in 0...(DB.medicationArray.count - 1)
        {
            let split_med = (DB.medicationArray[i])?.split(separator: ",")
            let temp_med = String((split_med?[0])!)
            let temp_date = dateFormatter.date(from:((split_med?[1])?.trimmingCharacters(in: .whitespacesAndNewlines))!)
            
            if ((temp_date!.timeIntervalSince1970 > first_date.timeIntervalSince1970) && (temp_date!.timeIntervalSince1970 < last_date.timeIntervalSince1970))
            {
                meds.append((temp_med, temp_date!))
            }
            
        }
        
        
    }
    
    //this function will fetch data of the previou week from the database and put it in all_data and meds
    func fetchWeek()
    {
        //clear the data previously in these arrays
        all_data.removeAll()
        meds.removeAll()
        
        //declare date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let currentDate = Date()
        
        if (DB.dateArray.count == 0)
        {
            return
        }
        
        for i in 0...(DB.dateArray.count - 1)
        {
            let tempDate = dateFormatter.date(from:DB.dateArray[i]!)!
            //print((currentDate.timeIntervalSince1970) - (tempDate.timeIntervalSince1970))
            if (((currentDate.timeIntervalSince1970) - (tempDate.timeIntervalSince1970)) < 604800)
            {
                //print(i)
                all_data.append((tempDate, DB.scoreArray[i]!))
            }
        }
        
        //reset dateFormat for medication
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if (all_data.count <= 1)
        {
            return
        }
        
        if (DB.medicationArray.count == 0)
        {
            return
        }
        
        let first_date = all_data[0].0
        let last_date = all_data[all_data.count - 1].0
        
        for i in 0...(DB.medicationArray.count - 1)
        {
            let split_med = (DB.medicationArray[i])?.split(separator: ",")
            let temp_med = String((split_med?[0])!)
            let temp_date = dateFormatter.date(from:((split_med?[1])?.trimmingCharacters(in: .whitespacesAndNewlines))!)
            
            if ((temp_date!.timeIntervalSince1970 > first_date.timeIntervalSince1970) && (temp_date!.timeIntervalSince1970 < last_date.timeIntervalSince1970))
            {
                meds.append((temp_med, temp_date!))
            }
            
        }
        
        
    }
    
    //this function will setup the chart to be displayed to the user
    func setChart()
    {
        //lineChart.clear()
        lineChart.backgroundColor = UIColor.white//do we want clear or white?
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
        
        dataEntries.removeAll()
        
        for i in 0..<all_data.count {
            let dataEntry = ChartDataEntry(x: (all_data[i].0).timeIntervalSince1970, y: all_data[i].1)
            dataEntries.append(dataEntry)
        }
        
        chartDataSet = LineChartDataSet(values: dataEntries, label: "Tremor Severity")
        chartDataSet!.drawCirclesEnabled = true
        chartDataSet!.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        chartDataSet!.setCircleColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        chartDataSet!.lineWidth = 1.5
        chartDataSet!.drawValuesEnabled = false
        chartDataSet!.drawCircleHoleEnabled = false
        chartDataSet!.circleRadius = 3.5
        chartData = LineChartData(dataSets: [chartDataSet!])
        lineChart.data = chartData
        
        //here we will add the limit lines for the medications
        if (meds.count == 0) //no meds to add
        {
            return
        }
        
        lineChart.xAxis.removeAllLimitLines()
        for i in 0..<meds.count
        {
            let limitLine = ChartLimitLine()
            limitLine.lineColor = medColours[i%6] //rotate through the 6 colours
            limitLine.limit = ((meds[i].1).timeIntervalSince1970)
            limitLine.label = meds[i].0
            limitLine.lineWidth = 0.8
            limitLine.lineDashLengths = [1,2]
            limitLine.valueTextColor = medColours[i%6] //match with the line colour
            
            //try to make it so that labels for limit lines won't overlap???
            if (i < meds.count/2)
            {
                if (i%2 == 0)
                {
                    limitLine.labelPosition = .rightTop
                }
                else
                {
                    limitLine.labelPosition = .rightBottom
                }
            }
            else
            {
                if (i%2 == 0)
                {
                    limitLine.labelPosition = .leftTop
                }
                else
                {
                    limitLine.labelPosition = .leftBottom
                }
            }
            //limitLine.labelPosition = .leftTop
            lineChart.xAxis.addLimitLine(limitLine)
        }
        
        //need this to update the new line chart data and limit lines
        lineChart.animate(xAxisDuration: 0.00001)
        lineChart.animate(yAxisDuration: 0.00001)
        
    }
    
}


//date formatter for x-axis of plot (converts double to dd/MM/yyyy)
public class DateValueFormatter: NSObject, IAxisValueFormatter{
    private let dateFormatter = DateFormatter()
    
    override init(){
        super.init()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String{
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
