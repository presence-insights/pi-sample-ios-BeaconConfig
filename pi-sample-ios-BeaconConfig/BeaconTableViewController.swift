//
//© Copyright 2015 IBM Corp.
//    
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.



import UIKit
import CoreData
import CoreLocation
import PresenceInsightsSDK

class BeaconTableViewController: UITableViewController, CLLocationManagerDelegate {
    var beacons : AnyObject = []
    let locationManager = CLLocationManager()
    var results : NSArray = []
    var piAdapter : PIAdapter!
    private var _authorization: String!
    private let _httpContentTypeHeader = "Content-Type"
    private let _httpAuthorizationHeader = "Authorization"
    private let _contentTypeJSON = "application/json"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse)
        {
            locationManager.requestWhenInUseAuthorization()
        }
        results = retrieveAllDC("Beacon")
        
        if(results.count > 0){
            for res in results {
                let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "\(res.value! as String)")!, identifier: "Estimotes")
                locationManager.startRangingBeaconsInRegion(region)
            }
        }
        else{
            alert("Error", messageInput: "Please go to settings and add beacon information!")
        }
        

    
        
        //        //B9407F30-F5F8-466E-AFF9-25556B57FE6D
    }
    


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return beacons.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //myData.removeAll()
        let CellID: String = "Cell"
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellID)! as UITableViewCell
        let bea = beacons[indexPath.row]
        let rssi = beacons[indexPath.row].rssi
        
        //let major = bea.major!
        let majorString = bea.major!!.stringValue
        
