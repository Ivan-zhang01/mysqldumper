# Pretty print to STDOUT
message(){
	# Message
	MESG=$1
	case $2 in
		'info')
			COLOR="\e[0;33m";;
		'alert')
			COLOR="\e[0;31m";;
		'mesg')
			COLOR="\e[0;32m";;
		*)
			COLOR="\e[0;37m";;
	esac

	printf "$COLOR%b \e[0m\n" "$MESG"
}

#  Log file
log() {
    # Log Message
    logMessage=$1

    logdate=`date +%b\ %d\ %T`
    hostname=`hostname`
    mydirname=`dirname $0`
    myscript=`basename $0`

    echo $logdate $hostname $myscript : $logMessage >> $LOGFILE
}

# MySQL Status
mySQLStatus(){

  # Check PIF FILE
  case $SYSTEM in
    'osx' )
      # Hostname
      HOTSNAME=$(hostname)

      # Mysql PID File
      MYSQLPID="/usr/local/var/mysql/${HOTSNAME}.pid"
      ;;
    'linux')
      # PID File
      MYSQLPID="/var/run/mysqld/mysqld.pid"
      ;;
    *)
      message "System is not set, See [ $CONFDIR/config.sh ]" "alert"
      exit
    ;;
  esac

  # Check: MySQL Server must be rinning
  if [[ ! -f $MYSQLPID  ]]; then
    message "MySQL Server is not running" "alert"
    log "MySQL Server is not running"
    exit
  fi
}

# Check Root password is set
mySQLRootPassword(){
  # Check if root password is not set or it set to password01
  #if [[ -z $MYSQLROOTPASSWD || $MYSQLROOTPASSWD =~ ^password.*$ ]]; then
  if [[ -z $MYSQLROOTPASSWD ]]; then

    message "MySQL Root Password Is Not Set, See [ ${CONFDIR}/config.sh ]" "alert"
    log "MySQL Root Password Is Not Set, See [ ${CONFDIR}/config.sh ] "
    exit
  fi
}

# Clean up Databases
dbCleanUp() {
  # Days in SEC
  # ( 60 * 60 ) * ( 24 * $DAYS )
  # (sec * min) * ( 1day * Days )
  DAYSINSEC=$(( ( 60 * 60 ) * ( 24 * $DAYS ) ))

  # Give user Feedback
  message "Cleaning Up Databases Older Than: ${DAYS} Days" "info"
  log "Cleaning Up Databases Older Than: ${DAYS} Days"

  # Find ALL dumped db
  FINDDB=$(find ${DUMP} -type f -iname '*sql' | tr "\n" "|")
  # Load FINDDB into array
  IFS="|" read -a finddbs <<< "$FINDDB"

  # iterate through finddbs array
  for i in "${!finddbs[@]}"; do
    # Get File name only
    DB=$(basename  "${finddbs[$i]}")
    # Explode DB name to get unix timestamp
    IFS="." read -a db <<< "$DB"
    # DUMP TIME
    DUMPTIME="${db[1]}"

    # IF Databse is older then $DAYS Remove it
    if [[ $(( $UNIXTIME - $DUMPTIME )) -gt $DAYSINSEC ]]; then
      message "Removing: ${finddbs[$i]}" "alert"
      log "Removing: ${finddbs[$i]}"
      # Remove Databses older than $DAYS
      rm -rf "${finddbs[$i]}"
    fi

  done
}

# Dump Databses
dbDumper() {
  # SQL: Get All Databases
  SQL="SHOW DATABASES;"
  # Get All Databases
  DATABASES=$(echo $SQL | mysql -u $MYSQLROOTUSER -p"$MYSQLROOTPASSWD" 2> /dev/null | tr "\n" "|")
  # Load Databses into an array
  IFS="|" read -a dbs <<< "$DATABASES"

  # Give user Feedback
  echo ""
  message "Dumping Databses." "info"

  # Irrtiate thought the dbs array
  for i in "${!dbs[@]}"; do
    case "${dbs[$i]}" in
      "Database" ) ;;
      "information_schema" ) ;;
      "performance_schema" ) ;;
      "mysql" ) ;;
      "test" ) ;;
      *)
      # DB Name
      DB="${dbs[$i]}"
      # Dump Filename
      DUMPFILENAME="${PREFIX}.${UNIXTIME}.${DB}.sql"
      # DB DIR
      DBDIR="${DUMP}/${DB}"
      # Seperate DB into different dir
      mkdir -p $DBDIR
      # Only Dump user dbs
      message "Dumping Database: [ ${DB} ] [ $DUMPFILENAME ]" "mesg"
      log "Dumping Database: [ ${DB} ] [ $DUMPFILENAME ]"
      # Dump DB
      mysqldump -u $MYSQLROOTUSER -p"$MYSQLROOTPASSWD" $DB > "${DBDIR}/${DUMPFILENAME}" 2> /dev/null
      ;;
    esac
  done

  echo ""
}
