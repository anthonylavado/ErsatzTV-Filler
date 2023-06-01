const winston = require('winston');
const { format } = winston;
const DailyRotateFile = require('winston-daily-rotate-file');
const moment = require('moment-timezone');

// Define your custom log levels
const customLevels = {
  success: 0,
  info: 1,
  warn: 2,
  error: 3,
  debug: 4,
  ffmpeg: 5
};

// Define colors for the custom log levels
const customLevelColors = {
  success: 'green',
  debug: 'blue',
  info: 'cyan',
  warn: 'yellow',
  error: 'red',
  ffmpeg: 'orange'
};

// Apply colors to the custom log levels
winston.addColors(customLevelColors);

// Define the log format
const logFormat = winston.format.printf(({ level, message, timestamp }) => {
  return `${timestamp} ${level}: ${message}`;
});

// Create the logger
const logger = winston.createLogger({
  levels: customLevels,
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    logFormat
  ),
  transports: [
    new winston.transports.Console(),
    new DailyRotateFile({
     filename: 'ersatztv-filler-%DATE%.log',
     datePattern: 'YYYY-MM-DD',
     maxFiles: '7d', // Keep logs for 7 days
     maxSize: '900m', // Rotate logs if the file size exceeds 20MB
     level: 'info'
   }),
   new DailyRotateFile({
    filename: 'ersatztv-filler-ffmpeg-%DATE%.log',
    datePattern: 'YYYY-MM-DD',
    maxFiles: '7d', // Keep logs for 7 days
    maxSize: '900m', // Rotate logs if the file size exceeds 20MB
    level: 'ffmpeg'
  })
  ]
});



module.exports = logger;
