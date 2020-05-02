# TRAVEL BUDDY

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
An App for users to interact with people who live in the place they plan on visiting.

### Current Progress
<img src="http://g.recordit.co/zY2ZK9GbhI.gif" width=250><br>
<img src="http://g.recordit.co/KsphHBwpHk.gif" width=250><br>
<img src="http://g.recordit.co/CfEQjcatdu.gif" width=250>. <img src="http://g.recordit.co/chZrc8474O.gif" width=250>  <img src="http://g.recordit.co/goaClW4nI6.gif" width=250>

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Social
- **Mobile:** Chat applications are much convenient on a mobile platform. 
- **Story:** After planning on a visit/journey, hop in to interact with people at your destination, make friends and have an awesome visit.
- **Market:** Anyone interested in having a wonderful travel experience could use this app. People who want to meet visitors to their area, show them around, and make their visit an interesting one, will need this app. Evidently, this app is appropriate for everyone.
- **Habit:** This app could be used by people on a regular basis depending upon how much they travel and how much time they are willing to put into helping those traveling to their area.
- **Scope:** The fundamentals behind this app are not too technically challenging and should be able to be completed within the time constraints for this course.  However, in order for this app to reach its full potential additional features would most likely need to be added beyond the time alloted in this course.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User must be able to select / search for a particular location and find a list of other users who live in that location
- [ ] User must be able to message people in the location that they are interested in visiting
- [X] User must be able to login in and sign up
- [x] App provides travel information for each location
- [x] User can rate the person they messaged based on how helpful they were - higher rating for a user allows them access to perks and rewards

**Optional Nice-to-have Stories**
- [ ] User must be able to register as an inhibant of the location in which they live
- [ ] User must be able to view and edit profile by clicking image of themselves in the top right hand corner of the screen
- [ ] Allow users to add their location if it is not available on the app

### 2. Screen Archetypes

* Login Screen
   * User must be able to sign up if this is their first time using the application
   * User must be able to log in if they have used the application before
* Home Screen
   * User can find location on map
   * Search bar at top that allows user to search for particular locations
* Details
    * User can select a location and get a general descripion of the location / image
    * List of inhabitants of the location listed in order of rating
* Messaging
    * User can message inhabitants of the location they are interested in and rate them
* Profile
    * User can click on image of themselves in the top right corner of their screen and see stats

### 3. Navigation

**Flow Navigation** (Screen to Screen)

* Login Screen
   * Home Screen
* Home Screen
   * Places 
   * Friends 
   * Profile 

### [BONUS] Digital Wireframes & Mockups
Digital Wire Frame is complete on figma and available at the following link: https://www.figma.com/file/B0x0iS6YtMyaYWWvQDvHgI/TravelBuddyWireFrame?node-id=0%3A1.

### [BONUS] Interactive Prototype
<img src='http://g.recordit.co/LoQXK5SbBA.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

## Schema 
## Schema 
### Models

#### User

| Property | Type | Description |
| -------- | -------- | -------- |
| username     | string     | unique identifier for user     |
| password     | string     | password for user     |
| profileImage    | Image     | profile image for user to display to other users    |
| defaultLocation | string | default location of user |
| statusMessage | string | Public status message |

#### Location

| Property | Type | Description |
| -------- | -------- | ------- |
| id | Number | Unique id of the location |
| locationImage     | file     | picture of location    |
| userImages | Array | Images the user has taken at the location |
| description     | string     | brief description of location     |
| visited     | bool     | true if user has visited location     |
| user    | Pointer to User     | points to the user that visited / plan to visit this location    |
| address    | String     | address of location    |
| createdOn | DateTime | Date and time on which the user added this location |
| visitedOn | DateTime | Date and time on which the user visited the loation |

#### FriendRequest

| Property | Type | Description |
| ------- | ------ | ------- |
| fromUser | Pointer to User | User that initiated the request |
| toUser | Pointer to User | User to whom the request was sent |
| status | Number | Status (accepted, pending, rejected) |
| createdOn | DateTime | Date and time on which the request was sent |
| updatedOn | DateTime | Date and time on which status changed |

#### Message

| Property | Type | Description |
| --- | --- | --- |
| id | Number | unique id of this message |
| fromUser | Pointer to User | User who sent the message |
| toUser | Pointer to User | User who received the message |
| text | String | Message content |
| createdOn | DateTime | Date and time the message was sent |
| status | int | 0 - not seen, 1 - seen |

#### Reaction

| Property | Type | Description |
| --- | --- | --- |
| messageId | Pointer to a message | The message with this reaction |
| User | Pointer to User | User who reacted to the message |
| Reaction | Number | 1 - like, 2 - love, 3 - ... etc.|


