# IWT: Interactive Well Transformer

## Introduction
IWT is a tool for ImageJ or Fiji for transformation of full well images from multi-well plates. It is intended for use with time series images, where a certain object is monitored over time, such as a growth of a spheroid.

This tool is designed for:

1. **Rotation:** If the images are not aligned over time to the same rotation angle. This tool allows for selecting a reference image of an image series and aligns all other images in the series by identifying a reference point on the image that will be adjusted for all of them. This reference point can be a particular shape on the edge of the well or another readily identifiable object within all images. 

2. **Crop Well:** For some downstream analyses and for generation of image panels for publication, it may be best to remove the extra parts of the image outside the well. This tool selects the center of the image based on the brightness of the well and allows you to select bounds to the well which it will automatically crop for all images.

3. **Crop a specific part of the well:** This tool allows you to select a square of a specific feature in your well in order to obtain a series of that object from your full series automatically. An example, you can generate images that represent the growth of a specific spheroid.

## Installation

To install this tool, you need to have any version of ImageJ or Fiji.

1. Download the "Interactive_Well_Transformer.ijm" file.
2. From ImageJ/Fiji, install from the plugins menu. `Plugins > Install...` 
3. Restart ImageJ/Fiji

## Usage

After installation, you can use the tool from the plugins menu: `Plugins > Interavtive Well Transformer`

## What is IWT used for?
![](/workflow.png)

Tool designed by: 
Hani N. Alsafadi
