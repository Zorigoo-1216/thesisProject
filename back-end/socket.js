const { Server } = require('socket.io');

let io;
const onlineUsers = new Map(); // userId -> socketId

function initSocket(server) {
  io = new Server(server, {
    cors: { origin: '*' },
  });

  io.on('connection', (socket) => {
    socket.on('register', (userId) => {
      onlineUsers.set(userId, socket.id);
    });

    socket.on('disconnect', () => {
      for (const [uid, sid] of onlineUsers.entries()) {
        if (sid === socket.id) onlineUsers.delete(uid);
      }
    });
  });
}

function sendSocketNotification(userId, notificationData) {
  const socketId = onlineUsers.get(userId);
  if (socketId && io) {
    io.to(socketId).emit('notification', notificationData);
  }
}

module.exports = { initSocket, sendSocketNotification };
