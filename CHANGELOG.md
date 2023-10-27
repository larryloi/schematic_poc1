## [0.2.0] (2023-10-26)

	* Fixed a gitignore rule to allow some secret env files to be checked into code repository
	* Refactored make env files to consolidate configuration settings
	* Added environment variables DB_TYPE to indicate database engine: mssql or psql so that database identifier mangling can be properly configured in Ruby Sequel
	* Provided convenient Makefile targets to show related docker images
	* Updated README.md for project creation with proper database passwords configured

## [0.1.5] (2023-10-24)

	* Refactored global configurations and build/deploy/make configurations
	* Refactored database configurations
	* Refactored folder structure
	* Refined project template generation

## [0.1.0] (2023-10-20)

	* Initial commit for the project
