# Quaternion-Based Cube Orientation Visualizer

This project visualizes a cube that assumes the orientation described by quaternion data transmitted from a sensor to the serial port. The visualization is done using Processing 4.3.

**Disclaimer** : This project is inspired by and based on the original work by Fabio Varesano!

## **Overview**
This program reads quaternion data from a serial port, processes it, and visualizes the orientation of a cube in real-time. It is intended for use with a sensor like the BNO055, which provides quaternion data representing the orientation of the sensor.

## **Requirements**
- Processing 3.x or later
- A sensor (e.g., BNO055) capable of transmitting quaternion data over UART
- A serial connection between the sensor and the computer (e.g., via USB-to-serial adapter)
- Correctly configured serial port on the computer (e.g., COM7 on Windows)

## **Setup and Usage**

**Install Processing** : Download and install Processing from [processing.org](processing.org).

**Sensor Setup** : Ensure your sensor is connected and properly configured to transmit quaternion data over UART. The data format should be as follows:

```c
//Exemple from STM32CubeIDE using C :
char quaternionStr[100];
sprintf(quaternionStr, "%.6f,%.6f,%.6f,%.6f,%.6f\r\n", data->quaternion.w, data->quaternion.x, data->quaternion.y, data->quaternion.z, 0.1);
HAL_UART_Transmit(&huart1, (uint8_t*)quaternionStr, strlen(quaternionStr), HAL_MAX_DELAY);
```

**Processing Sketch** : Copy the Processing code from this repository into a new Processing sketch.

**Adjust Serial Port** : Update the serialPort variable in the Processing sketch to match your serial port (e.g., "COM7" on Windows).

**Run the Sketch** : Run the Processing sketch. The program will start reading quaternion data from the serial port and visualizing the cube's orientation.

## **How It Works**

**Data Transmission** : 

- The sensor transmits quaternion data over UART to the specified serial port on the computer.

**Processing Sketch** : 
- Reads the quaternion data from the serial port.
- Parses the data and converts the quaternion to Euler angles.
- Visualizes the cube's orientation using the Euler angles.

**Key Commands**:

- h: Set the current orientation as the home position.
- v: Request version information from the sensor.
- n: Clear the home position.

## **Results with BNO055 sensor**

I'm currently using this program to test the hardware and firmware of [Aerosentinel Argus Navigation Module](https://github.com/yaxsomo/aerosentinel-argus), which features multiple IMUs. The data transmission of fusionned quaternions form my BNO055 have excellent results : 

<p align="center">
  <img src="https://github.com/user-attachments/assets/934b94dc-e057-42d6-b5b0-aa2f25d6c809" alt="IMU Visualization Final">
</p>

## **Improvements to make**
I will add multiple views in the next days, so I can have multiple IMUs streaming data and visualize the drift between each one.

## Contributing
Contributions are welcome! Please follow the [contribution guidelines](CONTRIBUTING.md) when making contributions to this project.

## License
This project is licensed under the [BSD 3-Clause License](LICENSE).
