#!/bin/bash
echo "Running image processing node and line tracking"

THRESHOLD=150
USE_ROSBAG=true
NOW=$(date +%F-%T)
SAVE_IMAGES=true

for BAGFILE in 'missionZ20m' 'missionZ16m';
do
    for EDGE in 'canny' 'sobel' 'laplacian';
    do
        for FILTER in 'gaussian' 'blur' 'bilateral';
        do
            echo "Do you want to run simulation with $FILTER and $EDGE in $BAGFILE ?"
            select answer in "yes" "no";
            do
                case $answer in
                    "yes")

                        mkdir -p ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER

                        roscore &
                        sleep 5s

                        echo "Using $FILTER and $EDGE at bagfile: $BAGFILE"
                        roslaunch plt_scripts all.launch date:=$NOW filter:=$FILTER kernel:=3 edge:=$EDGE bagfile:=$BAGFILE houghThreshold:=$THRESHOLD use_rosbag:=true log_files:=true

                        echo "Done simulation"

                        python my_bag_graph.py  -b  ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER/log.bag -y   -6    6.5    -d 0.5  -l "Distance (Rho) [m]" -s /uav/line/distance  -f pose_calculated.eps
                        python my_bag_graph.py  -b  ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER/log.bag -y   -20   22   -d 2    -l "Orientation (Theta) [deg]"  -s /uav/line/theta  -f pose_orientation_calculated.eps
                        python my_bag_graph.py  -b  ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER/log.bag -y   -0.50 0.6 -d 0.1  -l "Distance Error [m]" -s /uav/error/distance -f pose_error.eps
                        python my_bag_graph.py  -b  ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER/log.bag -y   -6    7    -d 1    -l "Orientation Error [deg]" -s /uav/error/theta -f pose_orientation_error.eps
                        python my_bag_graph.py  -b  ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER/log.bag -y   0     15   -d 1    -l "Total Lines" -s /plt_cv/lines/len -f totalLines.eps
                        python my_bag_graph.py  -b  ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER/log.bag -y   0     5    -d 1    -l "Cables Detected" -s /uav/line/lines_found -f linesFound.eps


                        mv *.eps ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER
                        cp my_bag_graph.py ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER

                        echo 'python my_bag_graph.py  -b log.bag -y -5 5 -d 0.5 -l "distância (Rho)" -s /uav/line/distance  -f pose_calculated.eps ' > run3.sh
                        mv run3.sh ~/simulation/plt_ws/src/plt_resources/logs/$NOW/$BAGFILE/$EDGE/$FILTER

                        echo "Done2!!!"
                        echo ""
                        echo ""

                        killall rosmaster

                        sleep 10s

                        ;;
                    "no")
                        echo "Ok. It is up to you!"
                        break;
                        ;;
                    *)
                        echo "Wrong option! Select 1 or 2."
                        exit 1
                        ;;
                esac
            done;
        done;
    done;
done;
