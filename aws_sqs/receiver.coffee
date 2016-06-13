# receiver.coffee
AWS = require 'aws-sdk'
logger = require("vair_log").Logger
config = require '../config'

class Receiver 
	log: logger.getLogger()

	constructor: () ->
		AWS.config.update {
			accessKeyId: config.aws.accessKeyId
			secretAccessKey: config.aws.secretAccessKey
			region: config.aws.region
		}
		AWS.config.apiVersion = config.aws.API_VERSION
		@log.info "initialize AWS service"

	receive: (queueUrl) =>
		param = 
			QueueUrl: queueUrl

		log = @log
		sqs = new AWS.SQS
		sqs.receiveMessage param, (err, data) ->
			if err?
				log.error "error: #{err}"
				throw err
			log.info "data received: #{JSON.stringify data, null, 4}"

module.exports = Receiver