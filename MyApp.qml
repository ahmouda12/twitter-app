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
import QtQuick.Layouts 1.11

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.3

Rectangle {
    id: app
    width: 400
    height: 640

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
            onClicked: {map_slide.open()}
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

               Item {
                   anchors.fill: parent

                   ListModel {
                       id: model
                   }

                   ListView {
                       id: listview
                       anchors.fill: parent
                       model: model
                       delegate: Text {
                           text: jsondata; font.capitalization: Font.AllLowercase
                       }
                   }

                   Button {
                       anchors.bottom: parent.bottom
                       width: parent.width
                       text: "GET Data"
                       onClicked: getData()
                   }
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
//                     initialViewpoint: viewpoint
                   }
                }
            }
        }
    }

// request test data endpoint
    property string bearerToken : "AAAAAAAAAAAAAAAAAAAAAI%2FBuAAAAAAAqbFCZnDgSTyebXFhM1d%2Brw7K8Hs%3DrhdQWj6iQ0LSmC8H4Nd950dpTEC97vJw8kuUQqppLP1wYZG8vp"
    property string hashtag: "love"

    function getData() {
        var req = new XMLHttpRequest;
            req.open("GET", 'https://api.twitter.com/1.1/search/tweets.json?q=%23'+ hashtag +'&count=100');
            req.setRequestHeader("Authorization", "Bearer " + bearerToken);
            req.onreadystatechange=function() {
                if (req.readyState == 4 && req.status == 200) {
                myData(req.responseText);
            }
        }
        req.send();
    }

    function myData(json) {
        var obj = JSON.parse(json);
            obj.statuses.forEach (function(data){
                if (data.coordinates){
//                  if (data.place.bounding_box !== null){
                        console.log(data.coordinates.coordinates)
                        listview.model.append({jsondata: data.text })
                    }
//              }
            });
    }

//    Component.onCompleted: {
//        getData()
//    }

//    // Create the intial Viewpoint
//    ViewpointCenter {
//            id: viewpoint
//            // Specify the center Point
//            center: Point {
//                x: 0
//                y: 0
//                spatialReference: SpatialReference { wkid: 102100 }
//            }
//            // Specify the scale
//            targetScale: 10000000
//        }


}