#### Rating
| Property | Type | Description |
| --- | --- | --- |
| user | Pointer to user | The user to whom the rating belongs |
| rating | Number | Rating of the user |
| numUsers | Number | The number of users that rated this user |

### Networking

**List of Network requests by screen**


#### SignUp Screen

- (POST) Create a new User with the provided credentials
    ```swift
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        user.defaultLocation = //some location - yet to figure out how to get it
        
        user.signUpInBackground { (success, error) in
            if success {
                // Transition to home screen
            } else {
                // print error
            }
        }
        
    ```

#### Login Screen

- (GET) Verify if a user with the provided credentials exit

    ```swift
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                // Transition to home screen
            } else {
                // print error
            }
        }
        
    ```

#### Home Screen

- (GET) Get users whose locations are within some miles of the current user's location to display on map
    ```swift
        // Will figure this out
    ```
    
- (GET) Get public details of the user which the current user selects on the map
    ```swift
        let selectedUsername = "some username" // username attributed to the mark on the map
        let query = PFQuery(className:"User")
         query.whereKey("username", equalTo: selectedUsername)
         query.findObjectsInBackground { (selectedUser: PFObject?, error: Error?) in
            if let error = error { 
               // print error
            } else if let selectedUser = selectedUser {
               // User retrieved
            }
         }
    ```
    
- (POST) Add a location
    ```swift
        let location = PFObject(className: "Location")
        
        location["address"] = "some address"// pull from map
        location["user"] = PFUser.current()
        
        let imageData = // an image, if any, that the map has associated with that location
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        post["locationImage"] = file
        
        post.saveInBackground { (success, error) in
            if success {
                // alert - location added
            } else {
                // print error
            }
        }
    ```

#### Locations Screen

- (GET) Get all locations associated with this user
    ```swift
        let query = PFQuery(className:"Location")
         query.whereKey("user", equalTo: currentUser)
         query.order(byDescending: "createdOn")
         query.limit = 20
         query.findObjectsInBackground { (locations: [PFObject]?, error: Error?) in
            if let error = error { 
               // print error
            } else if let locations = locations {
               // locations retrieved
            }
         }
    ```

#### Location Screen

- (GET) Get location details added by the current user and other users
    ```swift
        let query = PFQuery(className:"Location")
         query.whereKey("id", equalTo: locationId)
         query.findObjectsInBackground { (location: PFObject?, error: Error?) in
            if let error = error { 
               // print error
            } else if let location = location {
               // location retrieved
            }
         }
    ```


#### List of Friends Screen

- (GET) Get Friends of the current user
    ```swift
        let query1 = PFQuery(className:"FriendRequest")
         query.whereKey("fromUser", equalTo: currentUser)
         
         let query2 = PFQuery(className:"FriendRequest")
         query.whereKey("toUser", equalTo: currentUser)

         let query = PFQuery.orQuery(withSubqueries: [query1, query2])
         query.limit = 20
         query1.order(byAscending: "username")
        
         query.findObjectsInBackground { (results: [PFObject]?, error: Error?) in
             if let error = error {
                // The request failed
                print(error.localizedDescription)
             } else {
                // In ascending order of username, first 20 friends returned.
             }
         }
         
    ```
- (GET) Get Friends of friends of current user (when searching for friends)
    ```swift
        // Will be needed when searching for friends
    ```
- (GET) Get user that matches the provided username (for specific user search)
    ```swift
        let usernameSearched = usernameTextView.text
        let query = PFQuery(className:"User")
         query.whereKey("username", equalTo: usernameSearched)
         query.findObjectsInBackground { (foundUser: PFObject?, error: Error?) in
            if let error = error { 
               // print error
            } else if let foundUser = foundUser {
               // User retrieved
            }
         }
    ```


#### Chat Screen

- (GET) Get last 10 chat messages.
    ```swift
        let query1 = PFQuery(className:"Message")
         query.whereKey("fromUser", equalTo: currentUser)
         
         let query2 = PFQuery(className:"Message")
         query.whereKey("toUser", equalTo: currentUser)
         
         let query = PFQuery.orQuery(withSubqueries: [query1, query2])
         query.limit = 10
         query1.order(byDescending: "createdOn")
        
         query.findObjectsInBackground { (results: [PFObject]?, error: Error?) in
            if let error = error {
                // The request failed
                print(error.localizedDescription)
            } else {
                // last 10 chat messages in order returned
            }
         }
    ```
    
- (POST) Create a message in chat table.
    ```swift
        let messageObj = PFObject(className: "Message")
        
        message["fromUser"] = PFUser.current()
        message["toUser"] = selectedUser
        message["text"] = text
        message["status"] = 0
        
        post.saveInBackground { (success, error) in
            if success {
                // alert - message sent
            } else {
                // print error
            }
        }
    ```
