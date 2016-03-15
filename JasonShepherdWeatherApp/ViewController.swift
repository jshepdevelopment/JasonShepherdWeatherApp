//
//  ViewController.swift
//  JasonShepherdWeatherApp
//
//  Created by Jason Shepherd on 3/14/16.
//  Copyright © 2016 Salt Lake Community College. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var weatherResultLabel: UILabel!
    
    @IBAction func searchButton(sender: AnyObject) {
        // Occurs on button tap
        
        // Assign and check by zip code
        if zipCodeField.text != "" {
            
            // Variable to city name and truncated city name
            var cityString = " "
            var truncatedCityString = " "
            
            if zipCodeField.text!.characters.count < 4 || zipCodeField.text!.characters.count > 5 {
                weatherResultLabel.text = "That is not a valid zip code. Try again."
            }
            else {
                let url = NSURL(string: "https://tools.usps.com/go/ZipLookupResultsAction!input.action?resultMode=2&postalCode=" + zipCodeField.text!)
                
                if url != nil {
                    // Creating an asynchronous web session
                    let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: {
                        (data, response, error) -> Void in
                        
                        // Check if for any session error
                        var urlError = false
                        
                        // Get successful display contents
                        if error == nil {
                            let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
                            let urlContentArray = urlContent.componentsSeparatedByString("<p class=\"std-address\">")
                            
                            // Make sure the paragraph exists
                            if urlContentArray.count > 0 {
                                
                                // Get the city name from the html
                                var cityNameArray = urlContentArray[1].componentsSeparatedByString("</p>")
                                cityString = cityNameArray[0] as String
                                print(cityString)
                                
                                // After getting name by zip code, assign it to the city name text field.
                                // Drop the last three characters, which are the state and a space, then assign to a truncated string
                                let cityStringLength = cityString.startIndex.advancedBy(cityString.characters.count - 3)
                                truncatedCityString = cityString.substringToIndex(cityStringLength)
                                
                                print("Truncated string = \(truncatedCityString)")
                                
                                //cityNameField.text = cityString
                            }
                        }
                
                        else {
                            // Error
                            urlError = true
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            // Show the error message if necessary
                            if urlError == true {
                                self.showError()
                            }
                            else {
                                self.weatherResultLabel.text = cityString
                                self.cityNameField.text = truncatedCityString
                            }
                        }
                        
                    })
                    task.resume(); // Resuming normal activity
                    
                }
                else {
                    showError()
                }
            }
           
        }


        // Assign and check by name
        else {
            // Assign url to string
            let url = NSURL(string: "http://www.weather-forecast.com/locations/" + cityNameField.text!.stringByReplacingOccurrencesOfString(" ", withString: "-") + "/forecasts/latest")
        
            if url != nil {
            // Creating an asynchronous web session
                let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: {
                    (data, response, error) -> Void in
                
                    // Check if for any session error
                    var urlError = false
               
                    var weather = ""
                
                    // Get successful dispplay contents
                    if error == nil {
                        let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
                    
                        let urlContentArray = urlContent.componentsSeparatedByString("<span class=\"phrase\">")
                    
                        // Make sure span exists
                        if urlContentArray.count > 0 {
                        
                            var weatherArray = urlContentArray[1].componentsSeparatedByString("</span>")
                            weather = weatherArray[0] as String
                        
                            weather = weather.stringByReplacingOccurrencesOfString("&deg;", withString: "°")
                        
                        }
                    }
                    else {
                        // Error
                        urlError = true
                    }
                
                    dispatch_async(dispatch_get_main_queue()) {
                    
                        // Show the error message if necessary
                        if urlError == true {
                            self.showError()
                        }
                        else {
                            self.weatherResultLabel.text = weather
                        }
                    }
                
                })
                task.resume(); // Resuming normal activity
            
            }
            else {
                showError()
            }
        }
    }
    
    func showError() {
        // Display the following for any URL errors
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

