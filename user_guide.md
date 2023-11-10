# Intruduction
An Rdb schema migration tools that develop on ruby and Supporting SQL Server and MySQL. This help you to deploy you database schema change. stored procedure and create or update agent job on SQL Server formally and solidly.

- [Intruduction](#intruduction)
- [Functions](#functions)
- [Development, Testing phases](#development-testing-phases)
- [How to use it for development?](#how-to-use-it-for-development)
  - [Prepare New Project from template](#prepare-new-project-from-template)
    - [Get the schematic base code from github](#get-the-schematic-base-code-from-github)
    - [Build the schematic base image for development](#build-the-schematic-base-image-for-development)
    - [Create development project](#create-development-project)
  - [Start development in new project folder](#start-development-in-new-project-folder)
    - [Start project container](#start-project-container)
    - [Run database setup](#run-database-setup)
    - [Start development locally inside dev.app container](#start-development-locally-inside-devapp-container)
    - [Development features](#development-features)
    - [Database migration create and deploy](#database-migration-create-and-deploy)
    - [Stored Procedures create and deploy](#stored-procedures-create-and-deploy)
    - [SQL Server jobs create and deploy](#sql-server-jobs-create-and-deploy)
  - [Project folder structure](#project-folder-structure)


# Functions
- SQL Server, help to create database schema, and create SQL Server Agent jobs
- MySQL, help to create database schema.

# Development, Testing phases
In development phase, we hope to have a environment that build up fast and work independent, with the tools here, build our self-contain a development environment and also prepare some sample data for testing purpose.

# How to use it for development?
The schematic base that content core logic for schema, sp, jobs deployment but also help to create new project template for development. 
1. Clone Schematic and build the base image
2. Create New project by schematic project template

## Prepare New Project from template
### Get the schematic base code from github
**Get it by command**
```bash
cd /home/ds/_Devlopment/temp
git clone https://github.com/larryloi/schematic.git
```
**Or use VScode**
 1. Open Remote Explorer and connect Remote Host
 2. Clone Git Repository to /home/ds/_Devlopment/temp

### Build the schematic base image for development
**Open Terminal and run build image command**
```bash
cd docker
make build.base.dev
```
**The below schematic-base will be built**
```bash
ubt23 :: temp/schematic/docker ‹main› » docker images
REPOSITORY                        TAG                     IMAGE ID       CREATED        SIZE
quay.io/metasync/schematic-base   0.2.0-dev               dd8b8c8aa215   24 hours ago   413MB
quay.io/metasync/schematic-base   0.2.0-dev.0             dd8b8c8aa215   24 hours ago   413MB
```
### Create development project
In schematic home path, execute the below command, that creates project template for development. This project folder will be created in parent folder in this case.
```bash
cd schematic
make create.project.mssql project=stg app=acsc target=../
```


## Start development in new project folder
Open the New project folder ( In this case is stg_acsc )

We need to kick start the container that including dev.app and dev.db to devlop our code. Before that, set database password to evironment variable, ```MSSQL_SA_PASSWORD``` in ```secret.env``` file:
```bash
## MSSQL
vi docker/make.env/mssql/secret.env
```

### Start project container
The below command will start up container for ```dev.app``` and ```dev.db```
```bash
cd <Project-Path>/stg_acsc/docker
make up
```
### Run database setup
```bash
make shell.dev.db

# Now you get into the shell of the database container
./setup-db.sh
exit
```
This ```setup-db.sql``` file use to prepare database setup for your development, for example, ```db```, ```schema``` and ```login``` setup. you may update as your need

```bash
<Project-Path>/docker/deploy/mssql/scripts/sql/setup-db.sql
```

### Start development locally inside dev.app container 
```bash
make shell.dev
```

### Development features
**List rake tasks avalable**
Schematic provides a few handy rake tasks out-of-box:
```bash
rake -T
rake cipher:decrypt_env_var[env_var]  # Decrypt an environment variable
rake cipher:encrypt[string]           # Encrypt a string
rake cipher:encrypt_env_var[env_var]  # Encrypt an environment variable
rake cipher:generate_keys             # Generate cipher keys
rake db:applied_migration[steps]      # Show a given applied schema migration
rake db:applied_migrations            # Show applied schema migrations
rake db:apply[steps]                  # Apply last n migrations
rake db:clean                         # Remove migrations
rake db:create_migration[name]        # Create a migration file with a timestamp and name
rake db:migrate[version]              # Run migrations
rake db:migration_to_apply[steps]     # Show a given schema migration to apply
rake db:migrations_to_apply           # Show schema migrations to apply
rake db:redo[steps]                   # Redo last n migrations
rake db:reset                         # Remove migrations and re-run migrations
rake db:rollback[steps]               # Rollback last n migrations
rake deploy                           # Run deployment
rake job:create[name]                 # Create job template files
rake job:deploy                       # Apply jobs
rake sp:create[name]                  # Create a stored procedure template file
rake sp:deploy                        # Apply stored procedures
```

### Database migration create and deploy
After a new project is created, it is most likely to create your database migration before any other development work:

```bash
rake db:create_migration[create_table_CFPAI01a]
New migration is created: /home/app/db/migrations/stg_acsc/20231101084508_create_table_CFPAI01a.rb

rake db:create_migration[CFPAI_add_index_DTCTAI_ACCTAI]
New migration is created: /home/app/db/migrations/stg_acsc/20231101084529_CFPAI_add_index_DTCTAI_ACCTAI.rb

```

**Edit the migration scripts**

Above 2 command created 2 migration script from a template. you may update the mgiration content as what you want.
Edit these file under the path ```<Project-Path>/src/db/migrations/stg_acsc``` by ```VScode```.

The below sample is telling you that specify a ```ds``` schema while creating table ```CFPAI``` by using function ```Sequel.qualify```. 

```ruby
Sequel.migration do
  change do
    create_table(Sequel.qualify(:ds, :CFPAI)) do
      String :journalTime, size: 85
      String :sequenceNumber, size: 85
      String :entryType, size: 85
      String :ACCTAI, size: 85
      String :CODEAI, size: 85
      String :CNTIAI, size: 85
      String :CPIDAI, size: 85
      String :PRIDAI, size: 85
      String :VALDAI, size: 85
...

      unique [:sequenceNumber,:entryType]
    end
  end
end
```
For more detail information. just check the below 

https://github.com/jeremyevans/sequel/blob/master/doc/schema_modification.rdoc


**Deploy migration scripts**

Run the below command to deploy your migration scripts
```bash
rake db:migrate
```


### Stored Procedures create and deploy
**Create Stored Procedures from template**
```bash
rake sp:create[sp_acsc_CFPAI]
New Stored procedure template is created: /home/app/stored_procedures/stg_acsc/sp_acsc_CFPAI.sql
```

**Edit the migration scripts**

Above command created stored procedure script from a template. you may update the content as what you want.
Edit these file under the path ```<Project-Path>/src/stored_procedures/stg_acsc``` by ```VScode```.

**Deploy Stored procedures**

Run the below command to deploy your Stored procedures
```bash
rake sp:deploy

  >> Executing script from /home/app/stored_procedures/stg_acsc/sp_acsc_CFPAI.sql

  >> Create new stored procedure.
```


### SQL Server jobs create and deploy
**Create SQL Server jobs from template**
```bash
rake job:create[stg_acsc_CPFAI01a]
New job template is created: /home/app/jobs/stg_acsc/stg_acsc_CPFAI01a.yaml
New environment template is created: /home/app/env/jobs/stg_acsc_CPFAI01a_env.yaml
```

**Edit the Job files**

Above command created job yaml and job environment files from  template. you may update the content as what you want.
Edit these file under the path 
- ```<Project-Path>/src/jobs/stg_acsc```  
- ```<Project-Path>/docker/deploy/env/jobs``` 
  
  by ```VScode```.

**Deploy Stored procedures**

Run the below command to deploy your Stored procedures
```bash
rake job:deploy
/usr/local/bundle/gems/sequel-5.73.0/lib/sequel/adapters/tinytds.rb:34: warning: undefining the allocator of T_DATA class TinyTds::Result
  >> Loading general configuration from /home/app/jobs/general.yaml

  >> Loading configuration from /home/app/jobs/stg_acsc/stg_acsc_CPFAI01a.yaml
  >> Creating job stg_acsc_CPFAI01a
    >> Adding step Executing sp_template
    >> Adding step Executing sp_template again
  >> Adding schedule to the job stg_acsc_CPFAI01a
  >> Adding server to the job stg_acsc_CPFAI01a
---------------------------------------------
/home/app $ 
```

## Project folder structure
Here is the project folder structure for a sample project:

```bash
.
|-- CHANGELOG.md
|-- README.md
|-- VERSION
|-- docker
|   |-- Makefile
|   |-- Makefile.env
|   |-- build
|   |   |-- dev
|   |   |   |-- Dockerfile
|   |   |   |-- Makefile
|   |   |   `-- build.env
|   |   |-- rel
|   |   |   |-- Dockerfile
|   |   |   |-- Makefile
|   |   |   `-- build.env
|   |   `-- shared
|   |       |-- build.env
|   |       `-- build.mk
|   |-- deploy
|   |   |-- docker-compose.yaml
|   |   |-- env
|   |   |   |-- cipher.env
|   |   |   |-- database.env
|   |   |   |-- jobs
|   |   |   |   |-- acsc_hist_table01a_env.yaml
|   |   |   |   |-- acsc_hist_table01b_env.yaml
|   |   |   |   `-- general.env
|   |   |   `-- secret.env
|   |   `-- mssql
|   |       |-- docker-compose.yaml
|   |       `-- scripts
|   |           |-- mssql.sh
|   |           |-- setup-db.sh
|   |           `-- sql
|   |               `-- setup-db.sql
|   `-- make.env
|       |-- base_image.env
|       |-- cipher.env
|       |-- database.env
|       |-- docker.env
|       |-- mssql
|       |   |-- database.env
|       |   `-- secret.env
|       `-- project.env
`-- src
    |-- Rakefile
    |-- db
    |   `-- migrations
    |-- env
    |   `-- jobs
    |-- jobs
    |   |-- acsc_hist
    |   |   |-- acsc_hist_table01a.yaml
    |   |   `-- acsc_hist_table01b.yaml
    |   `-- general.yaml
    `-- stored_procedures
        `-- acsc_hist
            |-- acsc_hist_table01a.sql
            `-- acsc_hist_table01b.sql
```