/* Copyright 2018 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */


// You can run your app in Qt Creator by pressing Alt+Shift+R.
// Alternatively, you can run apps through UI using Tools > External > AppStudio > Run.
// AppStudio users frequently use the Ctrl+A and Ctrl+I commands to
// automatically indent the entirety of the .qml file.


import QtQuick 2.7
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.11
import QtPositioning 5.3
import QtSensors 5.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.3

Rectangle {
    id: app
    width: 800
    height: 600

    property string bearerToken : "AAAAAAAAAAAAAAAAAAAAAI%2FBuAAAAAAAqbFCZnDgSTyebXFhM1d%2Brw7K8Hs%3DrhdQWj6iQ0LSmC8H4Nd950dpTEC97vJw8kuUQqppLP1wYZG8vp"
    property string tweetHashtag: ""
    property variant tweetText: []
    property variant tweetImage: []
    property variant tweetArray: []
    property string compassMode: "Compass"
    property string onMode: "On"
    property string stopMode: "Stop"
    property string closeMode: "Close"
    property string currentModeText: stopMode
    property string currentModeImage: "images/baseline_menu_black_18dp.png"



// Create tab bars
    TabBar {
        id: bar
        width: parent.width
        background: Rectangle {
                color: "steelBlue"
            }

        TabButton {
            text: "Tweets"
        }

        TabButton {
            text: "Map"
//            onClicked: {map_slide.open()}
        }
    }

 // Create a layout for each tab bar
    StackLayout {
        anchors{
            top: bar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        currentIndex: bar.currentIndex

// tweets layout
        Item {
           id: tweets_layout

           Rectangle {
               anchors.fill: parent

                   ListModel {
                       id: model
                   }

                   ListView {
                       id: listview
                       anchors.fill: parent
                       model: model
                       delegate: Text {
                                    text: tweetText

                                Image {
                                    source: tweetImage
                                    }
                       }
                 }

                   RowLayout {
                       id: searchBar
                       anchors.bottom: parent.bottom
                       width: parent.width
                       height: 40
                       Behavior on opacity { NumberAnimation{} }
                       visible: opacity ? true : false
                       TextField {
                           id: searchText
                           Behavior on opacity { NumberAnimation{} }
                           visible: opacity ? true : false
                           property bool ignoreTextChange: false
                           placeholderText: qsTr("Search hashtags...")
                           Layout.fillWidth: true
                       }

                       ToolButton {
                           id: searchButton
                           iconSource:  "images/baseline_search_black_18dp.png"
                           onClicked: getData()
                       }
                   }

//                   Button {
//                       anchors.bottom: parent.bottom
//                       width: parent.width
//                       text: "GET Data"
//                       onClicked: getData()
//                   }
//               }
           }
        }

// map layout
        Item {
            id:map_layout
            Rectangle {
                anchors.fill: parent

                MapView {
                    id : mapView
                    anchors.fill: parent

                    Map {
                       id: map
                       basemap: BasemapStreets {}

                       // start the location display
                       onLoadStatusChanged: {
                           if (loadStatus === Enums.LoadStatusLoaded) {
                               // populate list model with modes
                               autoPanListModel.append({name: compassMode, image: "images/baseline_compass_calibration_black_18dp.png"});
                               autoPanListModel.append({name: onMode, image: "images/baseline_location_searching_black_18dp.png"});
                               autoPanListModel.append({name: stopMode, image: "images/baseline_location_disabled_black_18dp.png"});
                               autoPanListModel.append({name: closeMode, image: "images/baseline_close_black_18dp.png"});
                           }
                       }
                }
                    // create graphic layer
                    GraphicsOverlay {
                            id: graphicsOverlay

                    }

                    SimpleMarkerSymbol {
                        id: pointSymbol
                        style: Enums.SimpleMarkerSymbolStyleCircle
                        color: "red"
                        size: 12
                    }

                    // set the location display's position source
                    locationDisplay {
                        positionSource: PositionSource {
                        }
                        compass: Compass {}
                    }
            }

                Rectangle {
                    id: rect
                    anchors.fill: parent
                    visible: autoPanListView.visible
                    color: "black"
                    opacity: 0.5
                }

                ListView {
                    id: autoPanListView
                    anchors {
                        right: parent.right
                        top: parent.top
                        margins: 20
                    }
                    visible: false
                    width: parent.width
                    height: 300
                    spacing: 10
                    model: ListModel {
                        id: autoPanListModel
                    }

                    delegate: Row {
                        id: autopanRow
                        anchors.right: parent.right
                        spacing: 10

                        Text {
                            text: name
                            font.pixelSize: 16
                            color: "white"
                            MouseArea {
                                anchors.fill: parent
                                // When an item in the list view is clicked
                                onClicked: {
                                   autopanRow.updateAutoPanMode();
                                }
                            }
                        }

                        Image {
                            source: image
                            width: 25
                            height: width
                            MouseArea {
                                anchors.fill: parent
                                // When an item in the list view is clicked
                                onClicked: {
                                   autopanRow.updateAutoPanMode();
                                }
                            }
                        }

                        // set the appropriate auto pan mode
                        function updateAutoPanMode() {
                            switch (name) {
                            case compassMode:
                                mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeCompassNavigation;
                                mapView.locationDisplay.start();
                                break;
                            case onMode:
                                mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeOff;
                                mapView.locationDisplay.start();
                                break;
                            case stopMode:
                                mapView.locationDisplay.stop();
                                break;
                            }

                            if (name !== closeMode) {
                                currentModeText = name;
                                currentModeImage = image;
                            }

                            // hide the list view
                            currentAction.visible = true;
                            autoPanListView.visible = false;
                        }
                    }
                }

                Row {
                    id: currentAction
                    anchors {
                        right: parent.right
                        top: parent.top
                        margins: 25
                    }
                    spacing: 10

                    Text {
                        text: ""
                        font.pixelSize: 20
                        color: "white"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                currentAction.visible = false;
                                autoPanListView.visible = true;
                            }
                        }
                    }

                    Image {
                        source: currentModeImage
                        width: 25
                        height: width
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                currentAction.visible = false;
                                autoPanListView.visible = true;
                            }
                        }
                    }
                }
            }
        }
    }

