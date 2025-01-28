# Steps to setup the sitl

## Install setup

Install setup from [px4 dev guide](https://dev.px4.io/en/setup/getting_started.html)

### Install a GCS (Ground Control Station)

* Download QGroundControl from [here](https://docs.qgroundcontrol.com/en/releases/daily_builds.html)

### First build

```shell
cd <FW_PATH>
make px4_sitl_default gazebo
```

Where <FW_PATH> is the path to the Firmware folder from PX4 cloned git.

It will build the project and launch the px4 flight stack, gazebo simulator and the quadrotor iris.
Launch the QGroundControl and you can send commands and missions to the quadcopter.

## Use PX4 with Gazebo and ROS

### Sending sensor data from Gazebo to Ros topics

In order to have the sensors being published in ROS topics is necessary to update some paths

Add theses lines to your .bashrc file. It is located at your home folder.

```shell
source Tools/setup_gazebo.bash <FW_PATH>  <FW_PATH>/build/posix_sitl_default
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:<FW_PATH>
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:<FW_PATH>/Tools/sitl_gazebo
```

Where <FW_PATH> is the path to the Firmware folder from PX4 cloned git.

and then:

```shell
roslaunch px4 mavros_sitl.launch vehicle:=iris
```

Now it will also launch ros nodes. Look at the nodes and topics list.

## Use uav with gimbal and camera support

The uav Typhoon has support to gimbal and camera.

### First remove previous configurations from other vehicles

```shell
rm -r ~/.ros/eeprom
```

### Then build the code to launch the typhoon with correct parameters.

```shell
cd <FW_PATH>
make px4_sitl_default gazebo_typhoon_h480
```

### Kill the sitl and run with ROS using a ros launch file

```shell
roslaunch px4 mavros_sitl.launch vehicle:=typhoon_h480
```

### To publish the camera images in ros topics, uncomment this part of code in typhoon_h480.sdf and run again the previous command.

```xml
<plugin name="cgo3_camera_controller" filename="libgazebo_ros_camera.so">
    <alwaysOn>true</alwaysOn>
    <updateRate>0.0</updateRate>
    <cameraName>cgo3_camera</cameraName>
    <imageTopicName>image_raw</imageTopicName>
    <cameraInfoTopicName>camera_info</cameraInfoTopicName>
    <frameName>cgo3_camera_optical_frame</frameName>
    <hackBaseline>0.0</hackBaseline>
    <distortionK1>0.0</distortionK1>
    <distortionK2>0.0</distortionK2>
    <distortionK3>0.0</distortionK3>
    <distortionT1>0.0</distortionT1>
    <distortionT2>0.0</distortionT2>
</plugin>
```

### To see the images run this command in a new terminal:

```shell
rosrun image_view image_view image:=cgo3_camera/image_raw
```

## How to use this repository

Clone it in your machine.

It is a ROS workspace. So after downloading it, go to the root of the workspace
and compile the code, to generate the header files necessary to ROS, using
the catkin_make command:

```shell
cd <path>plt_ws
catkin_make
```

Now, you have two folders, build and devel.
Add the command to source this workspace, in order to ROS view this folder as a ROS package
system.

Add this line:

```shell
source <path>/plt_ws/devel/setup.bash
```

to the end of the .bashrc file. It is generally located at /home/user/

## To run the simulation

After completed the previous step, use the roslaunch command to start the Gazebo simulator
with the PX4 Sitl firmware.

```shell
roslaunch plt_gazebo simulation.launch
```

To start the image processing node, run the following command:

```shell
roslaunch plt_cv img_preprocessing.launch use_rosbag:=false
```

The use_rosbag parameter is used to launch or not the image processing step with the
images captured by ROS.
