#
# Cookbook:: boxcutter_ros_test
# Recipe:: default
#

include_recipe 'boxcutter_ros::common'
include_recipe 'boxcutter_ros::user'
include_recipe 'boxcutter_ros::default'
include_recipe 'boxcutter_ros::gazebo' if node.ubuntu? && node['platform_version'].start_with?('20')

# https://gazebosim.org/docs/latest/ros_installation/
# https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
# ROS2 Jazzy (LTS) - ros-jazzy-desktop ros-jazzy-ros-base ros-dev-tools "source /opt/ros/jazzy/setup.bash"
# https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
# ROS2 Humble (LTS) - ros-humble-desktop ros-humble-ros-base ros-dev-tools "source /opt/ros/humble/setup.bash"
# https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html
# ROS2 Foxy (LTS) - ros-foxy-desktop python3-argcomplete ros-foxy-base ros-dev-tools "source /opt/ros/foxy/setup.bash"
# https://wiki.ros.org/noetic/Installation/Ubuntu
# ROS1 Noetic (LTS) - ros-noetic-desktop-full ros-noetic-ros-base "source /opt/ros/noetic/setup.bash"

# source /opt/ros/humble/setup.bash
# ros2 run demo_nodes_cpp talker

# source /opt/ros/humble/setup.bash
# ros2 run demo_nodes_py listener

# $ ros2 multicast receive
# $ ros2 multicast send
# $ sudo ufw allow in proto udp to 224.0.0.0/4
# $ sudo ufw allow in proto udp from 224.0.0.0/4

# apt-get download ros-dev-tools
# dpkg-deb -x /root/ros-dev-tools_1.0.1_all.deb extracted/
# dpkg-deb -e /root/ros-dev-tools_1.0.1_all.deb extracted/DEBIAN

# apt-get update
# apt-get install binutils xz-utils
# ar t /root/ros-dev-tools_1.0.1_all.deb
# ar x /root/ros-dev-tools_1.0.1_all.deb
# tar -tf control.tar.xz
# tar -tf data.tar.xz
