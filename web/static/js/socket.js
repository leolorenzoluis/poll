// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "deps/phoenix/web/static/js/phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()


var features = [];

/*$.ajax({
    url: '/register',
    dataType: 'json',
    async: false,
    success: function(json1) {
        $.each(json1, function (key, data) {
            if (key == 'data') {
                $.each(data, function (k, v) {
                    if (v.type=='Point') {
                        //console.log(v.geometry.coordinates);
                        if (v.coordinates.length>1) {
                            features[k] = new ol.Feature(new ol.geom.Point(ol.proj.transform(v.coordinates, 'EPSG:4326', 'EPSG:3857')));
                        }
                    }
                });
                console.log(features.length);
            }
        });
    }
});*/
var source = new ol.source.Vector({
  features: features
});

var clusterSource = new ol.source.Cluster({
  distance: 40,
  source: source
});

var styleCache = {};
var clusters = new ol.layer.Vector({
  source: clusterSource,
  style: function(feature, resolution) {
    var size = feature.get('features').length;
    var style = styleCache[size];
    if (!style) {
      style = [new ol.style.Style({
        image: new ol.style.Circle({
          radius: 50,
          stroke: new ol.style.Stroke({
            color: '#fff'
          }),
          fill: new ol.style.Fill({
            color: '#3399CC'
          })
        }),
        text: new ol.style.Text({
          text: size.toString(),
          fill: new ol.style.Fill({
            color: '#fff'
          })
        })
      })];
      styleCache[size] = style;
    }
    return style;
  }
});

var raster = new ol.layer.Tile({
  source: new ol.source.MapQuest({layer: 'sat'})
});

var raw = new ol.layer.Vector({
  source: source
});


    var map = new ol.Map({
        layers: [
            new ol.layer.Tile({
                source: new ol.source.Stamen({
                    layer: 'watercolor'
                })
            }),
             /* Cluster heat map new ol.layer.Tile({
                source: new ol.source.TileJSON({
                    url: 'http://api.tiles.mapbox.com/v3/' +
                        'mapbox.20110804-hoa-foodinsecurity-3month.jsonp',
                    crossOrigin: 'anonymous'
                })
            }),*/
            new ol.layer.Tile({
                source: new ol.source.TileJSON({
                    url: 'http://api.tiles.mapbox.com/v3/' +
                        'mapbox.world-borders-light.jsonp',
                    crossOrigin: 'anonymous'
                })
            }),
            new ol.layer.Tile({
                source: new ol.source.Stamen({
                    layer: 'terrain-labels'
                })
            }),
     clusters
        ],
        target: 'map',
        view: new ol.View({
            center: ol.proj.transform(
            [123.995087, 10.405683], 'EPSG:4326', 'EPSG:3857'),
            zoom: 7
        })
    });







/*var source = new ol.source.Vector({
  wrapX: false
});
var vector = new ol.layer.Vector({
  source: source,
  style: function(feature, resolution) {
    var size = 5;
    var style = styleCache[size];
    if (!style) {
      style = [new ol.style.Style({
        image: new ol.style.Circle({
          radius: 10,
          stroke: new ol.style.Stroke({
            color: '#fff'
          }),
          fill: new ol.style.Fill({
            color: '#3399CC'
          })
        }),
        text: new ol.style.Text({
          text: size.toString(),
          fill: new ol.style.Fill({
            color: '#fff'
          })
        })
      })];
      styleCache[size] = style;
    }
    return style;
  }

});
map.addLayer(vector);

function addRandomFeature() {
  

  var coordinates = ol.proj.transform(
            [123.9000, 10.2800], 'EPSG:4326', 'EPSG:3857');
  var feature = new ol.Feature(new ol.geom.Point(coordinates));
  source.addFeature(feature);

}

var duration = 3000;
function flash(feature) {
  var start = new Date().getTime();
  var listenerKey;

  function animate(event) {
    var vectorContext = event.vectorContext;
    var frameState = event.frameState;
    var flashGeom = feature.getGeometry().clone();
    var elapsed = frameState.time - start;
    var elapsedRatio = elapsed / duration;
    // radius will be 5 at start and 30 at end.
    var radius = ol.easing.easeOut(elapsedRatio) * 25 + 5;
    var opacity = ol.easing.easeOut(1 - elapsedRatio);

    var flashStyle = new ol.style.Circle({
      radius: radius,
      snapToPixel: false,
      stroke: new ol.style.Stroke({
        color: 'rgba(255, 0, 0, ' + opacity + ')',
        width: 1,
        opacity: opacity
      })
    });

    vectorContext.setImageStyle(flashStyle);
    vectorContext.drawPointGeometry(flashGeom, null);
    if (elapsed > duration) {
      ol.Observable.unByKey(listenerKey);
      return;
    }
    // tell OL3 to continue postcompose animation
    frameState.animate = true;
  }
  listenerKey = map.on('postcompose', animate);
}

source.on('addfeature', function(e) {
  flash(e.feature);
});

window.setInterval(addRandomFeature, 1000)*/


var $messages  = $("#messages")
// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("eleksyon:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("new:msg", msg => {

          source.addFeature(new ol.Feature(new ol.geom.Point(ol.proj.transform(msg.coordinates, 'EPSG:4326', 'EPSG:3857'))));
          $messages.append(JSON.stringify(msg.coordinates)) 
          scrollTo(0, document.body.scrollHeight)
        })

export default socket
