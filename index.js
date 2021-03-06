// Load the AWS SDK for Node.js
const moment = require('moment-timezone');
const https = require('https');
const AWS = require('aws-sdk');

exports.handler = async () => {
    console.log('Starting function...');
    const sns = new AWS.SNS();
    let snsParams = {
        Message: 'Testing from lambda.',
        TopicArn: process.env.snsTopicArn
    };
    let response = await new Promise((resolve, reject) => {
        console.log('Retrieving secret...');
        const secretsManager = new AWS.SecretsManager({apiVersion: '2017-10-17'});
        const dynamo = new AWS.DynamoDB();
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
                                    let data = [];
                                    const dateFormat = 'MMMM DD yyyy hh:mm a z';
                                    const timeZone = 'America/Los_Angeles';
                                    moment.tz.setDefault(timeZone);
                                    if (Array.isArray(parse) && parse.length > 0) {
                                        parse.forEach((tourney) => {
                                            data.push({
                                                tournamentName: tourney.nameKey,
                                                tournamentDay: tourney.nameKeySecondary,
                                                startTime: new moment(tourney.schedule[0].startTime),
                                                registrationTime: new moment(tourney.schedule[0].registrationTime)
                                            });
                                        });
                                        data.sort((dateOne, dateTwo) => dateOne.startTime.diff(dateTwo.startTime));
                                        data.forEach((data) => {
                                            data.startTime = data.startTime.format(dateFormat);
                                            data.registrationTime = data.registrationTime.format(dateFormat);
                                            data.tournamentDay = data.tournamentDay.split('day_')[1];
                                            let params = {
                                                Item: {
                                                    'key': {
                                                        S: `${data.tournamentName}#${data.tournamentDay}`
                                                    },
                                                    'tournamentName': {
                                                        S: data.tournamentName
                                                    },
                                                    'tournamentDay': {
                                                        S: data.tournamentDay
                                                    },
                                                    'startTime': {
                                                        S: data.startTime
                                                    },
                                                    'registrationTime': {
                                                        S: data.registrationTime
                                                    }
                                                },
                                                TableName: 'clashtimes'
                                            }
                                            dynamo.putItem(params, function (err) {
                                                if (err) reject(err);
                                            })
                                        });
                                        console.log('League Clash times loaded.');
                                        resolve(data);
                                    } else {
                                        resolve('No upcoming Clash Tournaments.')
                                    }
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
    let snsMessage = 'Here are your Tournament Details\n-------------------------\n';
    if (Array.isArray(response) && response.length) {
        response.forEach(data => {
            snsMessage += `Tournament Details ${data.tournamentName} Day ${data.tournamentDay} @ ${data.startTime}\n`
        });
    } else {
        snsMessage = `Data failed to be retrieved due to > ${response}`;
    }
    snsParams.Message = snsMessage;
    await new Promise((resolve, reject) => {
        console.log('Sending email...')
        sns.publish(snsParams, function (err, data) {
            if (err) reject(err);
            else {
                console.log('Email successfully sent.');
                resolve(data);
            }
        });
    });
    console.log('Lambda finished.');
    return response;
};
