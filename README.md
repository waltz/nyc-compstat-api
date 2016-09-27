# NYC Compstat API

[![Build Status](https://travis-ci.org/waltz/nyc-compstat-api.svg?branch=master)](https://travis-ci.org/waltz/nyc-compstat-api)

New York City revolutionized the way cities were policed with their COMPSTAT approach. The police department releases partial reports of the data that they collect, but this information is hidden in PDF documents that disappear after a week. This scraper downloads all of the reports on the [NYPD's crime statistics page](http://www.nyc.gov/html/nypd/html/crime_prevention/crime_statistics.shtml) and uploads them to an S3 bucket.

## Public Archive

This scraper currently runs every day and uploads the results here:

https://nyc-compstat-api.s3.amazonaws.com/

## Using this thing

* Install the required gems.

`$ bundle`

* Run the tests.

  `$ rake`

* Run the main archiver.

	`$ ruby application.rb`
