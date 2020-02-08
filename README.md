# Vesta Control Panel Google Drive Backup
Backup VestaCP Users to separate Google Drive folders

## Environment

- Ubuntu 16.04

## Requirements

- https://github.com/gdrive-org/gdrive
- Google Drive Account
- Google Drive API
- git
- Go 1.12

## Installation and Configuration steps

Next steps assume you are on VPS server having root access.
If this is not your case apply sudo to the commands.

### Install git
- `apt update`
- `apt install software-properties-common`
- `add-apt-repository ppa:git-core/ppa # apt update; apt install git`

### Install and config Go
- `wget https://dl.google.com/go/go1.12.linux-amd64.tar.gz`
- `mv go1.12.linux-amd64.tar.gz /usr/local/`
- `cd /usr/local`
- `tar -zxvf go1.12.linux-amd64.tar.gz`
- `cd ~`
- `nano .profile`
- // Add these global variables as follow at the end of the `.profile`:

`export GOROOT=/usr/local/go`

`export GOPATH=$HOME/gosource ~/.profile`

`export PATH=$GOPATH/bin:$GOROOT/bin:$PATH`

- `source ~/.profile`
- // Check Go is installed correctly:

`go version`

### Google Drive API configuration
- // Login to Google Developers and create a new project. Give it a name, for instance VestaCP-Gdrive-backup 
- https://console.developers.google.com/apis/dashboard
- // Enable Google Drive API and then click on Credentials
- https://console.developers.google.com/apis/library/drive.googleapis.com
- // From the dropdown select Other UI and check User data
- // Click on "What credentials do I need?"
- // Give it a name, for instance VestaCP-Gdrive-backup and save

### Handle existing `gdrive` installation
- // If old local `gdrive` installation exist:
- `cd ~`
- `rm -r gdrive`
- `rm -r .gdrive`
- `rm /usr/local/bin/gdrive`


### Install `gdrive` app
- `go get github.com/gdrive-org/gdrive`
- // Change the Credentials from Google Drive API in the `gdrive` source code
- `cd go/src/github.com/gdrive-org/gdrive/`
- `nano handlers_drive.go`
- // On lines 17 and 18 change the credentials (ClientId and ClientSecret) with those created in Google Drive API
- `const ClientId = "your-client-id.apps.googleusercontent.com"`
- `const ClientSecret = "your-client-secret"`
- // Compile the executable by run `go build` in `go/src/github.com/gdrive-org/gdrive/`
- `go build`
- `install gdrive /usr/local/bin/gdrive`
- `install gdrive ~/go/bin/gdrive`
- // You’ll need to tell Google Drive to allow this program `gdrive` to connect to your account. To do this, run the `gdrive` program with any parameter and copy the text it gives you to your browser. Then paste in to your SSH window the response code that Google gives you. Run the following:
- `/usr/local/bin/gdrive about`
- // Follow the steps from the output

### Create vesta_gdrive_backup Bash script
- `cd ~`
- `touch vesta_gdrive_backup.sh`
- `chmod +x vesta_gdrive_backup.sh`
- `nano vesta_gdrive_backup.sh`
- // Copy and paste in the script the content from here:
- https://github.com/grandeto/vestacp_gdrive_backup/blob/master/vesta-gdrive-backup.sh
- // Following the example in `vesta_gdrive_backup.sh` (lines 42-45), add a new function execution at the end of the `vesta_gdrive_backup.sh` for every user you wish to backup in Google Drive.
- // This script will create a separate folder for every VestaCP user in `/vesta-gdrive-backups`, will move the latest backup files from `/backup` to these separate folders and will remove the last backup file from every separate folder if the maximum backups count is exceeded

### Google Drive post-configuration
- // Open the Google Drive account you just integrated with `gdrive`
- https://drive.google.com/drive/
- Create separate folders for every VestaCP user you wish to backup to Google Drive
- The name of each of these folders should be same as the name of the related VestaCP user you wish to backup to Google Drive

### Add vesta_gdrive_backup cron tasks
- // Open your VestCP admin dashboard and go to CRON section
- https://123.123.123.123:8083/list/cron/
- // Find the cron job named `sudo /usr/local/vesta/bin/v-backup-users`
- // Then remember the execution time of this cron. For instance: `10 03 * * 1`
- // Open cron tasks in your Linux machine
- crontab -e
- // Add a new cron task that will execute `vesta_gdrive_backup.sh` after VestaCP backup cron task is finished. For instance:
- `10 4 * * 1 /root/vesta_gdrive_backup.sh`
- // Add a new Google Drive sync cron task for every VestaCP user you wish to backup in Google Drive. For instance:

`#admin backup`

`15 4 * * 1 /usr/local/bin/gdrive sync upload --delete-extraneous /vesta-empty-dir 146D974dy437dh7347778d378h34`

`20 4 * * 1 /usr/local/bin/gdrive sync upload --delete-extraneous /vesta-gdrive-backups/admin 146D974dy437dh7347778d378h34`

- // The first `gdrive` cron command will keep your Google Drive free space save by first deleting the old files by replacing them with an empty file ( from `/vesta-empty-dir/emptyfile.txt` ) and then the second `gdrive` cron command will replace the empty file by uploading the latest backup files for the given VestaCP user
- // Replace `146D974dy437dh7347778d378h34` with your Google Drive folder ID. 
- // You can find the IDs of your Google Drive folders by open a desired folder in browser and copy its ID from the last part of the URL `http://drive.google.com/drive/u/0/folders/146D974dy437dh7347778d378h34`


