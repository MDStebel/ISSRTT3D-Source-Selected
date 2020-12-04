//
//  User Guide.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 6/15/18.
//  Copyright © 2018-2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import UIKit


/// Main user guide and context sensitive help
struct UserGuide {
    
    // MARK: - Theme colors converted to CSS hex
    
    private static let helpViewBackgroundColor = UIColor(named: Theme.usrGuide)?.cgColor.toHex ?? "000000"
    private static let tintColor = UIColor(named: Theme.tint)?.cgColor.toHex ?? "ff0000"
    private static let whiteColor = UIColor(named: Theme.white)?.cgColor.toHex ?? "ffffff"
    
    
    // MARK: - Common code
    
    static let head =
    """
    <!doctype html>
    <html>
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="initial-scale=1.0" />
    <style type="text/css">
    a {
    color: #\(whiteColor);
    font-style: normal;
    text-decoration-line: none;
    }
    h1, h2, h3, h4 {
    color: #\(tintColor);
    }
    h5, h6 {
    color: #\(whiteColor);
    }
    p {
    color: #\(whiteColor);
    }
    li {
    color: #\(tintColor);
    }
    body {
    background-color: #\(helpViewBackgroundColor);
    }
    </style>
    </head>
    <body style="font-family: 'Avenir Next', 'San Francisco', Helvetica, Arial, sans-serif; color: #333333;">
    """
    
    static let tail =
    """
    <h6>Covers version \(Globals.versionNumber)</h6>
    <h5>\(Globals.copyrightString)</h5>
    </body>
    </html>
    """
    
    // MARK: - Content for User Guide & context-sensitive help
    
