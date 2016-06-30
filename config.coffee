# config.coffee
module.exports = 
	ftp:
		host: "ftp.avantik.io"
		user: "VAI_Export"
		password: "m!R4ja!X"
		protocol: "ftps"
		port: 21
		targetFilePath: "/Prod"
		pnrSource:
			"PAYMENTS.CSV": 5
			"MAP.CSV": 1
			"FEE.CSV": 1
	aws:
		queueUrl: "https://sqs.us-east-1.amazonaws.com/662107851369/ItineraryJob"
		accessKeyId: "AKIAIQM4MWTKCNE3ALYQ",
		secretAccessKey: "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"
		region: "us-east-1"
		API_VERSION: "2012-11-05"

	message_size: 50