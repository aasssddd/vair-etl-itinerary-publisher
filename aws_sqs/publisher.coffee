# publisher.coffee
AWS = require 'aws-sdk'
logger = require("vair_log").Logger

class Publisher

	log: logger.getLogger()
	constructor: (aws_credential)->
		AWS.config.update {
			accessKeyId: aws_credential.accessKeyId
			secretAccessKey: aws_credential.secretAccessKey
			region: aws_credential.region
		}
		AWS.config.apiVersion = aws_credential.apiVersion
		@log.info "initialize AWS service"



	send: (queueUrl, serialized_message, callback) ->
		sqs = new AWS.SQS
		log = @log
		param = 
			MessageBody: serialized_message
			QueueUrl: queueUrl

		sqs.sendMessage param, (err, data) =>
			if err?
				log.error "send message fail! #{err}"
				throw err
			log.info "send result: #{JSON.stringify data}"
			return callback null, data


module.exports = Publisher