    static let helpContentHTML =
    """
    \(head)
    <h1>User Guide</h1>
    <h2>Contents</h2>
    <p>Tap an item from the list below to jump to that section:</p>
    <h3><a href="#passes">Pass Predictions</a></h3>
    <h3><a href="#track">Real-Time Tracking</a></h3>
    <h3><a href="#globe">Interactive 3D Globe</a></h3>
    <h3><a href="#crew">Current Crew</a></h3>
    <h3><a href="#streaming">Live Earth View</a></h3>
    <h3><a href="#nasatv">NASA TV</a></h3>
    <h3><a href="#settings">Settings</a></h3>
    <div id="passes"></div>
    <h2>Pass Predictions</h2>
    <p>Tapping the telescope icon at the bottom of the main screen starts the process of computing up-coming visible ISS passes. First, ISS Real-Time Tracker gets your current location's coordinates. Then, it computes the visible passes for that location. The default number of days to predict passes is set in Settings. The passes are listed in chronological order along with detailed viewing data.</p>
    <p>Data for each pass includes:</p>
    <ul>
    <li>
    <h5>Date of the pass</h5>
    </li>
    <li>
    <h5>Rating (0, 1, 2, 3, or 4 stars)</h5>
    </li>
    <li>
    <h5>Visible duration (in minutes and seconds)</h5>
    </li>
    <li>
    <h5>Max visual magnitude (using same scale as astronomical brightness, i.e., apparent magnitude)</h5>
    </li>
    <li>
    <h5>Time, azimuth, elevation, and compass direction for the start time, max elevation time, and end time</h5>
    </li>
    </ul>
    <p>Each pass is rated based on its maximum magnitude (i.e., brightness). The brightest passes get the highest ratings. Passes are rated with 0, 1, 2, 3, or 4 stars corresponding to poor, fair, good, better, or best, respectively.</p>
    <h4>Adding a Pass Event to Your Calendar</h4>
    <p>Tap any pass in the table to add it as an event in your calendar. When adding a pass to your calendar, two alerts will be set: the first for 1 hour before and the second for 20 minutes before the start of the pass. The starting and ending times for the pass are saved in the event in your calendar, along with the maximum magnitude, as well as the starting, maximum, and ending azimuths and elevations for the pass.</p>
    <h4>Change Number of Days to Compute &amp; Refresh</h4>
    <p>Tap the Calendar icon at the top-right of the screen to change the number of days to compute and refresh the list. To change the number of days so that the app remembers your setting for next time, change it in Settings.</p>
    <h4>Pull-to-Refresh</h4>
    <p>Pull down the table to refresh the data.</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>The pass predictions become less certain the further out in time they go.</h6>
    </li>
    <li>
    <h6>Overhead passes returned are only those visible from your location for at least 300 seconds (5 minutes) and where the ISS is illuminated by the Sun.</h6>
    </li>
    <li>
    <h6>If there are buildings, trees, or other obstructions, and depending upon the weather and other viewing conditions, you may not be able to spot the station.</h6>
    </li>
    <li>
    <h6>You must give ISS Real-Time Tracker access to your location. When asked, tap &quot;OK.&quot; You can change this permission in your device's Settings app.</h6>
    </li>
    <li>
    <h6>Calendar events are saved in your default calendar.</h6>
    </li>
    </ul>
    <p>Tap ⟵ to return to the map and resume tracking.</p>
    <div id="track"></div>
    <h2>Tracking the ISS</h2>
    <p>To locate and track the International Space Station in real time, tap the play button at the bottom of the screen. To pause tracking, tap the pause button.</p>
    <p>You can select from the following map types in Settings from the Tracking screen:</p>
    <ul>
    <li>
    <h5>Standard (shows names, roads, and borders)</h5>
    </li>
    <li>
    <h5>Satellite (shows terrain only)</h5>
    </li>
    <li>
    <h5>Hybrid (the default setting: shows borders, names, roads, and terrain)</h5>
    </li>
    </ul>
    <p>To zoom in or out of the map, use the slider control at the top of the map. This changes the scale of the map, which is displayed in degrees to the right of the zoom slider.</p>
    <p>You can set the map scale range in Settings to any of the following ranges (in degrees):</p>
    <ul>
    <li>
    <h5>Fine: 0.10° - 3.00° (0.15° - 3.00° for iPad)</h5>
    </li>
    <li>
    <h5>Small: 0.33° - 10.00°</h5>
    </li>
    <li>
    <h5>Medium: 1.00° - 30.00° (the default setting)</h5>
    </li>
    <li>
    <h5>Large: 3.00° - 90.00°</h5>
    </li>
    </ul>
    <p>There are three styles of markers, which you can select in Settings: </p>
    <ul>
    <li>
    <h5>ISS icon (the default setting)</h5>
    </li>
    <li>
    <h5>Circular</h5>
    </li>
    <li>
    <h5>Small +</h5>
    </li>
    </ul>
    <p>The time interval between map updates is automatically set from 1 to 6 seconds, based upon the zoom slider setting. With the slider all the way to the left, the update interval is set at 1 second. As you drag the slider right, it increases by 1 second up to a maximum interval of 6 seconds. This keeps the relative motion of the map roughly equal at all scales within a given range.</p>
    <h4>Ground Track</h4>
    <p>The orbit ground track line is drawn by default. This shows the ground track of the ISS. You can turn this on/off in Settings by tapping the settings icon from the Tracking screen. When the orbit track is on, the ground track clear button is displayed on the Tracking screen.</p>
    <h4>Interactive 3D Globe</h4>
    <p>The globe shows the current position of the ISS and its orbital track. This is a photorealistic model of the Earth complete with accurate Sun subsolar position, specular reflections on the water, seasonal tilt, mountain shadows, and other details. Drag the globe to rotate and pan it. The circle represents the approximate ISS sighting range from ground level. Auto-rotation is enabled by default and rotates the globe once every 90 seconds. To disable auto-rotation, as well as to enable/disable the globe entirely, go to Settings. Tapping the expand icon on the globe overlay, or the globe button on the tab bar, expands the globe to fullscreen mode and hides the map.</p>
    <h4>Copy Info to the Clipboard</h4>
    <p>Tap the copy icon next to the info box on bottom of the map to copy the ISS's location, altitude, velocity, and associated time to the clipboard. You can then paste the data in another app.</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>If the Information box overlay setting is turned off in Settings, the copy button will not be available.</h6>
    </li>
    <li>
    <h6>The music soundtrack will be disabled (not play) by default. Click the ♪ icon at the upper-right to toggle the soundtrack on/off.</h6>
    </li>
    </ul>
    <div id="globe"></div>
    <h2>Interactive 3D Globe</h2>
    <p>From the Tracking screen, tapping the expand icon on the globe overlay, or the globe button on the tab bar, expands the globe to fullscreen mode and hides the map.</p>
    <p>The 3D interactive globe shows the current position of the ISS and its orbital track. This is a photorealistic model of the Earth complete with accurate Sun subsolar position, specular reflections on the water, seasonal tilt, mountain shadows, and other details.</p>
    <p>The globe starts updating automatically when in full-screen mode.</p>
    <h4>Using Gestures</h4>
    <ul>
    <li>
    <h5>Drag the globe with one finger to rotate the globe.</h5>
    </li>
    <li>
    <h5>Drag the globe with two fingers to move it around (translation).</h5>
    </li>
    <li>
    <h5>Use pinch gestures to zoom in/out of the globe.</h5>
    </li>
    <li>
    <h5>Rotate with two fingers to tilt the globe.</h5>
    </li>
    </ul>
    <h4>Choose Your Background</h4>
    <p>From Settings you can select from four background images for your fullscreen globe. These are:
    <ul>
    <li>
    <h5>Hubble Deep Field (the default)</h5>
    </li>
    <li>
    <h5>Milky Way</h5>
    </li>
    <li>
    <h5>Orion Nebula</h5>
    </li>
    <li>
    <h5>Tarantula Nebula in the Large Magellanic Cloud</h5>
    </li>
    </ul>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>The red circle represents the approximate ISS sighting range from ground level under perfect conditions. Use the Pass Predictor to get viewable passes from your exact location.</h6>
    </li>
    <li>
    <h6>Auto-rotation is enabled by default and rotates the globe once every 90 seconds.</h6>
    </li>
    <li>
    <h6>To disable auto-rotation, as well as to enable/disable the globe entirely, go to Settings.</p>
    </li>
    </ul>
    <p>Tap the collapse icon on the upper-right of the scene to return to the map and resume tracking.</p>
    <div id="crew"></div>
    <h2>Crew</h2>
    <p>Tap the space suit button at the bottom of the screen to get a table of information about the current ISS crew.</p>
    <h4> Crew Bios &amp; Tweets</h4>
    <p>Tap any cell in the table to pop-up the detail view for that crew member. This will display a brief bio. To view a full bio, tap the button on the bottom-left.</p>
    <p>To visit the crew member's Twitter feed, open their Twitter profile by tapping the Twitter button. If you do not have the Twitter app installed, it will open in Safari instead. If the crew member does not have a Twitter profile, the Twitter button will not be displayed. Return to ISS Real-Time Tracker by tapping "◀︎ ISS Tracker" on the top-left of Twitter.</p>
    <p>Tap X to close the pop-up and return to the crew table.</p>
    <h4>Copy Crew Data to the Clipboard</h4>
    <p>Tap the copy icon at the top-right of the screen to copy the crew names, titles, and nationalities to the clipboard. You can then paste them in another app.</p>
    <h4>Pull-to-Refresh</h4>
    <p>Pull down the table to refresh the data.</p>
    <p>Tap ⟵ icon to return to the map and resume tracking.</p>
    <div id="streaming"></div>
    <h2>Live Earth View</h2>
    <p>Live streaming HD video of Earth is provided via NASA's External High Definition Camera (EHDC).</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>The video will sometimes sequence through different views.</h6>
    </li>
    <li>
    <h6>The Live Earth View feature of ISS Real-Time Tracker gets its video stream from NASA. Please note the following: The live HD video is obtained from a camera mounted on Node 2, which is located on the forward part of the ISS. The camera looks forward at an angle so that the International Docking Adapter 2 (IDA2) is visible. If the Node 2 camera is not available due to operational considerations for a longer period of time, a continuous loop of recorded HDEV imagery will be displayed. In that case, the loop will have “Previously Recorded” on the image to distinguish it from the live stream from the Node 2 camera.</h6>
    </li>
    <li>
    <h6>If your screen is blank, then the EHDC is not currently operating, or the ISS is in nighttime. Just try again later.</h6>
    </li>
    </ul>
    <p>Tap ⟵ to return to the map.</p>
    <div id="nasatv"></div>
    <h2>NASA TV</h2>
    <p>NASA TV airs a variety of regularly scheduled, pre-recorded educational and public relations programming 24 hours a day. The network also provides an array of live programming, such as 24-hour coverage of missions, events (spacewalks, media interviews, educational broadcasts), press conferences & rocket launches.</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>If your screen is blank, then NASA TV is currently off the air.</h6>
    </li>
    </ul>
    <p>Tap ⟵ to return to the map.</p>
    <div id="settings"></div>
    <h2>Settings</h2>
    <p>All of your current user settings are automatically saved on your device when you exit the app or switch to another app. This also includes the current zoom slider position. Each time you run ISS Real-Time Tracker, your settings are restored.</p>
    <p>Tapping the ⟳ button on the Settings title bar, will clear all your user settings and change them back to their defaults. The zoom slider will reset to its default (center) position, and What's New and other messages will be restored.</p>
    <p>Tap ⟵ to return to the tracking view.</p>
    \(tail)
    """
    
