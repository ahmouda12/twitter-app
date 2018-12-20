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
import QtQuick.Layouts 1.3
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
           Image {
//               anchors.fill: parent
               anchors{
                   top: parent.top
                   left: parent.left
                   right: parent.right
                   bottom: searchBar.top
               }
               source: "images/bird-anim-sprites.png"
           }
                    ListView {
                        id: listview
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: searchBar.top
                            right: parent.right
                        }
                       clip:true
                       orientation:ListView.Vertical
                       flickableDirection: Flickable.VerticalFlick
                       boundsBehavior: Flickable.StopAtBounds
                       model: ListModel {id: listModel}
                       delegate: Rectangle {
                                   height: 70
                                   width: parent.width
                                   color: "#f5f8fa"
                                   border.width: 1
                                   border.color: "#e1e8ed"
                                   RowLayout {
                                     width: parent.width
                                     anchors.verticalCenter: parent.verticalCenter
                                     anchors {
                                         fill: parent
                                         leftMargin: 10
                                         rightMargin: 10
                                     }
                                        Image {
                                            source: tweetImage
                                        }
                                        ColumnLayout {
                                            Text {
                                                text: "<style>a:link { color: '#1da1f3'; }</style>" +
                                                      '<a href="https://twitter.com/' + tweetUser +'" >' + tweetUser +' </a>'
                                                Layout.fillWidth: true
                                                color: "black"
                                                font.pointSize: 12
                                                font.bold: true
                                                textFormat: Text.RichText
                                                onLinkActivated: Qt.openUrlExternally(link)
                                            }
                                            Text {
                                                font.pixelSize: 12
                                                text: tweetText
                                                wrapMode: Text.Wrap
                                                Layout.fillWidth: true
                                                color: "#14171a"
                                                textFormat: Text.RichText
                                                onLinkActivated: Qt.openUrlExternally(link)
                                            }
                                        }
                                    }
                                }
                            }

                   RowLayout {
                       id: searchBar
                       anchors.bottom: parent.bottom
                       width: parent.width
                       height: 70
                       Rectangle {
                               color: '#f5f8fa'
                               border.color: '#e1e8ed'
                               Layout.fillWidth: true
                               Layout.minimumWidth: parent.width
                               Layout.preferredWidth: parent.width
                               Layout.maximumWidth: parent.width
                               Layout.minimumHeight: parent.height
                       }
                       TextField {
                           id: searchText
                           font.pixelSize: 18
                           style: TextFieldStyle {
                                   textColor: "black"
                                   background: Rectangle {
                                               radius: 3
                                               color: "#f3f3f4"
                                               border.color: "steelBlue"
                                               border.width: 1
                                           }
                           }
                           placeholderText: qsTr("Search hashtag...")
                           anchors {
                               fill: parent
                               leftMargin: 10
                               rightMargin: 69
                               topMargin: 10
                               bottomMargin: 10
                           }
                           Image {
                               anchors { top: parent.top; right: parent.right; bottom: parent.bottom; margins: 10 }
                               id: clearText
                               fillMode: Image.PreserveAspectFit
                               smooth: true; visible: searchText.text
                               source: "images/baseline_clear_black_18dp.png"
                           MouseArea {
                               id: clear
//                               anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                               height: searchText.height; width: searchText.height
                               onClicked: {
                                   searchText.text = ""
                                   searchText.forceActiveFocus()
                                   clearModel()
                               }
                            }
                         }
                       }
                       Button {
                           id: searchButton
                           iconSource:  "images/baseline_search_black_18dp.png"
                           anchors { top: parent.top; right: parent.right; bottom: parent.bottom; margins: 10 }
                           onClicked:  getData()
                       }
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
                    PictureMarkerSymbol {
                        id: pictureMarkerSymbol
                        url: "images/RedStickpin.png"
                        width: 30
                        height: 30
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

 // connect to twitter api
    function getData() {
        var hashtag = searchText.text
        tweetHashtag = hashtag
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

                // tweets with no coordinates
                if (data.coordinates){
                    // create points in arcgis runtime enviroment
                    var coords = data.coordinates.coordinates
                    var geom;
                    var wkid = 4326;
                    var sr = ArcGISRuntimeEnvironment.createObject("SpatialReference", { wkid: wkid });
                    var pointBuilder = ArcGISRuntimeEnvironment.createObject("PointBuilder");
                    pointBuilder.spatialReference = sr;
                    pointBuilder.setXY(coords[0], coords[1]);
                    geom = pointBuilder.geometry;

                    // append graphic layers for pins
                        graphicsOverlay.graphics.append(createGraphic(geom, pictureMarkerSymbol));
                }

                // tweets with coordinates
                if (!data.coordinates) {
                    // append tweet user name, text, & image
                    var tweetId = data.id_str
                    var tweetUser = data.user.screen_name
                    var tweetText = data.text
                    tweetText = tweetText.replace(/#(\S+)/g,"<style>a:link { color: '#1da1f3'; }</style>" +
                                                  '<a href="http://twitter.com/hashtag/$1">#$1</a>');
                    var textLength = tweetText.split(/\r\n|\r|\n/)
                    var link = "http://google.com";
                    var tweetImage = data.user.profile_image_url_https
                    if (textLength.length > 1) {
                        listview.model.append({tweetImage: tweetImage, tweetUser: tweetUser, tweetText: textLength[0] + '<br>' +
                                                  "<style>a:link { color: '#1da1f3'; }</style>" +
                                                  '<a href="https://twitter.com/user_name/statuses/'+ tweetId +'" >' + "Read more..." +' </a>'})
                    } else {
                        listview.model.append({tweetImage: tweetImage, tweetUser: tweetUser, tweetText: textLength[0]})
                    }
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

    // clear the model
    function clearModel() {
        listModel.clear()
        graphicsOverlay.graphics.clear()
    }

}

