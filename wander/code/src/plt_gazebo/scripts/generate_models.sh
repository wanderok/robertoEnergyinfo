#!/bin/bash

# After making your own models in plt_description (.urdf),  use this script to convert then to .sdf

SRC=`rospack find plt_description`/urdf

DEST=`rospack find plt_gazebo`/models/pole
echo 'Generating pole.sdf'
echo $DEST
rosrun xacro xacro --inorder ${SRC}/pole/pole.urdf.xacro > /tmp/pole.urdf
gz sdf -p /tmp/pole.urdf > ${DEST}/pole.sdf

DEST=`rospack find plt_gazebo`/models/pole_wireless
echo 'Generating pole_wireless.sdf'
echo $DEST
rosrun xacro xacro --inorder $SRC/pole_wireless/pole_wireless.urdf.xacro > /tmp/pole.urdf
gz sdf -p /tmp/pole.urdf > $DEST/pole_wireless.sdf

rm /tmp/pole.urdf
echo 'Done.'