    static let passesHelp =
    """
    \(head)
    <h2>Pass Predictions</h2>
    <p>Tapping the telescope icon at the bottom of the main screen starts the process of computing up-coming visible ISS passes. First, ISS Real-Time Tracker gets your current location's coordinates. Then, it computes the visible passes for that location. The default number of days to predict passes is set in Settings. The passes are listed in chronological order along with detailed viewing data.</p>
    <p>Data for each pass includes:</p>
    <ul>
    <li>
    <h5>Date of the pass</h5>
    </li>
    <li>
    <h5>Rating (0, 1, 2, 3, or 4 stars)</h5>
    </li>
    <li>
    <h5>Visible duration (in minutes and seconds)</h5>
    </li>
    <li>
    <h5>Max visual magnitude (using same scale as astronomical brightness, i.e., apparent magnitude)</h5>
    </li>
    <li>
    <h5>Time, azimuth, elevation, and compass direction for the start time, max elevation time, and end time</h5>
    </li>
    </ul>
    <p>Each pass is rated based on its maximum magnitude (i.e., brightness). The brightest passes get the highest ratings. Passes are rated with 0, 1, 2, 3, or 4 stars corresponding to poor, fair, good, better, or best, respectively.</p>
    <h4>Adding a Pass Event to Your Calendar</h4>
    <p>Tap any pass in the table to add it as an event in your calendar. When adding a pass to your calendar, two alerts will be set: the first for 1 hour before and the second for 20 minutes before the start of the pass. The starting and ending times for the pass are saved in the event in your calendar, along with the maximum magnitude, as well as the starting, maximum, and ending azimuths and elevations for the pass.</p>
    <h4>Change Number of Days to Compute &amp; Refresh</h4>
    <p>Tap the Calendar icon at the top-right of the screen to change the number of days to compute and refresh the list. To change the number of days so that the app remembers your setting for next time, change it in Settings.</p>
    <h4>Pull-to-Refresh</h4>
    <p>Pull down the table to refresh the data.</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>The pass predictions become less certain the further out in time they go.</h6>
    </li>
    <li>
    <h6>Overhead passes returned are only those visible from your location for at least 300 seconds (5 minutes) and where the ISS is illuminated by the Sun.</h6>
    </li>
    <li>
    <h6>If there are buildings, trees, or other obstructions, and depending upon the weather and other viewing conditions, you may not be able to spot the station.</h6>
    </li>
    <li>
    <h6>You must give ISS Real-Time Tracker access to your location. When asked, tap &quot;OK.&quot; You can change this permission in your device's Settings app.</h6>
    </li>
    <li>
    <h6>Calendar events are saved in your default calendar.</h6>
    </li>
    </ul>
    <p>Tap ⟵ to return to the map and resume tracking.</p>
    \(tail)
    """
    
