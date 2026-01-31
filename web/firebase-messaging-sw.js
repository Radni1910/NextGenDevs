importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAOslFc9fMds4Ou4gGq1WwZ8GyFN5XWc5s",
  authDomain: "dormtrack-3fbd6.firebaseapp.com",
  databaseURL: "https://dormtrack-3fbd6-default-rtdb.firebaseio.com",
  projectId: "dormtrack-3fbd6",
  storageBucket: "dormtrack-3fbd6.firebasestorage.app",
  messagingSenderId: "590200128665",
  appId: "1:590200128665:web:e18b4ba4abd40be3ef6408",
  measurementId: "G-8T49NJX8BH"
})
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log("Received background message ", payload);
});