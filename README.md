# CrimeSpotters

Hello and thank you for checking out the repo InformedCity.
</p>

This app was a project created in the second week of my time at The Iron Yard Detroit. It began as an assignment to learn how to pull information from APIs and has only grown.</p>

InformedCity works with information provided by the city of Detroit through the Opportunity Project to help keep citizens informed about the city. We are providing data on Police and Fire departments, crime locations, and residential property values based on properties sold in Q1 of 2016.</p>

InformedCity is built using Objective-C, and it using MapKit and UIKit for it's display. It uses NSURLSession to call and receive data from the various APIs, and that data is decoded and manually parsed into individual data sets. The Interface uses a UICollectionView to display buttons, which when pushed the first time, will call the API, prepare the data, and load that data onto the screen. Pushing the button a second time will remove the data. Once the data was been loaded, it will stay in temporary memory until the app is restarted, so loading times will shorten after the first call. </p>


Link to App on Itunes: https://itunes.apple.com/us/app/informedcity/id1126431261?mt=8# </p>
Link to App Page on my site: http://appsbypat.com/index.php/project/informed-city/
