const request = require('request');

module.exports = function (context, myQueueItem) {
  context.log('JavaScript queue trigger function processed work item', myQueueItem);

  const url = myQueueItem;

  request(url, (err, res, body) => {
    if (err) {
      context.log(`An error occurred during download of \n URL: ${url} \n ERROR: ${err}`);
    } else if (res.statusCode === 200) {
      context.bindings.rawOrg = JSON.parse(body);
    } else {
      context.log(`Non 200 response encountered during download of \n URL: ${URL}`);
    }
  });

  context.done();
};