    static let trackingHelp =
    """
    \(head)
    <h2>Tracking the ISS</h2>
    <p>To locate and track the International Space Station in real time, tap the play button at the bottom of the screen. To pause tracking, tap the pause button.</p>
    <p>You can select from the following map types in Settings, by tapping the settings icon from the Tracking screen:</p>
    <ul>
    <li>
    <h5>Standard (shows names, roads, and borders)</h5>
    </li>
    <li>
    <h5>Satellite (shows terrain only)</h5>
    </li>
    <li>
    <h5>Hybrid (the default setting: shows borders, names, roads, and terrain)</h5>
    </li>
    </ul>
    <p>To zoom in or out of the map, use the slider control at the top of the map. This changes the scale of the map, which is displayed in degrees to the right of the zoom slider.</p>
    <p>You can set the map scale range in Settings to any of the following ranges (in degrees):</p>
    <ul>
    <li>
    <h5>Fine: 0.10° - 3.00° (0.15° - 3.00° for iPad)</h5>
    </li>
    <li>
    <h5>Small: 0.33° - 10.00°</h5>
    </li>
    <li>
    <h5>Medium: 1.00° - 30.00° (the default setting)</h5>
    </li>
    <li>
    <h5>Large: 3.00° - 90.00°</h5>
    </li>
    </ul>
    <p>There are three styles of markers, which you can select in Settings: </p>
    <ul>
    <li>
    <h5>ISS icon (the default setting)</h5>
    </li>
    <li>
    <h5>Circular</h5>
    </li>
    <li>
    <h5>Small +</h5>
    </li>
    </ul>
    <p>The time interval between map updates is automatically set from 1 to 6 seconds, based upon the zoom slider setting. With the slider all the way to the left, the update interval is set at 1 second. As you drag the slider right, it increases by 1 second up to a maximum interval of 6 seconds. This keeps the relative motion of the map roughly equal at all scales within a given range.</p>
    <h4>Ground Track</h4>
    <p>The orbit ground track line is drawn by default. This shows the ground track of the ISS. You can turn this on/off in Settings by tapping the settings icon from the Tracking screen. When the orbit track is on, the ground track clear button is displayed on the Tracking screen.</p>
    <h4>Interactive 3D Globe</h4>
    <p>The globe shows the current position of the ISS and its orbital track. This is a photorealistic model of the Earth complete with accurate Sun position, specular reflections on the water, seasonal tilt, mountain shadows, and other details. Drag the globe to rotate and pan it. Pinch to zoom in/out. The circle represents the approximate ISS sighting range from ground level. Auto-rotation is enabled by default and rotates the globe once per minute. To disable auto-rotation, as well as to enable/disable the globe entirely, go to Settings. Tapping the expand icon on the globe overlay expands the globe to fullscreen mode and hides the map.</p>
    <h4>Copy Info to the Clipboard</h4>
    <p>Tap the copy icon next to the info box on bottom of the map to copy the ISS's location, altitude, velocity, and associated time to the clipboard. You can then paste the data in another app.</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>If the Information box overlay setting is turned off in Settings, the copy button will not be available.</h6>
    </li>
    <li>
    <h6>The music soundtrack will be disabled (not play) by default. Click the ♪ icon at the upper-right to toggle the soundtrack on/off.</h6>
    </li>
    </ul>
    \(tail)
    """
    
