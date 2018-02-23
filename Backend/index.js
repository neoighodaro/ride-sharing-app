// --------------------------------------------------------
// Pull in the libraries
// --------------------------------------------------------

const app = require('express')()
const bodyParser = require('body-parser')
const config = require('./config.js')
const Pusher = require('pusher')
const pusher = new Pusher(config["pusher"])
const PushNotifications = require('pusher-push-notifications-node')
const pushNotifications = new PushNotifications(config['pusher-notifications'])

// --------------------------------------------------------
// In-memory database
// --------------------------------------------------------

let rider = null
let driver = null
let user_id = null
let status = "Neutral"

// --------------------------------------------------------
// Express Middlewares
// --------------------------------------------------------

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended: false}))


// --------------------------------------------------------
// Helpers
// --------------------------------------------------------

function uuidv4() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

function sendRiderPushNotificationFor(status) {
    switch (status) {
        case "Neutral":
            var alert = {
                "title": "Driver Cancelled :(",
                "body": "Sorry your driver had to cancel. Open app to request again.",
            }
            break;
        case "FoundRide":
            var alert = {
                "title": "🚕 Found a ride",
                "body": "The driver is a few minutes away."
            }
            break;
        case "OnTrip":
            var alert = {
                "title": "🚕 You are on your way",
                "body": "The driver has started the trip. Enjoy your ride."
            }
            break;
        case "EndedTrip":
            var alert = {
                "title": "🌟 Ride complete",
                "body": "Your ride cost $15. Open app to rate the driver."
            }
            break;
    }

    if (alert != undefined) {
        pushNotifications.publish(['rider'], {apns: {aps: {alert, sound: "default"}}})
            .then(resp => console.log('Just published:', resp.publishId))
            .catch(err => console.log('Error:', err))
    }
}

function sendDriverPushNotification() {
    pushNotifications.publish(['ride_requests'], {
        "apns": {
            "aps": {
                "alert": {
                    "title": "🚗 New Ride Request",
                    "body": `New pick up request from ${rider.name}.`,
                },
                "category": "DriverActions",
                "mutable-content": 1,
                "sound": 'default'
            },
            "data": {
                "attachment-url": "https://maps.google.com/maps/api/staticmap?markers=color:red|37.388064,-122.088426&zoom=13&size=500x300&sensor=true"
            }
        }
    })
    .then(response => console.log('Just published:', response.publishId))
    .catch(error => console.log('Error:', error));
}


// --------------------------------------------------------
// Routes
// --------------------------------------------------------

// ----- Rider --------------------------------------------

app.get('/status', (req, res) => res.json({ status }))

app.get('/request', (req, res) => res.json(driver))

app.post('/request', (req, res) => {
    user_id = req.body.user_id
    status = "Searching"
    rider = { name: "Jane Doe", number: "+18001234567", longitude: -122.088426, latitude: 37.388064 }

    sendDriverPushNotification()

    pusher.trigger('cabs', 'status-update', { status, rider })
    res.json({ status: true })
})

app.delete('/request', (req, res) => {
    driver = null
    status = "Neutral"
    pusher.trigger('cabs', 'status-update', { status })
    res.json({ status: true })
})

// ----- Driver ------------------------------------------

app.get('/pending-rider', (req, res) => res.json(rider))

app.post('/status', (req, res) => {
    status = req.body.status

    if (status == "EndedTrip" || status == "Neutral") {
        rider = driver = null
    } else {
        driver = { name: "John Doe" }
    }

    sendRiderPushNotificationFor(status)

    pusher.trigger('cabs', 'status-update', { status, driver })
    res.json({ status: true })
})

// ----- Misc ---------------------------------------------

app.get('/', (req, res) => res.json({ status: "success" }))


// --------------------------------------------------------s
// Serve application
// --------------------------------------------------------

app.listen(4000, _ => console.log('App listening on port 4000!'))
