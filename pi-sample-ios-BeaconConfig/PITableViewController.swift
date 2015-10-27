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
import PresenceInsightsSDK

class PITableViewController: UITableViewController {
    
    var myData: Array<AnyObject> = []
    var piAdapter : PIAdapter!
    private var _authorization = "Basic Y2Y6"
    private let _httpContentTypeHeader = "Content-Type"
    private let _httpAuthorizationHeader = "Authorization"
    private let _contentTypeJSON = "application/x-www-form-urlencoded"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myData = ["Username", "Password", "TenantID", "OrgID", "SiteID", "FloorID", "Get Token"]
        //let newItem = NSEntityDescription.insertNewObjectForEntityForName("BM", inManagedObjectContext: self.managedObjectContext!) as! BM
        
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
        return myData.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellID: String = "Cell"
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellID)! as UITableViewCell
        
    
        let value = retrieveSpecificDC("BM", key: "\(myData[indexPath.row] as! String)")
        if (value.isEmpty){
            cell.textLabel!.text = "\(myData[indexPath.row] as! String)"
        }
        else{
            cell.textLabel!.text = "\(myData[indexPath.row] as! String) : \(value)"
        }

        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.]
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    
    
    //Override to support editing the table view.
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            myData.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(myData[indexPath.row] as! String == "Get Token"){
            var inputTextField: UITextField?
            var inputTextField2: UITextField?
            let currentToken = retrieveSpecificDC("BM", key: "token")
            
            //TESTING PURPOSE i will show the token
            let Prompt = UIAlertController(title: "Token Retrieval", message: "Enter your Bluemix Credentials. \n Need to retrieve token before we can add beacons to PI \n Current Token: \(currentToken)", preferredStyle: UIAlertControllerStyle.Alert)
            Prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            Prompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                //Now do whatever you want with inputTextField (remember to unwrap the optional)
                //need to store to DB
                let username = (inputTextField!.text!).stringByReplacingOccurrencesOfString("@", withString: "%40")
                let password = inputTextField2!.text!
                let data : NSData = ("password=\(password)&username=\(username)&grant_type=password").dataUsingEncoding(NSUTF8StringEncoding)!
//                print(data)
                
                let urlPath: String = "https://login.ng.bluemix.net/UAALoginServerWAR/oauth/token"
                let url: NSURL = NSURL(string: urlPath)!
                let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
                
                request.HTTPMethod = "POST"
                
                //let data = stringPost.dataUsingEncoding(NSUTF8StringEncoding)
                
                //request1.timeoutInterval = 60
                request.HTTPBody=data
                request.HTTPShouldHandleCookies=false
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("Basic Y2Y6", forHTTPHeaderField: "Authorization");
                //let queue:NSOperationQueue = NSOperationQueue()
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                    do {
                        let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        let token = jsonResult["access_token"] as! String
                        if( currentToken.isEmpty ){
                            self.saveDC("BM", key: "token", value: token)
                        }
                        else{
                            self.updateDC("BM", key: "token", value: token)
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                
                
                })

                task.resume()

                
                
                
                
                
            }))
            Prompt.addTextFieldWithConfigurationHandler({(textField: UITextField) in
                textField.placeholder = "Bluemix Username"
                textField.secureTextEntry = false
                inputTextField = textField
            })
            Prompt.addTextFieldWithConfigurationHandler({(textField2: UITextField) in
                textField2.placeholder = "Bluemix Password"
                textField2.secureTextEntry = false
                inputTextField2 = textField2
            })
            presentViewController(Prompt, animated: true, completion: nil)

        }
        
        else if(myData[indexPath.row] as! String == "SiteID" || myData[indexPath.row] as! String == "FloorID"){
            let tenantID = retrieveSpecificDC("BM", key: "TenantID")
            let orgID = retrieveSpecificDC("BM", key: "OrgID")
            let username = retrieveSpecificDC("BM", key: "Username")
            let passwd = retrieveSpecificDC("BM", key: "Password")
            let siteID = retrieveSpecificDC("BM", key: "SiteID")
            let floorID = retrieveSpecificDC("BM", key: "floorID")

            if (tenantID.isEmpty || orgID.isEmpty || username.isEmpty || passwd.isEmpty){
                alert("Error", messageInput: "Please make sure you entered TenantID, OrgID, Username, and password before trying to set Floor and Site IDs")
            }

            if(myData[indexPath.row] as! String == "SiteID"){
                piAdapter = PIAdapter(tenant: tenantID, org: orgID, username: username, password: passwd)
                piAdapter.getAllSites({ ( sites : [String : String], NSError) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alert = UIAlertController(title: "Select floor", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                        if(sites.count > 0 ){
                            for site in sites{
                                alert.addAction(UIAlertAction(title: "\(site.1)                            ", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
                                    if(siteID.isEmpty){
                                        self.saveDC("BM", key: "SiteID", value: site.0)
                                    }
                                    else{
                                        self.updateDC("BM", key: "SiteID", value: site.0)
                                        self.alert("Warning", messageInput: "Please check your Floor ID since you have updated the Site ID")
                                    }
                                    self.refresh()
                                    
                                }))
                            }
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        else{
                            self.alert("Warning", messageInput: "No Sites were found. Please check your Presence Insights")
                        }
                        
                    })
                })

            }
            else {
                if (siteID.isEmpty){
                    alert("Error", messageInput: "Please set Site ID before Floor ID")
                }
                else{
                    piAdapter.getAllFloors(siteID, callback: { (floors:[String : String], NSError) -> () in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if(floors.count>0){
                                let alert = UIAlertController(title: "Select floor", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                                for floor in floors{
                                    alert.addAction(UIAlertAction(title: "\(floor.1)                            ", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
                                        if(floorID.isEmpty){
                                            self.saveDC("BM", key: "FloorID", value: floor.0)
                                        }
                                        else{
                                            self.updateDC("BM", key: "FloorID", value: floor.0)
                                        }
                                        self.refresh()
                                    }))
                                }
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            else{
                                self.alert("Warning", messageInput: "No Floors were found. Please go check your Presence Insights")
                            }
                            
                        })
                        
                    })

                }
            }
            

        }
        else{
        
            var inputTextField: UITextField?
            //var pick = myData[indexPath.row] as! String
        
            let returnValue: String = retrieveSpecificDC("BM", key: myData[indexPath.row] as! String)

            let Prompt = UIAlertController(title: "Enter Bluemix Information", message: "You have selected to enter your \(myData[indexPath.row]).", preferredStyle: UIAlertControllerStyle.Alert)
            Prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            Prompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                //Now do whatever you want with inputTextField (remember to unwrap the optional)
                //need to store to DB
                if (returnValue == ""){
                    self.saveDC("BM", key: self.myData[indexPath.row] as! String, value: inputTextField!.text!)
                }
                else{
                    self.updateDC("BM", key: self.myData[indexPath.row] as! String, value: inputTextField!.text!)
                }

                self.refresh()
            
            }))
            Prompt.addTextFieldWithConfigurationHandler({(textField: UITextField) in
                textField.placeholder = self.myData[indexPath.row] as? String
                textField.secureTextEntry = false
                inputTextField = textField
                if(returnValue != ""){
                    inputTextField!.text = returnValue
                }
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
        //print("finish Save DC")
        
    }
    func retrieveSpecificDC ( entityName : String , key:String) -> String {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false;
        request.predicate = NSPredicate(format: "key = %@", key)

        
        let results : NSArray = try! context.executeFetchRequest(request)
        //print(results, terminator: "")
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
    func deleteDC (entityName: String, key: NSManagedObject){
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        context.deleteObject(key)
        do {
            try context.save()
        } catch _ {
        }
    }
    func refresh(){

        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
   
   
}
