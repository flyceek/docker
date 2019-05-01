/* eslint-disable max-len */

export const port = process.env.PORT || 3001;
export const host = process.env.WEBSITE_HOSTNAME || `localhost:${port}`;

export const analytics = {

  // https://analytics.google.com/
  google: {
    trackingId: process.env.GOOGLE_TRACKING_ID, // UA-XXXXX-X
  },

};

export const common = {
  api: {
    URL: process.env.CODE_PUSH_SERVER_URL ||'http://10.4.99.4:3000', // production code-push-server address
    devURL: process.env.CODE_PUSH_SERVER_URL_DEV ||'http://10.4.99.4:3000', // development code-push-server address
  },
};
