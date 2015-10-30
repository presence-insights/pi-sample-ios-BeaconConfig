# IBM Presence Insights Beacon Configuration Tool

The purpose of this application is to use the ibeacon technology and leverage the Presence Insights SDK to easily detect beacons in your store and quickly add them to your Presence Insights Instance.

It also contains sample code to make an API call to retrieve a bearer token from Bluemix and post a beacon to Presence Insights.

You must use a IOS device to use a beacon SDK as the Xcode simulator does not support beacons. 

1. Open pi-sample-ios-BeaconConfig.xcodeproj.
2. Edit the ViewController.swift file to update the Bluemix credentials, tenantID, orgID, siteID, floorID, username and password. Note that all of this information can be found in your Presence Insights Dashboard.
3. Select your IOS device instead of the simulator.
4. Click **Play** to build and run the application.

The ViewController.swift appliction is a great way to see how objects are initialized and implemented. The application will perform an initial check to see if the device is already registered. If the device is registered, it will alert the user and populate the device name and type.

The sample application contains the following fields and options:

* **Setting**
	- Enter your beacon UUID information.
	- Add, remove/delete, and update.
	**Note:** IOS requires the users to provide the UUID to scan for beacons. 
* **Presence Insights Information**
	- **Username:** Located in Presence Insights at **Settings -> Security -> Credentials**.
	- **Password:** Same as Username. Ensure that you use the password corresponding to the **Username**.
	- **TeanantID:** Specific Tenant ID assigned to your account. 
	- **OrgID:** Specific Org ID assigned to your account. 
	- **SiteID:** Once you assigned the values above, it will make an api call out to grab all the sites. Pick the site name that you want to assign.
	- **floorID:** Once you assigned the values above, it will make api call out to grab all the floors associated with the site. Select the floorname you want to assign the beacons to.
	- **Get token:** Enter your Bluemix login credentials. The application stores the authentication token that is required to make the api call to configure the beacon.
* **Scan for Beacons**
	- Once you have your UUID entered and all the Presence Insights information provided, you are now ready to configure beacons to the floor.
	- It will scan for beacons around you that contains the UUID and display: Proximity, RSSI, Major, and Minor value.
	- select on the beacon you want to configure and enter beacon name you want to assign.
	- It will default to coordinate 1,1 on the map. 




Copyright 2015 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


