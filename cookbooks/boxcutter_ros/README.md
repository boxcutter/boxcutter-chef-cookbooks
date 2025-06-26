# boxcutter_ros

Install and configure the Robot Operating System (ROS).

## Attributes

- node['boxcutter_ros']['mirror']
- node['boxcutter_ros']['packagees']

## Usage

To install ROS, include the recipe `boxcutter_ros::default`. If you have a local
mirror, specify the mirror url with the attribute `node['boxcutter_ros']['mirror']`.

If you would like to customize the list of packages to be installed, use the
attribute `node['boxcutter_ros']['packages']`.

```bash
node.default['boxcutter_ros']['mirror'] = 'https://crake-nexus.org.boxcutter.net/repository/ros-apt-proxy'
node.default['boxcutter_ros']['packages'] = ['ros-jazzy-desktop']
```

### Rocker

To install the rocker tool that will run docker images with customized local
support, include `boxcutter_ros::rocker`.
