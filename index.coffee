# index.coffee
Client = require 'ftp'
Logger = require('vair_log').Logger
fs = require 'graceful-fs'
async = require 'async'
moment = require 'moment'
iconv = require 'iconv-lite'
unique = require 'array-unique'
Publisher = require './aws_sqs/publisher'
config = require './config'

log = Logger.getLogger()
pnrlist = []

c = new Client
c.on 'ready', () ->
	c.cwd config.ftp.targetFilePath, (err, currentDir) ->
		if err?
			return log.error "ftp connect error: #{err}"
		else
			log.info "work directory is setting to #{currentDir}"

			beginDate = moment().add -1, 'day'
			endDate = moment().add -1, 'day'
				
			log.info "start process with parameters: #{JSON.stringify process.argv}"
			if process.argv.length >= 3 and moment(process.argv[2], "YYYY/MM/DD").isValid()
				beginDate = moment(process.argv[2], "YYYY/MM/DD")
				endDate = beginDate

			if process.argv.length >= 4 and moment(process.argv[3], "YYYY/MM/DD").isValid()
				endDate = moment process.argv[3], "YYYY/MM/DD"
			
			log.info "query days: #{beginDate.format "YYYY/MM/DD"} ~ #{endDate.format "YYYY/MM/DD"}"

			dateArray = []
			while beginDate.startOf('day').isBefore endDate.startOf('day')
				dateArray.push beginDate.format("YYYYMMDD")
				beginDate.add 1, 'day'

			dateArray.push endDate.format("YYYYMMDD")
			log.info dateArray + ""

			async.forEachOfSeries config.ftp.pnrSource, (index, fileName, cb) ->

				async.forEachOfSeries dateArray, (day, idx, callback) ->

					filePrefix = "#{day}__"
					log.info "retrieve ftp file: #{filePrefix}#{fileName}"

					c.get "#{filePrefix}#{fileName}", (err, stream) ->
						if err?
							return log.error "retrieve file #{filePrefix}#{fileName} error: #{err}"
						csv = require 'fast-csv'
						csvStream = csv {delimiter: ';', ignoreEmpty: true}
						.on 'data', (data) ->
							if data[index]?
								log.debug "#{fileName}, #{index}, #{iconv.decode(data[index], 'utf-16')}"
								pnrlist.push iconv.decode(data[index], 'utf-16')
								# pnrlist.push data[col]
						.on 'data-invalid', (data) ->
							log.warn "invalid data #{data}"
						.on 'end', () ->
							log.info "#{filePrefix} data parsed"
							unique pnrlist
							callback null
						stream.pipe csvStream

				, (err) ->
					if err?
						log.error "#{err}"
					log.info "data parsed"
					cb null

			, (err) ->
				if err?
					log.error "#{err}"
				c.end()

c.on 'error', (err) ->
	log.error "error: #{err}"
c.on 'end', () ->
	unique pnrlist
	log.info "PNR length: #{pnrlist.length}"

	# split into 
	msg_size = config.message_size

	async.whilst () ->
		return pnrlist.length > 0
	, (callback) ->
		subPnrlist = pnrlist.splice 0, msg_size
		message = 
			pnrlst: subPnrlist

		publisher = new Publisher {
			accessKeyId: config.aws.accessKeyId,
			secretAccessKey: config.aws.secretAccessKey
			region: config.aws.region
		}

		publisher.send config.aws.queueUrl, "#{JSON.stringify message}", (err, data) ->
			if err?
				log.error "send message to SQS fail: #{err}"
			else
				log.info "send message: #{JSON.stringify data} to SQS successful"
			callback err
	, (err) ->
		process.exit()

c.connect {
	host: config.ftp.host,
	port: config.ftp.port,
	user: config.ftp.user,
	password: config.ftp.password,
	secure: true,
	pasvTimeout: 20000,
	keepalive: 20000,
	secureOptions: { rejectUnauthorized: false }
}

