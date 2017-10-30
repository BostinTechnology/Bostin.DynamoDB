#!/bin/bash

# 
# 
# Script to download and configure a local installation of dynamoDB
#
#
# Copyright (C) 2017 Ciaran Morgan - All Rights Reserved



#                   Revision History
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#	  Version		Date			Details
#   =========	=============	========================================
#	1.0         23-Oct-2017		Initial release
#
#
#
#

# This will download the required sqlite4java source for the ARM device and compile it to form a working dynamoDB 

echo "************************************************"
echo "Downloading sqlite4java and dynamoDB.....>"

INSTALLDIR=`pwd`

mkdir dynamoDB
cd dynamoDB

wget --quiet https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/sqlite4java/source-archive.zip >/dev/null

wget --quiet https://raw.github.com/SpatialInteractive/sqlite4java-custom/master/custom/swig/sqlite_wrap.c >/dev/null

wget --quiet https://s3.eu-central-1.amazonaws.com/dynamodb-local-frankfurt/dynamodb_local_latest.tar.gz >/dev/null

echo " Finished downloading, now extracting....>"

tar -xf ./dynamodb_local_latest.tar.gz 


unzip ./source-archive.zip 

mv sqlite_wrap.c ./sqlite4java/trunk/

cd ./sqlite4java/trunk/


# Now build gcc
#gcc
echo " Compiling Libsqlite4java library...."

gcc -O2 -DNDEBUG -fpic -DARM -DARCH="ARM" -DLINUX -D_LARGEFILE64_SOURCE -D_GNU_SOURCE -D_LITTLE_ENDIAN -fno-omit-frame-pointer -fno-strict-aliasing -static-libgcc -I./sqlite -I/usr/lib/jvm/jdk-7-oracle-armhf/include -I/usr/lib/jvm/jdk-7-oracle-armhf/include/linux -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_MEMORY_MANAGEMENT -DSQLITE_ENABLE_STAT2 -DHAVE_READLINE=0 -DSQLITE_THREADSAFE=1 -DSQLITE_THREAD_OVERRIDE_LOCK=-1 -DTEMP_STORE=1 -DSQLITE_OMIT_LOAD_EXTENSION=1 -DSQLITE_OMIT_DEPRECATED -DSQLITE_OS_UNIX=1 -c ./sqlite/sqlite3.c -o sqlite3.o
gcc -O2 -DNDEBUG -fpic -DARM -DARCH="ARM" -DLINUX -D_LARGEFILE64_SOURCE -D_GNU_SOURCE -D_LITTLE_ENDIAN -fno-omit-frame-pointer -fno-strict-aliasing -static-libgcc -I./sqlite -I/usr/lib/jvm/jdk-7-oracle-arm-vfp-hflt/include -I/usr/lib/jvm/jdk-7-oracle-arm-vfp-hflt/include/linux  -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_MEMORY_MANAGEMENT -DSQLITE_ENABLE_STAT2 -DHAVE_READLINE=0 -DSQLITE_THREADSAFE=1 -DSQLITE_THREAD_OVERRIDE_LOCK=-1 -DTEMP_STORE=1 -DSQLITE_OMIT_LOAD_EXTENSION=1 -DSQLITE_OMIT_DEPRECATED -DSQLITE_OS_UNIX=1 -c sqlite_wrap.c -o sqlite_wrap.o
gcc -O2 -DNDEBUG -fpic -Di586 -DARCH="i586" -DLINUX -D_LARGEFILE64_SOURCE -D_GNU_SOURCE -D_LITTLE_ENDIAN -fno-omit-frame-pointer -fno-strict-aliasing -static-libgcc -I./sqlite -I./native -I/usr/lib/jvm/jdk-7-oracle-arm-vfp-hflt/include -I/usr/lib/jvm/jdk-7-oracle-arm-vfp-hflt/include/linux -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_MEMORY_MANAGEMENT -DSQLITE_ENABLE_STAT2 -DHAVE_READLINE=0 -DSQLITE_THREADSAFE=1 -DSQLITE_THREAD_OVERRIDE_LOCK=-1 -DTEMP_STORE=1 -DSQLITE_OMIT_LOAD_EXTENSION=1 -DSQLITE_OMIT_DEPRECATED -DSQLITE_OS_UNIX=1 -c ./native/sqlite3_wrap_manual.c -o sqlite3_wrap_manual.o
gcc -O2 -DNDEBUG -fpic -Di586 -DARCH="i586" -DLINUX -D_LARGEFILE64_SOURCE -D_GNU_SOURCE -D_LITTLE_ENDIAN -fno-omit-frame-pointer -fno-strict-aliasing -static-libgcc -I./sqlite -I./native -I/usr/lib/jvm/jdk-7-oracle-arm-vfp-hflt/include -I/usr/lib/jvm/jdk-7-oracle-arm-vfp-hflt/include/linux  -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_MEMORY_MANAGEMENT -DSQLITE_ENABLE_STAT2 -DHAVE_READLINE=0 -DSQLITE_THREADSAFE=1 -DSQLITE_THREAD_OVERRIDE_LOCK=-1 -DTEMP_STORE=1 -DSQLITE_OMIT_LOAD_EXTENSION=1 -DSQLITE_OMIT_DEPRECATED -DSQLITE_OS_UNIX=1 -c ./native/intarray.c -o intarray.o
gcc -O2 -DNDEBUG -fpic -Di586 -DARCH="i586" -DLINUX -D_LARGEFILE64_SOURCE -D_GNU_SOURCE -D_LITTLE_ENDIAN -fno-omit-frame-pointer -fno-strict-aliasing -static-libgcc -shared -Wl,-soname=libsqlite4java-linux-arm.so -o libsqlite4java-linux-arm.so sqlite3.o sqlite_wrap.o sqlite3_wrap_manual.o intarray.o

cp libsqlite4java-linux-arm.so ../../DynamoDBLocal_lib/

echo " Done.  Now configuring DynamoDB as a system service"

SVC_TMP="/tmp/svc"
SVC_SCRIPT="/lib/systemd/system/Bostin.DynamoDB.service"

echo "[Unit]                                                        "> $SVC_TMP
echo "Description = Bostin Technology DynamoDB Service              ">>$SVC_TMP
echo "                                                              ">>$SVC_TMP
echo "[Service]                                                     ">>$SVC_TMP
INSTALLDIR="ExecStart="$INSTALLDIR"/run_DynDB.sh"
echo $INSTALLDIR                                                     >>$SVC_TMP
echo "                                                              ">>$SVC_TMP
echo "[Install]                                                     ">>$SVC_TMP
echo "WantedBy = multi-user.target                                  ">>$SVC_TMP
sudo mv $SVC_TMP $SVC_SCRIPT
sudo chown root:root $SVC_SCRIPT
sudo chmod 644 $SVC_SCRIPT

sudo systemctl enable Bostin.DynamoDB.service
sudo systemctl start  Bostin.DynamoDB.service

echo " All done."
echo " "
echo "Action             Command"
echo "=========================="
echo "Stop  Service      sudo systemctl stop Bostin.DynamoDB.service"
echo "Start Service      sudo systemctl start Bostin.DynamoDB.service"
echo "View Status        sudo systemctl status Bostin.DynamoDB.service"
echo ""
echo "**************88888888888888888**********************************"


