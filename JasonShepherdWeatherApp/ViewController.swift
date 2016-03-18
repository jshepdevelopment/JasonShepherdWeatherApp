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
    var progressBool = true
    
    var myTimer: NSTimer!
    var progressLabelCounter: Float!
    
    // Outlets to UI elements
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
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
                // A valid zip code exists, therefor check
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
                                
                            }
                        }
                
                        else {
                            // Error
                            urlError = true
                        }
                        
                        

                            dispatch_async(dispatch_get_main_queue(), {
                            
                            // Show the error message if necessary
                            if urlError == true {
                                self.showError()
                            }
                            else {
                                //self.weatherResultLabel.text = cityString
                                self.cityNameField.text = truncatedCityString
                                self.getWeather(truncatedCityString)
                            }
                            
                        })

                    })
                    task.resume() // Resuming normal activity
                    
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

            // Set up a NSURLRequest to populate webView later
            let webViewRequest = NSURLRequest(URL: url!)
            
            // Print some stuff to console for debugging purposes
            print("global city name is \(globalCityName)")
            print("url is \(url)")
            
            // Proceed if the url is good
            if url != nil {
                // Creating an asynchronous web session
                let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: {
                    (data, response, error) -> Void in
                    
                    // Check if for any session error
                    var urlError = false
                    var weather = ""
                    var highTemp = ""
                    var lowTemp = ""
                    
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
                        
                        let highContentArray = weather.componentsSeparatedByString("max ")
                        if highContentArray.count > 0 {
                            var highArray = highContentArray[1].componentsSeparatedByString("°")
                            highTemp = highArray[0] as String
                        }
                        
                        let lowContentArray = weather.componentsSeparatedByString("min ")
                        if lowContentArray.count > 0 {
                            var lowArray = lowContentArray[1].componentsSeparatedByString("°")
                            lowTemp = lowArray[0] as String
                        }
                        
                        
                    }
                    else {
                        // Error
                        urlError = true
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {

                        // Show the error message if necessary
                        if urlError == true {
                            self.showError()
                        }
                        else {
                            
                            // Everything good, so populate labels and webView
                            self.weatherResultLabel.text = weather
                            self.highLabel.text = highTemp
                            self.lowLabel.text = lowTemp
                            self.startLoadingWebView()
                            self.webView.loadRequest(webViewRequest)
                            self.finishLoadingWebView()
                            
                            // Check for weather variations and update image
                            if ((weather.rangeOfString("moderate rain")) != nil) {
                                self.weatherImageView.image = UIImage(named: "sunrain.png")
                            }
                            
                            if ((weather.rangeOfString("Light rain")) != nil) {
                                self.weatherImageView.image = UIImage(named: "sunrain.png")
                            }
                            
                            if ((weather.rangeOfString("cloudy")) != nil) {
                                self.weatherImageView.image = UIImage(named: "cloudy.png")
                            }

                            if ((weather.rangeOfString("Mostly dry")) != nil) {
                                self.weatherImageView.image = UIImage(named: "sunny.png")
                            }
                            
                            if ((weather.rangeOfString("Heavy rain")) != nil) {
                                self.weatherImageView.image = UIImage(named: "rainy.png")
                            }
                            
                            if ((weather.rangeOfString("snow")) != nil) {
                                self.weatherImageView.image = UIImage(named: "snow.png")
                            }
                            

                        }
                    })
                })
                task.resume(); // Resuming normal activity
                webView.scrollView.contentOffset = CGPoint(x: 0,y: 600)
                
            }
            else {
                showError()
            }
        }
    }
    
    func showError() {
        // Display the following for any URL errors
    }
    
    // Begin loading webview progress
    func startLoadingWebView() {
        self.progressView.progress = 0.0
        self.progressLabelCounter = self.progressView.progress * 100.0
        self.progressLabel.text = String("\(progressLabelCounter)%")
        self.progressBool = false
        self.myTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
    }
    
    // Finished loading webview progress
    func finishLoadingWebView() {
        self.progressBool = true
        
    }
    
    // And a timer callback
    func timerCallback() {
        if self.progressBool {
            if self.progressView.progress >= 1 {
                self.myTimer.invalidate()
                self.progressLabel.text = String("Finished!")
                
                
            } else {
                self.progressView.progress += 0.1
                self.progressLabelCounter = self.progressView.progress * 100.0
                self.progressLabel.text = String("\(progressLabelCounter)%")
            }
        }   else {
            self.progressView.progress += 0.05
            self.progressLabelCounter = self.progressView.progress * 100.0
            if self.progressView.progress >= 0.95 {
                self.progressView.progress = 0.95
                self.progressLabelCounter = self.progressView.progress * 100.0
                self.progressLabel.text = String("Finished!")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.setProgress(0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

