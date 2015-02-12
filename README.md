# Boxlet

Boxlet is a server + mobile app system that allows you to take advantage of free space on any cloud server you have ssh access to as a backup/sync for your photos.

Boxlet is also compatible with storing files on Amazon S3.

From the mobile iOS app, you can specify any server:port where the Boxlet server is running to sync and backup your photos to a remote server.


## Dependencies

- Ruby 2.0+ (Has been tested in 2.0 and 2.1.1)
- MongoDB 2.4+
- Linux server with free drive space and an open port
- iOS 7.1 (iPhone app)


## Installation

`gem install boxlet`


## Usage

Run `boxlet` from any folder to stat the server with default settings.

See below for config and parameters.


## Config

Here's a sample Boxlet configuration file `config.yml` with default values populated:

```yml
# config.yml

# Environment
environment: development
debug: true

# File system parameters
path: ./
upload_dir: ./uploads
tmp_dir: /tmp
file_system_root: /

# Capacity is either a percentage of available space on the drive or number in MB
capacity: 90%

# Server type and listen parameters
port: 8077
host: localhost
server_type: thin
daemonize: false

#use s3
s3:
  enabled: false
  access_key_id:
  secret_access_key:
  bucket: boxlet

# Database config
db:
  development:
    host: localhost
    db: boxlet_dev
  production:
    host: localhost
    # port:
    # user:
    # pass:
    db: boxlet

```

Many config options are available as command-line parameters

- Path: `-f` or `--path`
  - Default: `./`
- Port: `-p` or `--port`
  - Default: `8077`
- Host: `-o` or `--host`
  - Default: `localhost`
  - Public: `0.0.0.0`
- Server Type: `-s` or `--server_type`
  - Default: `rack`
- Environment: `-E` or `--environment`
  - Default: `development`
- Daemonize: `-D` or `--daemonize`
  - Default: `false`
- Debug: `-d` or `--debug`
  - Default: `true`
- Upload Directory: `-U` or `--upload_dir`
  - Default: `./uploads`
- Temp Directory: `-T` or `--tmp_dir`
  - Default: `./tmp`
- File System Root: `-r` or `--file_system_root`
  - Default: `/`
- Capacity: `-C` or `--capacity`
  - Default: `90%`



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
