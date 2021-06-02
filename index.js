// Load the AWS SDK for Node.js
let https = require('https');

exports.handler = async (event, context, callback) => {
    console.log('Starting function...');
    const options = {
        host: 'na1.api.riotgames.com',
        path: '/lol/clash/v1/tournaments',
        method: 'GET',
        headers: {
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Charset': 'application/x-www-form-urlencoded; charset=UTF-8',
            'X-Riot-Token': 'RGAPI-615a9bbb-36c3-4526-8cc0-77dcf9baa6f1',
            'Origin': 'https://developer.riotgames.com',
        },
        timeout: 200
    };
    let response = await new Promise((resolve, reject) => {
        console.log('Making call...');
        https.request(options, function (response) {
            let str = '';
            response.on('data', function (chunk) {
                str += chunk;
            });

            response.on('end', function () {
                if (response.statusCode !== 200) {
                    reject(`Failed to retrieve league Clash API data due to => ${str}`);
                } else {
                    let parse = JSON.parse(str);
                    console.log('League Clash times loaded.');
                    resolve(parse);
                }
            });

            response.on('error', function (err) {
                console.error('Failed to make request', err);
                reject(err);
            });
        }).end();
    });
    console.log('Call finished.');
    return response;
};
