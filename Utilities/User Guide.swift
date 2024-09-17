//
//  User Guide.swift
//  ISS Real-Time Tracker 3D
//
//  Created by Michael Stebel on 6/15/18.
//  Copyright © 2018-2024 ISS Real-Time Tracker. All rights reserved.
//

import UIKit

/// Main user guide and context-sensitive help
struct UserGuide {
    
    // MARK: - Theme colors converted to CSS hex
    
    private static let helpViewBackgroundColor = UIColor(named: Theme.usrGuide)?.cgColor.toHex ?? "000000"
    private static let tintColor = UIColor(named: Theme.tint)?.cgColor.toHex ?? "ff4c4c"
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
    <div id="contents"></div>
    <h1>User Guide</h1>
    <h6>Covers version \(Globals.versionNumber)</h6>
    <h2>Contents</h2>
    <p>Tap an item from the list below to jump to that section:</p>
    <h4><a href="#track">Track</a></h4>
    <h4><a href="#globe">Globe</a></h4>
    <h4><a href="#passes">Passes</a></h4>
    <h4><a href="#crew">Crew</a></h4>
    <h4><a href="#settings">Settings</a></h4>
    <h4><a href="#watch">Using the Apple Watch App</a></h4>

    <div id="track"></div>
    <h2>Track</h2>
    <p>To locate and track the ISS (default), Tiangong, or Hubble in real time, tap the play button at the bottom of the screen. To pause tracking, tap the pause button.</p>
    <h4>Switching Targets</h4>
    <p>To change the target satellite to ISS, Tiangong, or Hubble, tap the target button at the top-left of the screen.</p>
    <h4>Map Formats</h4>
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
    <h5>Icon &#8212; The icon changes to represent the current target. This is the default setting.</h5>
    </li>
    <li>
    <h5>Circular</h5>
    </li>
    <li>
    <h5>Small +</h5>
    </li>
    </ul>
    <p>The time interval between map updates is automatically set from 1 to 6 seconds based on the zoom slider setting. With the slider all the way to the left, the update interval is set at 1 second. As you drag the slider right, it increases by 1 second up to a maximum interval of 6 seconds. This keeps the relative motion of the map roughly equal at all scales within a given range.</p>
    <h4>Ground Track</h4>
    <p>The orbit ground track line is drawn by default. This shows the ground track of the selected target. You can turn this on/off in Settings by tapping the settings icon from the 2D tracking map. The ground track clear button is displayed on the Tracking screen when the orbit track is on. The track is automatically cleared when the target is switched to another satellite.</p>
    <h4>3D Globe Overlay</h4>
    <p>The globe shows the current position of the selected target, its orbital track, and the viewing range circle. The globe is a photorealistic model of the Earth, complete with accurate subsolar point position, specular reflections on the water, seasonal tilt, mountain shadows, and other details. Drag the globe to rotate and pan it. The circle represents the approximate target sighting range from ground level. Autorotation is enabled by default and rotates the globe once every 90 seconds. To disable autorotation and enable/disable the globe overlay entirely, go to Settings. Tapping the expand icon on the globe overlay or the globe button on the tab bar expands the globe to full-screen mode and hides the map. Tap the reset button to reset the globe.</p>
    <h4>Copy Info to the Clipboard</h4>
    <p>Tap the copy icon next to the info box on bottom of the map to copy the target's location, altitude, velocity, and associated time to the clipboard. You can then paste the data in another app.</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>If the Information box overlay setting is turned off in Settings, the copy button will not be available.</h6>
    </li>
    <li>
    <h6>The music soundtrack will be disabled (not play) by default. Click the ♪ icon at the upper-right to toggle the soundtrack on/off.</h6>
    </li>
    </ul>
    <h4><a href="#contents">Back to contents</a></h4>
    <div id="globe"></div>
    <h2>Globe</h2>
    <p>From the Tracking screen, tapping the expand icon on the globe overlay, or the globe icon on the tab bar, expands the globe to full-screen mode and hides the map.</p>
    <p>The full-screen 3D interactive globe shows the current position of the ISS, Tiangong, and Hubble. It plots their orbital tracks and groundtrack footprints (viewing range circle). The ISS track and footprint are shown in red, gold for the Tiangong, and blue for the Hubble.</p>
    <p>The globe is a photorealistic model of the Earth complete with accurate Sun subsolar position, specular reflections on the water, seasonal tilt, mountain shadows, and other details.</p>
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
    <p>From Settings, you can select from six backgrounds for your full-screen globe. These are:</p>
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
    <li>
    <h5>James Webb Space Telescope Deep Field</h5>
    </li>
    <li>
    <h5>Just black</h5>
    </li>
    </ul>
    <h5>Notes:</h5>
    <ul>
    <li><h6>The red, gold, and blue circles represent the approximate ISS, Tiangong, and Hubble sighting ranges (i.e., footprints), respectively, from ground level under perfect conditions. Use the Pass Predictor to get viewable ISS, Tiangong, or Hubble passes from your exact location.</h6></li>
    <li><h6>Autorotation is enabled by default and rotates the globe once every 90 seconds.</h6></li>
    <li><h6>To enable/disable autorotation, tap the toggle autorotation button on the upper-right, or go to Settings.</h6></li>
    <li><h6>Tap the reset button on the upper-right of the globe scene to reset the globe.</h6></li>
    <li><h6>The music soundtrack will be disabled (not play) by default. Click the ♪ icon at the upper-right to toggle the soundtrack on/off.</h6></li>
    </ul>
    <p>Tap the collapse button on the upper-right of the globe scene, or the back button, to return to the tracking screen.</p>
    <h4><a href="#contents">Back to contents</a></h4>
    <div id="passes"></div>
    <h2>Passes</h2>
    <p>Tapping the binoculars icon at the bottom of the main screen starts computing upcoming visible ISS, Tiangong, or Hubble passes. First, ISS Real-Time Tracker 3D gets your current location's coordinates. Then, it computes the ISS, Tiangong, or Hubble passes that should be visible (weather permitting) from your location. The default number of days to predict passes is set in Settings and can be overridden in the Passes screen. The passes are listed in chronological order, along with detailed viewing data.</p>
    <p>Data for each pass includes:</p>
    <ul>
    <li>
    <h5>Date of the pass</h5>
    </li>
    <li>
    <h5>Rating (0 - 4 stars)</h5>
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
    <p>Each pass is rated based on its maximum magnitude (i.e., brightness). The brightest passes get the highest ratings. Passes are rated with 0, 1, 2, 3, or 4 stars corresponding to relatively poor, fair, good, better, or best, respectively.</p>
    <h4>Switching Targets</h4>
    <p>Tap the switch target button in the navigation bar to switch between the ISS, Tiangong, and Hubble. The table will automatically refresh and present passes for the selected station.</p>
    <h4>Adding a Pass Event to Your Calendar</h4>
    <p>Tap any pass in the table to add it as an event in your calendar. When adding a pass to your calendar, two alerts will be set: the first for 1 hour before and the second for 15 minutes before the start of the pass. The starting and ending times for the pass are saved in the event in your calendar, along with the maximum magnitude and the starting, maximum, and ending azimuths and elevations for the pass.</p>
    <h4>Changing the Number of Days to Compute</h4>
    <p>Tap the Calendar icon at the top-right of the screen to change the number of days to compute and refresh the list. You can also change the number of days so that the app remembers your settings for the next time in Settings.</p>
    <h4>Pull-to-Refresh</h4>
    <p>Drag down the table to refresh the data.</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>The pass predictions become less certain the further out in time they go.</h6>
    </li>
    <li>
    <h6>Overhead passes returned are only those visible from your location for at least 300 seconds (5 minutes) and where the ISS is illuminated by the Sun.</h6>
    </li>
    <li>
    <h6>Tiangong pass predictions do not currently include the magnitude of the passes and are, therefore, not rated. The stars are greyed-out. This may change in the future, once the magnitude data are provided for the Tiangong.</h6>
    </li>
    <li>
    <h6>If there are buildings, trees, or other obstructions, and depending upon the weather and other viewing conditions, you may not be able to spot the space station.</h6>
    </li>
    <li>
    <h6>You must give ISS Real-Time Tracker 3D access to your location. When asked, tap &quot;OK.&quot; You can change this permission in your device's Settings app.</h6>
    </li>
    <li>
    <h6>Calendar events are saved in your default calendar.</h6>
    </li>
    </ul>
    <p>Tap < to return to the map and resume tracking.</p>
    <h4><a href="#contents">Back to contents</a></h4>
    <div id="crew"></div>
    <h2>Crew</h2>
    <p>Tap the astronaut icon at the bottom of the screen to get a table of information about the current space station crew.</p>
    <h4>Switching Stations</h4>
    <p>Tap the switch target button in the navigation bar to switch between the ISS and the Chinese space station, Tiangong. The table will automatically refresh and present the crew data for the selected space station.</p>
    <h4>Crew Bios &amp; X Tweets</h4>
    <p>Tap any cell in the table to pop-up the detail view for that crewmember. This will display a brief bio. To view the full bio, tap the biography icon.</p>
    <p>To visit the crew member's X feed, open their X profile by tapping the X button. If you do not have the X app installed, it will open in Safari instead. If the crewmember does not have an X profile, the X button will not be displayed. Return to ISS Real-Time Tracker 3D by tapping "◀︎ ISS Tracker" on the top-left of X.</p>
    <p>Tap X to close the pop-up and return to the crew table.</p>
    <h4>Copy Crew Data to the Clipboard</h4>
    <p>Tap the copy icon at the top-right of the screen to copy the crew names, titles, and nationalities to the clipboard. You can then paste them into another app.</p>
    <h4>Pull-to-Refresh</h4>
    <p>Drag down the table to refresh the data.</p>
    <p>Tap < to return to the map and resume tracking.</p>
    <h4><a href="#contents">Back to contents</a></h4>
    <div id="settings"></div>
    <h2>Settings</h2>
    <p>All of your current user settings are automatically saved on your device when you exit the app or switch to another app. This also includes the current zoom slider position. Each time you run ISS Real-Time Tracker 3D, your settings are restored.</p>
    <p>Tapping the ⟳ button on the Settings title bar will clear all your user settings and change them back to their defaults. The zoom slider will reset to its default (center) position, and What's New and other messages will be restored.</p>
    <p>Tap < to return to the tracking view.</p>
    <h4><a href="#contents">Back to contents</a></h4>
    <div id="watch"></div>
    <h2>Using the Apple Watch App</h2>
    <p>If you own an Apple Watch, installing the app on your iPhone or iPad will install the companion app on your watch.</p>
    <p>The watch app shows an interactive 3D globe with the real-time positions of the ISS, Tiangong, and Hubble. It also provides live position details, the subsolar point, pass predictions for each satellite, and crew listings, stats, and bios.</p>
    <p>From the globe view, tap the reset button at the bottom-left of the watch face to restore the globe to its starting position. Tap the rotation button to disable/enable the globe's autorotation.</p>
    <p>To see live position information for the three satellites and the subsolar point, tap the live position button (third from left). The positions are updated in real-time every three seconds.</p>
    <p>Get pass predictions on your Apple Watch for the ISS, Tiangong, and Hubble. Tap the live position button, then tap the ISS, Tiangong, or Hubble position details. You'll get a list of your location's visible passes for that satellite for the next 30 days. Like the iPhone and iPad apps, each ISS pass is rated 0 - 4 stars. Tap any of the passes to get viewing details for that pass. Tapping the subsolar point provides a discussion of the subsolar point.</p>
    <p>Tap the crew button (bottom-right) to get crew information for the ISS and Tiangong. Scroll to see the crews for each station. Tap a crew member to get their details.</p>
    <p>Tap the back button to return to the globe.</p>
    <h4><a href="#contents">Back to contents</a></h4>
    \(tail)
    """
    
    static let passesHelp =
    """
    \(head)
    <p>This screen computes and presents a table of up-coming ISS, Tiangong, or Hubble passes that are predicted to be visible (weather permitting) from your location. First, ISS Real-Time Tracker 3D gets your current location's coordinates. Then, it computes the passes that should be visible (weather permitting) from your location. The default number of days to predict passes is set in Settings and can be overridden in the Passes screen. The passes are listed in chronological order along with detailed viewing data.</p>
    <p>Data for each pass includes:</p>
    <ul>
    <li>
    <h5>Date of the pass</h5>
    </li>
    <li>
    <h5>Rating (0 - 4 stars)</h5>
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
    <p>Each pass is rated based on its maximum magnitude (i.e., brightness). The brightest passes get the highest ratings. Passes are rated with 0, 1, 2, 3, or 4 stars corresponding to relatively poor, fair, good, better, or best, respectively.</p>
    <h4>Switching Targets</h4>
    <p>Tap the switch target button in the navigation bar to switch between the ISS, Tiangong, and Hubble. The table will automatically refresh and present passes for the selected station.</p>
    <h4>Adding a Pass Event to Your Calendar</h4>
    <p>Tap any pass in the table to add it as an event in your calendar. When adding a pass to your calendar, two alerts will be set: the first for 1 hour before, and the second for 15 minutes before the start of the pass. The starting and ending times for the pass are saved in the event in your calendar, along with the maximum magnitude, as well as the starting, maximum, and ending azimuths and elevations for the pass.</p>
    <h4>Change Number of Days to Compute &amp; Refresh</h4>
    <p>Tap the Calendar icon at the top-right of the screen to change the number of days to compute and refresh the list. To change the number of days so that the app remembers your setting for next time, change it in Settings.</p>
    <h4>Pull-to-Refresh</h4>
    <p>Drag down the table to refresh the data.</p>
    <h5>Notes:</h5>
    <ul>
    <li>
    <h6>The pass predictions become less certain the further out in time they go.</h6>
    </li>
    <li>
    <h6>Overhead passes returned are only those visible from your location for at least 300 seconds (5 minutes) and where the ISS is illuminated by the Sun.</h6>
    </li>
    <li>
    <h6>Tiangong pass predictions do not currently include the magnitude of the passes and are, therefore, not rated. The stars are greyed-out. This may change in the future, once the magnitude data are provided for the Tiangong.</h6>
    </li>
    <li>
    <h6>If there are buildings, trees, or other obstructions, and depending upon the weather and other viewing conditions, you may not be able to spot the space station.</h6>
    </li>
    <li>
    <h6>You must give ISS Real-Time Tracker 3D access to your location. When asked, tap &quot;OK.&quot; You can change this permission in your device's Settings app.</h6>
    </li>
    <li>
    <h6>Calendar events are saved in your default calendar.</h6>
    </li>
    </ul>
    <p>Tap < to return to the map and resume tracking.</p>
    \(tail)
    """
    
    static let fullGlobe =
    """
    \(head)
    <p>The full-screen 3D interactive globe shows the current position of the ISS, Tiangong, and Hubble. It plots their orbital tracks and groundtrack footprints (viewing range circle). The ISS track and footprint are shown in red, gold for the Tiangong, and blue for the Hubble.</p>
    <p>The globe is a photorealistic model of the Earth complete with accurate Sun subsolar position, specular reflections on the water, seasonal tilt, mountain shadows, and other details.</p>
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
    <p>From Settings, you can select from six backgrounds for your full-screen globe. These are:</p>
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
    <li>
    <h5>James Webb Space Telescope Deep Field</h5>
    </li>
    <li>
    <h5>Just black</h5>
    </li>
    </ul>
    <h5>Notes:</h5>
    <ul>
    <li><h6>The red, gold, and blue circles represent the approximate ISS, Tiangong, and Hubble sighting ranges (i.e., footprints), respectively, from ground level under perfect conditions. Use the Pass Predictor to get viewable ISS, Tiangong, or Hubble passes from your exact location.</h6></li>
    <li><h6>Autorotation is enabled by default and rotates the globe once every 90 seconds.</h6></li>
    <li><h6>To enable/disable autorotation, tap the toggle autorotation button on the upper-right, or go to Settings.</h6></li>
    <li><h6>Tap the reset button on the upper-right of the globe scene to reset the globe.</h6></li>
    <li><h6>The music soundtrack will be disabled (not play) by default. Click the ♪ icon at the upper-right to toggle the soundtrack on/off.</h6></li>
    </ul>
    <p>Tap the collapse button on the upper-right of the globe scene, or the back button, to return to the tracking screen.</p>
    \(tail)
    """
    
    static let crewHelp =
    """
    \(head)
    <p>This screen provides a table of information about the current space station crew. It also lets you drill down to deeper information about each crewmember and even tweet a crewmember.</p>
    <h4>Switching Stations</h4>
    <p>Tap the switch target button in the navigation bar to switch between the ISS and Tiangong. The table will automatically refresh and present the crew data for the selected space station.</p>
    <h4>Crew Bios &amp; X Tweets</h4>
    <p>Tap any cell in the table to pop up the detail view for that crewmember. This will display a brief bio. To view the full bio, tap the biography icon.</p>
    <p>To visit the crew member's X feed, open their X profile by tapping the X button. If you do not have the X app installed, it will open in Safari instead. If the crewmember does not have an X profile, the X button will not be displayed. Return to ISS Real-Time Tracker 3D by tapping "◀︎ ISS Tracker" on the top-left of X.</p>
    <p>Tap X to close the pop-up and return to the crew table.</p>
    <h4>Copy Crew Data to the Clipboard</h4>
    <p>Tap the copy icon at the top-right of the screen to copy the crew names, titles, and nationalities to the clipboard. You can then paste them into another app.</p>
    <h4>Pull-to-Refresh</h4>
    <p>Drag down the table to refresh the data.</p>
    <p>Tap < to return to the map and resume tracking.</p>
    \(tail)
    """
    
    static let settingsHelp =
    """
    \(head)
    <p>All of your current user preferences are automatically saved on your device when you exit the app or switch to another app. This also includes the current zoom slider position. Each time you run ISS Real-Time Tracker 3D, your preferences are restored to their previous settings.</p>
    <p>Tapping the reset button on the Settings title bar will clear all your user settings and change them back to their defaults. The tracking map view zoom slider will also reset to its default (center) position, and What's New and other messages will be restored.</p>
    <p>Tap < to return to the tracking view.</p>
    \(tail)
    """
}