// test adding create graphic point
    Point {
        x: 56.06127916736989
        y: -2.6395150461199726
        spatialReference: SpatialReference.createWgs84()

        onComponentCompleted: {
            tweetArray.push(this);
        }
    }

 // connect to twitter api
    function getData() {
        var hashtag = searchText.text
        tweetHashtag = hashtag
//        console.log(tweetHashtag)
        var req = new XMLHttpRequest;
            req.open("GET", 'https://api.twitter.com/1.1/search/tweets.json?q=%23'+ hashtag +'&count=100');
            req.setRequestHeader("Authorization", "Bearer " + bearerToken);
            req.onreadystatechange=function() {
                if (req.readyState == 4 && req.status == 200) {
                myData(req.responseText);
                } /*else {
                    console.log('error');
                  }*/
        }

        req.send();
    }

// append twitter data
    function myData(json) {
        var obj = JSON.parse(json);
            obj.statuses.forEach (function(data){
                if (data.coordinates){
                        console.log(data.coordinates.coordinates)

                    // append tweet text
                    var tweetText2 = data.text
                        tweetText.push(tweetText2)
                    tweetText.forEach(function(text){
                        listview.model.append({tweetText: text})
                    })

                    // append tweet image
                    var tweetImage2 = data.user.profile_image_url_https
                        tweetImage.push(tweetImage2)
                    tweetImage.forEach(function(image){
                        listview.model.append({tweetImage: image})
                    })

                    // append graphic for test point
                    tweetArray.forEach(function(buoyPoint) {
                        graphicsOverlay.graphics.append(createGraphic(buoyPoint, pointSymbol));
                        console.log(tweetArray)
                    });
                    }
            });
    }

    // create and return a graphic
    function createGraphic(geometry, symbol) {
        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic");
        graphic.geometry = geometry;
        graphic.symbol = symbol;
        return graphic;
    }

}

