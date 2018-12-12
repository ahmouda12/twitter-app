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
   property var buoyLocArray: []
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
//                           text: tweetText
//                           text: "<a href="+ jsondata +"</a>"
//                           onLinkActivated: Qt.openUrlExternally(jsondata)
//                           Column{
//                               spacing: 2
                           Image {
                               source: tweetImage
                                }
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
//                       ViewpointCenter {
//                                       targetScale: 7500

//                                       Point {
//                                           x: -226773
//                                           y: 6550477
//                                           spatialReference: SpatialReference { wkid: 3857 }
//                                       }
//                                   }
                   }

//                    GraphicsOverlay {

//                               // add graphic to overlay
//                               Graphic {
//                                   // define position of graphic
//                                   Point {
//                                       x: tweet[0]
//                                       y: tweet[1]
//                                       spatialReference: SpatialReference { wkid: 4326 }
//                                   }

//                                   // set graphic to be rendered as a red circle symbol
//                                   SimpleMarkerSymbol {
//                                       style: Enums.SimpleMarkerSymbolStyleCircle
//                                       color: "red"
//                                       size: 12
//                                   }
//                               }

//                    }

                    GraphicsOverlay {
                            id: graphicsOverlay

                    }

                    SimpleMarkerSymbol {
                        id: pointSymbol
                        style: Enums.SimpleMarkerSymbolStyleCircle
                        color: "red"
                        size: 12
                    }

                }
            }
        }
    }

// test adding create a graphic point
property var tweetArray: []

    Point {
        x: 56.06127916736989
        y: -2.6395150461199726
        spatialReference: SpatialReference.createWgs84()

        onComponentCompleted: {
            tweetArray.push(this);
        }
    }

//    GraphicsLayer {
//        id: myGraphicsLayer

//        Graphic {
//            id: redCircle
//            geometry: Point {
//                json: {"spatialReference":{"latestWkid":3857,"wkid":102100}, "x": 9000000, "y": 6000000 }
//            }
//            symbol: SimpleMarkerSymbol {
//                style: Enums.SimpleMarkerSymbolStyleCircle
//                color: "red"
//                size: 24
//            }
//        }


// request test data endpoint
    property string bearerToken : "AAAAAAAAAAAAAAAAAAAAAI%2FBuAAAAAAAqbFCZnDgSTyebXFhM1d%2Brw7K8Hs%3DrhdQWj6iQ0LSmC8H4Nd950dpTEC97vJw8kuUQqppLP1wYZG8vp"
    property string hashtag: "love"
    property variant tweet2: []

    function getData() {
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

    function myData(json) {
        var obj = JSON.parse(json);
            obj.statuses.forEach (function(data){
                if (data.coordinates){
//                  if (data.place.bounding_box !== null){
                        console.log(data.coordinates.coordinates)
//                        tweet = data.coordinates.coordinates
//                        console.log(tweet)
                    tweet2 = [56.06127916736989,-2.6395150461199726]
                        listview.model.append({tweetImage: data.user.profile_image_url_https})
//                        listview.model.append({tweetText: data.text})
//                        graphicsOverlay.graphics.append(tweet2, pointSymbol)
//                    console.log(data.text)

                    // append a graphic for test point
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

