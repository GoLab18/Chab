# Chab
#### Video Demo:  https://youtu.be/er3zj5aO-rY
#### Description:

---

Chab is a simple chat app.
It allows users to chat with friends, whether through private chats or group chats.

### Frontend
The frontend is built with dart and flutter and BloC library. App is specifically made to be as real-time 
as possible (that of course was my idea behind it) so basically everything is fully real-time besides searching.

### Backend
Chab is powered by Firebase and Elasticsearch, former being a cloud-based NoSQL database for storing the actual data and latter being a search engine that holds denormalized data for full-text search, full-text querying, highlight queries etc. Photos and videos are stored with Firebase Storage and the rest with Firebase Firestore. API calls to elasticsearch are handled with Dio package for network requests through HTTPS.

---

## Features

### Messaging
Obviously it has messaging, that is the whole point. Messages can be also full-text searched within each room. Full-text search is backed by highlighting and allows slight fuzziness for queries thus the matching values won't always be 100% matching.

### Managing friend relations
Friends can be added in a page entered through a tile in a side drawer "Find Friends". Current user can search up other users and check received and issued invites, add them, delete them etc. On invite accepted, there is a room creation event invoked.

### Chat rooms
There are two different room versions - private for 1v1 chatting and group for 2+ members chatting. Rooms can be searched for from the home page's search bar. Room creation is enabled through "New Group" page opened via a tile with that name placed inside a side drawer. Rooms can be managed on creation and after it inside the page opened with info icon inside the chat room page.

### Login and Sign Up
Authorization is handled on app being opened. User can either sign up or sign in with an email.

### Profile info page
Accessed with "Profile" tile placed in the side drawer. User can change their info there like name or bio.

### Themes
There are two themes available - dark and light. There is a button in the top right corner of the side drawer with which they can be toggled.

---

## Setup information
1. Elasticsearch instance with Kibana is needed. Should be setup with HTTPS and public adress is needed. For local instances to be able to get external requests, API port has to be non-blocked by a firewall. .env.example file holds all the info that has to be included for API requests. NOTE .env file is there for development only, shouldn't be included in the actual build and the client setup with .env params should be decoupled in production.

2. Firebase has to be setup, mainly three things - Firebase Firestore, Firebase Storage and Firebase Authentication. Everything can be done from the    firebase CLI in the cloud. Firebase also requries CLI setup for Flutter (for generating firebase.json etc).

3. No document structure has to be setup for Firebase, it will get built up dynamically. For Elasticsearch there is an automatic indices mapping setup that also is better to be excluded in production but is very useful for development.

---

## Much needed Enhancements

Potential changes and enhancements include:
- **Group chat roles**: Needs proper implementation, for now everyone can do anything (i like that nontheless).
- **Room functionality**: More options should be included for the utility tiles. Audio and video calls, files look up, pinned messages look up etc.
- **Forgot password?**: Password changing with an email message - easy to setup with firebase, can be left for last.
- **Messages edits**: A way to edit messages (although i like immutable messages - full transparency).
- **Push notifications**: Not needed but every chat app has them so.
- **Better online status**: "5 mins ago" prompts etc.

---
