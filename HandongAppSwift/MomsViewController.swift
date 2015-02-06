//
//  File.swift
//  HandongAppSwift
//
//  Created by csee on 2015. 2. 6..
//  Copyright (c) 2015년 GHOST. All rights reserved.
//

import Foundation
import UIKit

class MomsViewController: UIViewController {
    let rootTag = "moms"
    let itemTag = "menu"
    let dateTag = "date"
    let breTag = "breakfast"
    let lunDinTag = "lunNdin"
    
    let menuTag = "name"
    let priceTag = "price"
    
    var itemYPos: Double = 0.0
    var momsItem = Array<MomsModel>()
    var idx: Int?
    
    var actInd = UIActivityIndicatorView()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        getDataXML()
        Util.showActivityIndicatory(self.view, indicator: &self.actInd)
    }
    
    func getDataXML() {
        let url = NSURL(string: Util.MomskitchenURL)!
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithURL(url, completionHandler:
            {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                self.parseMomsXML(data)
                
                self.makeViewWithData()
        })
        dataTask.resume()
    }
    
    func parseMomsXML(data: NSData) {
        let xmlDom = SWXMLHash.parse(data)
        
        var alldayMenuCount = xmlDom[rootTag][itemTag].all.count
        
        for i in 0 ..< alldayMenuCount {
            let model = MomsModel(
                date: xmlDom[rootTag][itemTag][i][dateTag].element!.text!,
                breakfast: xmlDom[rootTag][itemTag][i][breTag][menuTag].element!.text,
                breakfastPrice: xmlDom[rootTag][itemTag][i][breTag][priceTag].element!.text,
                lunchDinner: xmlDom[rootTag][itemTag][i][lunDinTag][menuTag].element!.text,
                lunchDinnerPrice: xmlDom[rootTag][itemTag][i][lunDinTag][priceTag].element!.text)
            
            momsItem.append(model)
        }
    }
    
    func makeViewWithData() {
        if self.momsItem.count == 0 {
            return
        }
        
        if self.idx == nil {
            
            let today = Util.getToday()
            self.idx = -1
            
            for i in 0 ..< self.momsItem.count {
                if self.momsItem[i].month.toInt() == today.month && self.momsItem[i].date.toInt() == today.day {
                    idx = i
                    break
                }
            }
            
            if idx == -1 {
                // no data for today
                idx = nil
                
                return
            }
        }
        
        let weekdayString = self.momsItem[idx!].dayOfWeek + "요일"
        let monthString = self.momsItem[idx!].month + "월 "
        let dateString = self.momsItem[idx!].date + "일 "
        self.dateLabel.text = monthString + dateString + weekdayString
        
        let grayColor = UIColor(red: 155, green: 159, blue: 161, alpha: 0)
        let screenWidth = Double(UIScreen.mainScreen().applicationFrame.width)
        
        
        // BREAKFAST
        
        let breHead = UILabel(frame: CGRect(x: 0.0, y: self.itemYPos, width: screenWidth, height: 30.0))
        self.itemYPos += 30.0
        
        breHead.backgroundColor = grayColor
        breHead.text = "아침"
        
        self.scrollView.addSubview(breHead)
        
        var lineCount = Double(momsItem[idx!].breakfast.menu.componentsSeparatedByString("\n").count * 25)
        
        let morningMenuLabel = UILabel(frame: CGRect(x: 0.0, y: self.itemYPos, width: screenWidth/4*3, height: lineCount))
        morningMenuLabel.text = momsItem[idx!].breakfast.menu
        morningMenuLabel.numberOfLines = 0
        morningMenuLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        self.scrollView.addSubview(morningMenuLabel)
        
        let morningPriceLabel = UILabel(frame: CGRect(x: screenWidth/4*3, y: self.itemYPos, width: screenWidth/4, height: lineCount))
        self.itemYPos += lineCount
        morningPriceLabel.text = momsItem[idx!].breakfast.price
        morningPriceLabel.numberOfLines = 0
        morningPriceLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        self.scrollView.addSubview(morningPriceLabel)
        
        
        // LUNCH && DINNER
        
        let ldHead = UILabel(frame: CGRect(x: 0.0, y: self.itemYPos, width: screenWidth, height: 30.0))
        self.itemYPos += 30.0
        
        ldHead.backgroundColor = grayColor
        ldHead.text = "점심 & 저녁"
        
        self.scrollView.addSubview(ldHead)
        
        lineCount = Double(momsItem[idx!].lunchDinner.menu.componentsSeparatedByString("\n").count * 25)
        
        let ldMenuLabel = UILabel(frame: CGRect(x: 0.0, y: self.itemYPos, width: screenWidth/4*3, height: lineCount))
        ldMenuLabel.text = momsItem[idx!].lunchDinner.menu
        ldMenuLabel.numberOfLines = 0
        ldMenuLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        self.scrollView.addSubview(ldMenuLabel)
        
        let ldPriceLabel = UILabel(frame: CGRect(x: screenWidth/4*3, y: self.itemYPos, width: screenWidth/4, height: lineCount))
        self.itemYPos += lineCount
        ldPriceLabel.text = momsItem[idx!].lunchDinner.price
        ldPriceLabel.numberOfLines = 0
        ldPriceLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        self.scrollView.addSubview(ldPriceLabel)
        
        
        
        // Loading END
        self.actInd.stopAnimating()
        self.scrollView.contentSize = CGSizeMake(CGFloat(screenWidth), CGFloat(self.itemYPos))
    }
}