    static let fullGlobe =
    """
    \(head)
    <h2>Interactive 3D Globe</h2>
    <p>From the Tracking screen, tapping the expand icon on the globe overlay, or the globe button on the tab bar, expands the globe to fullscreen mode and hides the map.</p>
    <p>The 3D interactive globe shows the current position of the ISS and its orbital track. This is a photorealistic model of the Earth complete with accurate Sun subsolar position, specular reflections on the water, seasonal tilt, mountain shadows, and other details.</p>
    <p>The globe starts updating automatically when in full-screen mode.</p>
    <h4>Using Gestures</h4>
    <ul>
    <li>
    <h5>Drag the globe with one finger to rotate the globe.</h5>
    </li>
    <li>
    <h5>Drag the globe with two fingers to move it around (translation).</h5>
    </li>
    <li>
    <h5>Use pinch gestures to zoom in/out of the globe.</h5>
    </li>
    <li>
    <h5>Rotate with two fingers to tilt the globe.</h5>
    </li>
    </ul>
    <h4>Choose Your Background</h4>
    <p>From Settings you can select from four background images for your fullscreen globe. These are:
    <ul>
    <li>
    <h5>Hubble Deep Field (the default)</h5>
    </li>
    <li>
    <h5>Milky Way</h5>
    </li>
    <li>
    <h5>Orion Nebula</h5>
    </li>
    <li>
    <h5>Tarantula Nebula in the Large Magellanic Cloud</h5>
    </li>
    </ul>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>The red circle represents the approximate ISS sighting range from ground level under perfect conditions. Use the Pass Predictor to get viewable passes from your exact location.</h6>
    </li>
    <li>
    <h6>Auto-rotation is enabled by default and rotates the globe once every 90 seconds.</h6>
    </li>
    <li>
    <h6>To disable auto-rotation, as well as to enable/disable the globe entirely, go to Settings.</p>
    </li>
    </ul>
    <p>Tap the collapse icon on the upper-right of the scene to return to the map and resume tracking.</p>
    \(tail)
    """
    
