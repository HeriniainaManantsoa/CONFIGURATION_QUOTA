#!/bin/bash
PARTITION_HOME="/home"
POINT_MONTAGE_HOME="/mnt/new_home"
PARTITION_DATA="/data"
POINT_MONTAGE_DATA="/mnt/new_data"

mkdir $POINT_MONTAGE_HOME
mkdir $POINT_MONTAGE_DATA
mount $PARTITION_HOME $POINT_MONTAGE_HOME
mount $PARTITION_DATA $POINT_MONTAGE_DATA

#---------------------activation_quota---------------------#
activation_quota () {
  echo "$PARTITION_HOME $POINT_MONTAGE_HOME ext4 defaults,usrquota,grpquota 0 2" >> /etc/fstab
  mount -o remount $POINT_MONTAGE_HOME
  quotacheck -cum $POINT_MONTAGE_HOME
  quotacheck -cgm $POINT_MONTAGE_HOME
  quotaon $POINT_MONTAGE_HOME
}
#---------------------recupere_utilisateur---------------------#
get_user () {
  LIST_USER=$(awk -F ':' '{if ($3 > 999 && $3 < 6000) print $1}' /etc/passwd)
}
#---------------------recupere_goupe---------------------#
get_group () {
  LIST_GROUP=$(awk -F ':' '{if ($3 > 999 && $3 < 6000) print $1}' /etc/group)
}
#---------------------quota_user---------------------#
set_quota_user () {
  for x in $LIST_USER
  do 
    setquota -u $x 500M 700M 0 0 $POINT_MONTAGE_HOME
  done
}
#---------------------quota_group---------------------#
set_quota_group () {
  for x in $LIST_GROUP
  do 
    setquota -u $x 1G 1.5G 0 0 $POINT_MONTAGE_HOME
  done
}
#---------------------quota_inode_user---------------------#
set_quota_inode_user () {
  for x in $LIST_USER
  do 
    setquota -u $x 0 0 1000 1500 $POINT_MONTAGE_DATA
  done
}
#---------------------quota__inode_group---------------------#
set_quota_inode_group () {
  for x in $LIST_GROUP
  do 
    setquota -u $x 0 0 10000 15000 $POINT_MONTAGE_HOME
  done
}

activation_quota
get_user
get_group
set_quota_user
set_quota_group
set_quota_inode_user
set_quota_inode_group
