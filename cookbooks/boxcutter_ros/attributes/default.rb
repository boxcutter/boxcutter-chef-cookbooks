if node.ubuntu? && node['platform_version'].start_with?('24')
  default['boxcutter_ros'] = {
    'mirror' => 'http://packages.ros.org/ros2/ubuntu',
    'distributions' => {
      'jazzy' => {
        'packages' => ['ros-jazzy-desktop', 'ros-jazzy-ros-gz']
      }
    }
  }
elsif node.ubuntu? && node['platform_version'].start_with?('22')
  default['boxcutter_ros'] = {
    'mirror' => 'http://packages.ros.org/ros2/ubuntu',
    'distributions' => {
      'humble' => {
        'packages' => ['ros-humble-desktop', 'ros-humble-ros-gz']
      }
    }
  }
elsif node.ubuntu? && node['platform_version'].start_with?('20')
  default['boxcutter_ros'] = {
    'mirror' => 'http://packages.ros.org/ros2/ubuntu',
    'distributions' => {
      'foxy' => {
        'packages' => ['ros-foxy-desktop']
      }
    }
  }
else
  default['boxcutter_ros'] = {
    'mirror' => 'http://packages.ros.org/ros2/ubuntu',
    'distributions' => {}
  }
end