//        let minor = bea.minor!
        let minorString = bea.minor!!.stringValue

        let proximity = bea.proximity
        
        var proximityString = String()
        
        switch proximity!
        {
        case .Near:
            proximityString = "Near"
        case .Immediate:
            proximityString = "Immediate"
        case .Far:
            proximityString = "Far"
        case .Unknown:
            proximityString = "Unknown"
        }
        cell.textLabel?.numberOfLines = 2;
        cell.textLabel?.text = "Proximity: \(proximityString) RSSI: \(rssi) \n  Major: \(majorString) Minor: \(minorString)"
        //myData.append(bea)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Beacons in range"
    }
    
    
    
    // Override to support conditional editing of the table view.]
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    

    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let tenantID = retrieveSpecificDC("BM", key: "TenantID")
        let orgID = retrieveSpecificDC("BM", key: "OrgID")
        let username = retrieveSpecificDC("BM", key: "Username")
        let passwd = retrieveSpecificDC("BM", key: "Password")
        let siteID = retrieveSpecificDC("BM", key: "SiteID")
        let floorID = retrieveSpecificDC("BM", key: "FloorID")
        var inputTextField: UITextField?
        
        if (tenantID.isEmpty || orgID.isEmpty || username.isEmpty || passwd.isEmpty || siteID.isEmpty || floorID.isEmpty){
            alert("Error", messageInput: "Please make sure all the Presence Insights Information have been entered.")
        }
        else{
            let uuid : NSUUID = beacons[indexPath.row].proximityUUID
            _authorization  = "Bearer " + retrieveSpecificDC("BM", key: "token")
            let url: String = "https://presenceinsights.ng.bluemix.net:443/pi-config/v1/tenants/\(tenantID)/orgs/\(orgID)/sites/\(siteID)/floors/\(floorID)/beacons"
            

            
            
            let Prompt = UIAlertController(title: "Confirm", message: "You have selected this beacon: \n UUID: \(uuid.UUIDString) \n Major: \(beacons[indexPath.row].major!!.stringValue) \n Minor: \(beacons[indexPath.row].minor!!.stringValue) \n Select Ok to continue.", preferredStyle: UIAlertControllerStyle.Alert)
            Prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            Prompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                //Now do whatever you want with inputTextField (remember to unwrap the optional)
                //need to store to DB
                let body : [String: AnyObject] = [
                    "name": "\(inputTextField!.text!)",
                    "proximityUUID": "\(uuid.UUIDString)",
                    "major":  self.beacons[indexPath.row].major!!.stringValue,
                    "minor": self.beacons[indexPath.row].minor!!.stringValue,
                    "description": "Added by using Beacon App",
                    "x": 1,
                    "y": 1,
                    "threshold": 10
                ]
                self.sendBeaconRegistration(url, body: body)
                
                
            }))
            Prompt.addTextFieldWithConfigurationHandler({(textField: UITextField) in
                textField.placeholder = "Beacon name"
                textField.secureTextEntry = false
                inputTextField = textField
            })
            presentViewController(Prompt, animated: true, completion: nil)
            
            
            

            
            
            
            
        }
    }

    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    func alert(titleInput : String , messageInput : String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion)
    {
        self.beacons = beacons
        refresh()
    }
    
    

    func refresh(){
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    func saveDC( entityName : String, key: String, value: String ) {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        //var request = NSFetchRequest(entityName: entityName)
        
        //create newkey object
        let newStore = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
        //set value (value, key)
        //print(key)
        //print(value)
        newStore.setValue(key , forKey: "key")
        newStore.setValue(value, forKey: "value")
        
        do {
            try context.save()
        } catch _ {
        }
        
        
    }



    func retrieveAllDC (entityName : String ) -> NSArray {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false;
        let results : NSArray = try! context.executeFetchRequest(request)
        return results
        
        
    }
    func retrieveSpecificDC ( entityName : String , key:String) -> String {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false;
        request.predicate = NSPredicate(format: "key = %@", key)
        
        
        let results : NSArray = try! context.executeFetchRequest(request)
        if (results.count > 0){
            let res = results[0] as! NSManagedObject
            return res.valueForKey("value") as! String
        }
        else{
            print("Potential error or no results!")
            return ""
        }
        
        
    }
    func updateDC ( entityName: String, key: String, value: String){
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "key = %@", key)
        
        if let fetchResults = (try? appDel.managedObjectContext!.executeFetchRequest(request)) as? [NSManagedObject] {
            if fetchResults.count != 0{
                let managedObject = fetchResults[0]
                managedObject.setValue(value, forKey: "value")
                do {
                    try context.save()
                } catch _ {
                }
            }
        }
    }
    
    /**
    Public function to send a payload of all beacons ranged by the device back to PI.
    
    - parameter beaconData: Array containing all ranged beacons and the time they were detected.
    */
    func sendBeaconRegistration(url: String, body: NSDictionary) {
        
        let endpoint = url
        let PostMessage =  body
        
        let Data = dictionaryToJSON(PostMessage as! [String : AnyObject])
        
        //print("Sending Beacon Registration Payload: \(PostMessage)")
        
        let request = buildRequest(endpoint, method: "POST", body: Data)
        performRequest(request, callback: {response, error in
            guard error == nil else {
                print("Could not send beacon payload: \(error)")
                
                return
            }
            print("Sent Beacon Payload Response: \(response)")
        })
    }
    
    
    /**
    Private function to convert a dictionary to a JSON object.
    
    - parameter dictionary: The dictionary to convert.
    
    - returns: An NSData object containing the raw JSON of the dictionary.
    */
    private func dictionaryToJSON(dictionary: [String: AnyObject]) -> NSData {
        
        do {
            let deviceJSON = try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions())
            return deviceJSON
        } catch let error as NSError {
            print("Could not convert dictionary object to JSON. \(error)")
        } catch {
            print("IDK")
        }
        
        return NSData()
        
    }
    /**
    Private function to perform a URL request.
    Will always massage response data into a dictionary.
    
    - parameter request:  The NSURLRequest to perform.
    - parameter callback: Returns an Dictionary of the response on task completion.
    */
    private func performRequest(request:NSURLRequest, callback:([String: AnyObject]!, NSError!)->()) {
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            
            guard error == nil else {
                print(error, terminator: "")
                callback(nil, error)
                return
            }
//            
//            if let data = data {
//                do {
//                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as? [String: AnyObject] {
//                        
//                        if let _ = json["code"] as? String,  message = json["message"] as? String {
//                            let errorDetails = [NSLocalizedFailureReasonErrorKey: message]
//                            let error = NSError(domain: "PresenceInsightsSDK", code: 1, userInfo: errorDetails)
//                            callback( nil, error)
//                            return
//                        }
//                        callback(json, nil)
//                        return
//                    } else if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as? [AnyObject] {
//                        let returnVal = [ "dataArray" : json]
//                        callback(returnVal, nil)
//                        return
//                    }
//                } catch let error {
//                    let returnVal = [ "rawData": data, "error": error as! NSError]
//                    callback(returnVal, nil)
//                }
//                
//            } else {
//                print("No response data.")
//            }
        })
        task.resume()
    }
    
    /**
    Private function to build an http/s request
    
    - parameter endpoint: The URL to connect to.
    - parameter method:   The http method to use for the request.
    - parameter body:     (Optional) The body of the request.
    
    - returns: A built NSURLRequest to execute.
    */
    private func buildRequest(endpoint:String, method:String, body: NSData?) -> NSURLRequest {
        
        if let url = NSURL(string: endpoint) {
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = method
            request.addValue(_authorization, forHTTPHeaderField: _httpAuthorizationHeader)
            request.addValue(_contentTypeJSON, forHTTPHeaderField: _httpContentTypeHeader)
            
            if let bodyData = body {
                request.HTTPBody = bodyData
            }
            
            return request
        } else {
            print("Invalid URL: \(endpoint)")
        }
        
        return NSURLRequest()
        
    }

   

}
