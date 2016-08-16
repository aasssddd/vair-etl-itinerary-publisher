# config.coffee
module.exports = 
	ftp:
		host: "data.host"
		user: "ftp user"
		password: "ftp password"
		protocol: "ftps"
		port: 21
		targetFilePath: "/Prod"
		pnrSource:
			"PAYMENTS.CSV": 5
			"MAP.CSV": 1
			"FEE.CSV": 1
	aws:
		queueUrl: "https://sqs.url"
		accessKeyId: "aws access key id",
		secretAccessKey: "aws secret access key"
		region: "region"
		API_VERSION: "2012-11-05"

	message_size: 50