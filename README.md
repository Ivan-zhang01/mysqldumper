## Installation
Make Script Executable
```sh
chmod +x mysqldumper.sh
```
Edit Config File `confi/config.sh`
```sh
# Sey MySQL ROOT PASSWORD
MYSQLPASSWD=''
# Number of Days to Keep Backup, Default is set to 30
DAYS="30"
# SET System OS [osx,linux]
SYSTEM="osx"
```
Run
```sh
./mysqldumper.sh
```

## Dump Files
Dump Files Location
```sh
./dumps/
```


## Run as a Cron Job
Set APP's Path, by default is set to `.`
```sh
# Run setup.sh
./setup.sh
```
Make sure you Pipe output to `/dev/null`
```sh
FULLPATH/mysqldumper.sh &> /dev/null
```
