// Load the AWS SDK for Node.js
let https = require('https');
let AWS = require('aws-sdk');

exports.handler = async (event, context, callback) => {
    console.log('Starting function...');
    let response = await new Promise((resolve, reject) => {
        console.log('Retrieving secret...');
        const secretsManager = new AWS.SecretsManager({apiVersion: '2017-10-17'});
        secretsManager.getSecretValue({SecretId: 'RIOT_TOKEN'}, (err, data) => {
                if (err) {
                    reject(err);
                } else {
                    console.log('Secret retrieved.');
                    let secret = '';
                    try {
                        if ('SecretString' in data) {
                            secret = JSON.parse(data.SecretString).RIOT_TOKEN;
                        } else {
                            reject('RIOT_TOKEN not found in secrets manager.');
                        }

                        const options = {
                            host: 'na1.api.riotgames.com',
                            path: '/lol/clash/v1/tournaments',
                            method: 'GET',
                            headers: {
                                'Accept-Language': 'en-US,en;q=0.9',
                                'Accept-Charset': 'application/x-www-form-urlencoded; charset=UTF-8',
                                'X-Riot-Token': secret,
                                'Origin': 'https://developer.riotgames.com',
                            },
                            timeout: 200
                        };
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
                    } catch (err) {
                        reject(err);
                    }
                }
            }
        )
    });
    console.log('Call finished.');
    return response;
};
