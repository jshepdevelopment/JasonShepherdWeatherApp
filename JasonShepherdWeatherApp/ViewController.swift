//
//  ViewController.swift
//  JasonShepherdWeatherApp
//
//  Created by Jason Shepherd on 3/14/16.
//  Copyright © 2016 Salt Lake Community College. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  
    // Boolean flags for error checking
    var checkByZip = true
    var dontCheck = false
    
    @IBOutlet weak var cityNameField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var weatherResultLabel: UILabel!
    
    @IBAction func searchButton(sender: AnyObject) {
        
        // Check whether app will find by name or zip
        if cityNameField.text != "" {
            checkByZip = false
        }
        
        if zipCodeField.text != "" {
            checkByZip = true
        }
      
        // Assign and check by zip code
        if checkByZip == true {
            
            // Variable to city name and truncated city name
            var cityString = " "
            var truncatedCityString = " "
            
            if zipCodeField.text!.characters.count < 4 || zipCodeField.text!.characters.count > 5 {
                weatherResultLabel.text = "That is not a valid zip code. Try again."
                dontCheck = true
            }
                
            else {
                dontCheck = false
                
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
                                //self.weatherResultLabel.text = cityString
                                self.cityNameField.text = truncatedCityString
                                self.getWeather(truncatedCityString)
                            }
                        }
                       
                    })
                    task.resume() // Resuming normal activity
                    // Update global cityNameField so name can be used in finding weather
                    
                }
                else {
                    showError()
                }
            }
        }
        
        else if checkByZip == false {
            // Didn't get a zip, so assign the name and run function
            getWeather(cityNameField.text!)
        }
        
    }
    
    
    // Function to get weather based on information passed from button
    func getWeather(globalCityName: String) {
        // Only attempt if given the green flag
        if dontCheck == false {
            
            // Assign url to string
            let url = NSURL(string: "http://www.weather-forecast.com/locations/" + globalCityName.stringByReplacingOccurrencesOfString(" ", withString: "-") + "/forecasts/latest")
            
            print("global city name is \(globalCityName)")
            
            //let url = NSURL(string: "http://www.weather-forecast.com/locations/" + globalCityName)
            
            print("url is \(url)")
            
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

