#!/bin/bash

echo "Starting simulation: Gazebo without GUI, ROS, SITL, world Grass"

# Starts QGroundControl. This command depends on the location of its .AppImage
~/Desktop/QGroundControl.AppImage &

roslaunch plt_gazebo simulation.launch gui:=false x:=-5 y:=0 world:=grass