    static let crewHelp =
    """
    \(head)
    <h2>Crew Stats</h2>
    <p>This screen provides a table of information about the current ISS crew.</p>
    <h4>Crew Bios &amp; Tweets</h4>
    <p>Tap any cell in the table to pop-up the detail view for that crew member. This will display a brief bio. To view a full bio, tap the button on the bottom-left.</p>
    <p>To visit the crew member's Twitter feed, open their Twitter profile by tapping the Twitter button. If you do not have the Twitter app installed, it will open in Safari instead. If the crew member does not have a Twitter profile, the Twitter button will not be displayed. Return to ISS Real-Time Tracker by tapping "◀︎ ISS Tracker" on the top-left of Twitter.</p>
    <p>Tap X to close the pop-up and return to the crew table.</p>
    <h4>Copy Crew Data to the Clipboard</h4>
    <p>Tap the copy icon at the top-right of the screen to copy the crew names, titles, and nationalities to the clipboard. You can then paste them in another app.</p>
    <h4>Pull-to-Refresh</h4>
    <p>Pull down the table to refresh the data.</p>
    <p>Tap ⟵ icon to return to the map and resume tracking.</p>
    \(tail)
    """
    
    static let streamingVideoHelp =
    """
    \(head)
    <h2>Live Earth View</h2>
    <p>Live streaming HD video of Earth is provided via NASA's External High Definition Camera (EHDC).</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>The video will sometimes sequence through different views.</h6>
    </li>
    <li>
    <h6>The Live Earth View feature of ISS Real-Time Tracker gets its video stream from NASA. Please note the following: The live HD video is obtained from a camera mounted on Node 2, which is located on the forward part of the ISS. The camera looks forward at an angle so that the International Docking Adapter 2 (IDA2) is visible. If the Node 2 camera is not available due to operational considerations for a longer period of time, a continuous loop of recorded HDEV imagery will be displayed. In that case, the loop will have “Previously Recorded” on the image to distinguish it from the live stream from the Node 2 camera.</h6>
    </li>
    <li>
    <h6>If your screen is blank, then the EHDC is not currently operating, or the ISS is in nighttime. Just try again later.</h6>
    </li>
    </ul>
    <p>Tap ⟵ to return to the map.</p>
    \(tail)
    """
    
    static let NASATVVideoHelp =
    """
    \(head)
    <h2>NASA TV</h2>
    <p>NASA TV airs a variety of regularly scheduled, pre-recorded educational and public relations programming 24 hours a day. The network also provides an array of live programming, such as 24-hour coverage of missions, events (spacewalks, media interviews, educational broadcasts), press conferences & rocket launches.</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>If your screen is blank, then NASA TV is currently off the air.</h6>
    </li>
    </ul>
    <p>Tap ⟵ to return to the map.</p>
    \(tail)
    """
    
    static let settingsHelp =
    """
    \(head)
    <h2>Settings</h2>
    <p>All of your current user settings are automatically saved on your device when you exit the app or switch to another app. This also includes the current zoom slider position. Each time you run ISS Real-Time Tracker, your settings are restored.</p>
    <p>Tapping the ⟳ button on the Settings title bar, will clear all your user settings and change them back to their defaults. The zoom slider will reset to its default (center) position, and What's New and other messages will be restored.</p>
    <p>Tap ⟵ to return to the tracking view.</p>
    \(tail)
    """
}
