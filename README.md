#MobileFirst Platform - PI Beacon Configuration Tool 
The purpose of this app is to use ibeacon technology and leveraging PI SDK to easily detect beacons in your store and quickly add them to your Presence Insights Instance.

Also contains sample code to make an API call to retrieve bearer token from Bluemix and posting a beacon to Presence Insights.

##Instructions
You would need to use a ios device to use Beacon SDK. Xcode simulator does not support beacons/BLE. 

* Open pi-sample-ios-BeaconConfig.xcodeproj
* Make sure you select your ios device instead of the simulator
* Click the play button to build and run


##Quick Walkthrough
On the sample app, there are 2 Cells an Settings button the user can press:

* "Setting"
	- This is where you would enter your beacon UUID information.
	- You can add/remove(delete)/update
	- *Note:* IOS requires the users to provide the UUID to scan for beacons. 
* "Presence Insights Information"
	- **Username:** Can be found in your Presence Insights Settings -> Security -> Credentials
	- **Password:** Same as Username.. but make sure you use the password corresponding to Username.
	- **TeanantID:** Specific Tenant ID assigned to your account. 
	- **OrgID:** Specific Org ID assigned to your account. 
	- **SiteID:** Once you assigned the values above, it will make api call out to grab all the sites. Pick the site name that you want to assign.
	- **floorID:** Once you assigned the values above, it will make api call out to grab all the floors associated with the site. Please select the floorname you want to assign the beacons to.
	- **Get token:** Enter your Bluemix login credentials. It will store the authentication token that is required to make the api call to configure the beacon.
* "Scan for Beacons"
	- Once you have your UUID entered and all the Presence Insights information provided, you are now ready to configure beacons to the floor.
	- It will scan for beacons around you that contains the UUID and display: Proximity, RSSI, Major, and Minor value.
	- select on the beacon you want to configure and enter beacon name you want to assign.
	- It will default to coordinate 1,1 on the map. 




Copyright 2015 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


