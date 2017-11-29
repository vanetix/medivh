'use strict';

import './styles/application.scss';
import { Socket } from '../deps/phoenix';

const Elm = require('./Main');
const app = Elm.Main.fullscreen({ users: window.boot });
const socket = new Socket("/socket");
const channel = socket.channel("users:lobby");
const {
  updateUser,
  windowKeyPress,
  saveToLocal,
  loadFromLocal,
  loadedUsers
} = app.ports;

delete window.boot;

socket.connect();
channel.join();

channel.on("user:update", user => updateUser.send(user));

saveToLocal.subscribe((tuple) => {
  let [key, value] = tuple;

  localStorage.setItem(key, value);
});


loadFromLocal.subscribe((key) => {
  let data = localStorage.getItem(key);

  loadedUsers.send(data || "");
});
