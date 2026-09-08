#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from rcl_interfaces.msg import SetParametersResult

import numpy as np
# TODO: include needed ROS msg type headers and libraries
from sensor_msgs.msg import LaserScan
from nav_msgs.msg import Odometry
from ackermann_msgs.msg import AckermannDriveStamped
from std_msgs.msg import Bool


class SafetyNode(Node):
    """
    The class that handles emergency braking.
    """
    def __init__(self):
        super().__init__('safety_node')
        """
        One publisher should publish to the /drive topic with a AckermannDriveStamped drive message.

        You should also subscribe to the /scan topic to get the LaserScan messages and
        the /ego_racecar/odom topic to get the current speed of the vehicle.

        The subscribers should use the provided odom_callback and scan_callback as callback methods

        NOTE that the x component of the linear velocity in odom is the speed
        """
        # Braking threshold in seconds. Set at launch with
        #   --ros-args -p ttc_threshold:=1.5
        # or live with
        #   ros2 param set /safety_node ttc_threshold 1.5
        # The live path works because on_set_parameters below refreshes the cached value.
        self.declare_parameter('ttc_threshold', 1.0)
        self.ttc_threshold = self.get_parameter('ttc_threshold').value
        self.add_on_set_parameters_callback(self.on_set_parameters)
        # cos(beam angle) for every beam, built on the first scan and reused
        self.cos_angles = None
        self.speed = 0.0
        # TODO: create ROS subscribers and publishers.
        self.create_subscription(LaserScan, '/scan', self.scan_callback, 10)
        self.create_subscription(Odometry, '/ego_racecar/odom', self.odom_callback, 10)
        self.drive_pub = self.create_publisher(AckermannDriveStamped, '/drive', 10)
        # Publish a bolean message to a brake engage topic to indicate that the brake is engaged
        self.brake_engage_pub = self.create_publisher(Bool, '/brake_engage', 10)

    def on_set_parameters(self, params):
        # Called by rclpy for every parameter change request, before it is applied.
        for p in params:
            if p.name == 'ttc_threshold':
                if p.value <= 0.0:
                    return SetParametersResult(successful=False, reason='ttc_threshold must be > 0')
                self.ttc_threshold = float(p.value)
                self.get_logger().info(f'ttc_threshold set to {self.ttc_threshold:.2f} s')
        return SetParametersResult(successful=True)

    def odom_callback(self, odom_msg):
        # TODO: update current speed
        self.speed = odom_msg.twist.twist.linear.x

    def scan_callback(self, scan_msg):
        # iTTC = r / {-r_dot}+  with  -r_dot = v * cos(beam angle)  (closing speed)
        # 1. beam angles never change: cache cos(angle) on the first scan
        if self.cos_angles is None:
            angles = scan_msg.angle_min + np.arange(len(scan_msg.ranges)) * scan_msg.angle_increment
            self.cos_angles = np.cos(angles)

        # 2. clean ranges: nan/inf/too-close readings become "nothing there" (inf)
        ranges = np.array(scan_msg.ranges, dtype=float)
        ranges[~np.isfinite(ranges) | (ranges < scan_msg.range_min)] = np.inf

        # 3. closing speed per beam, positive when the beam is shrinking
        closing_speed = self.speed * self.cos_angles

        # 4. iTTC, only where we are closing in; inf elsewhere (no warnings)
        ittc = np.full_like(ranges, np.inf)
        np.divide(ranges, closing_speed, out=ittc, where=closing_speed > 0)

        # 5. brake decision
        brake = bool(np.min(ittc) < self.ttc_threshold)
        self.brake_engage_pub.publish(Bool(data=brake))
        if brake:
            brake_msg = AckermannDriveStamped()
            brake_msg.header.stamp = self.get_clock().now().to_msg()
            brake_msg.drive.speed = 0.0
            self.drive_pub.publish(brake_msg)

def main(args=None):
    rclpy.init(args=args)
    safety_node = SafetyNode()
    rclpy.spin(safety_node)

    # Destroy the node explicitly
    # (optional - otherwise it will be done automatically
    # when the garbage collector destroys the node object)
    safety_node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
