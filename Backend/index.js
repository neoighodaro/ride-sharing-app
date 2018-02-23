// --------------------------------------------------------
// Pull in the libraries
// --------------------------------------------------------

const app = require('express')()
const bodyParser = require('body-parser')
const Pusher = require('pusher')
const pusher = new Pusher(require('./config.js')["pusher"])

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

    pusher.trigger('cabs', 'status-update', { status, driver })
    res.json({ status: true })
})

// ----- Misc ---------------------------------------------

app.get('/', (req, res) => res.json({ status: "success" }))


// --------------------------------------------------------s
// Serve application
// --------------------------------------------------------

app.listen(4000, _ => console.log('App listening on port 4000!'))
