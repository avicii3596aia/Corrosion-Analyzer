# Corrosion-Analyzer
Advanced MATLAB application for automated corrosion analysis - Image processing, pattern detection, statistical analysis, and data visualization
# Corrosion Analyzer App

## Overview
Advanced MATLAB application for automated corrosion analysis and quantification. Uses image processing and computer vision to detect, analyze, and quantify corrosion patterns on metal surfaces from microscopic images.

## Key Features

### 1. **Image Analysis**
- Automatic circle detection (corroded regions)
- Configurable RGB color range detection
- Sensitivity adjustment for different corrosion types
- Multiple detection methods support

### 2. **Parameter Configuration**
- Circle radius detection (min/max)
- Color sensitivity tuning
- RGB range customization
- Inner diameter ratio adjustment
- Auto-detection of optimal RGB parameters

### 3. **Environment Group Management**
- Define and manage different corrosion environments
- Assign carbon steel numbers to groups
- Track environmental conditions
- Add, edit, delete group configurations

### 4. **Batch Processing**
- Process multiple images simultaneously
- Real-time progress tracking
- Systematic file organization
- Automated result logging

### 5. **Advanced Visualization**
- Side-by-side image comparison (original vs. analyzed)
- Multiple view modes:
  - Original image
  - Detection overlay
  - RGB mask
  - Processed result
- Image navigation controls

### 6. **Statistical Analysis & Export**
- Corrosion ratio calculations
- Summary statistics per environment
- Heatmap visualization (Steel Number vs Environment)
- Correlation analysis
- Distribution comparisons
- Excel export capabilities

## Technical Specifications

### Image Processing
- Circle detection using image processing toolbox
- RGB color range filtering
- Morphological operations
- Image segmentation

### Data Analysis
- Corrosion ratio computation
- Statistical aggregation
- Correlation coefficient calculation
- Multi-parameter analysis

### Output Formats
- PNG images (standard and high-resolution)
- Excel spreadsheets (.xlsx)
- Log files (.txt)

## How to Use

### Starting the Application
```matlab
% Method 1: Direct execution
CorrosionAnalyzerApp.runApp()

% Method 2: Create instance
app = CorrosionAnalyzerApp();
```

### Basic Workflow

1. **Select Image Directory**
   - Click "Select Image Directory" button
   - Choose folder containing corrosion images

2. **Configure Analysis Parameters**
   - **Circle Radius Min/Max**: Adjust detection range for corroded regions
   - **Sensitivity**: Fine-tune detection sensitivity
   - **RGB Range**: Set color thresholds for corrosion detection
   - Use "Auto-Detect RGB" for automatic calibration
   - Use "RGB Preview" to verify settings

3. **Setup Environment Groups**
   - Define environment names and conditions
   - Assign carbon steel numbers
   - Create/Edit/Delete groups as needed

4. **Process Images**
   - Click "Process Images" to start analysis
   - Monitor progress with gauge
   - Review results in real-time

5. **Visualize Results**
   - Navigate through processed images
   - Switch between view modes
   - Examine detection overlays

6. **Export Results**
   - Click "Export Results"
   - Generates comprehensive statistics
   - Creates heatmaps and correlations
   - Exports all data to Excel

## Parameter Guide

### Circle Radius
- **Min**: Smallest corrosion pit to detect (pixels)
- **Max**: Largest corrosion pit to detect (pixels)
- Typical range: 245-500 pixels

### Sensitivity
- **Range**: 1-100
- Lower = more selective
- Higher = more inclusive
- Default: 50

### RGB Thresholds
- **Min**: Lower RGB value bound
- **Max**: Upper RGB value bound
- **Factor**: Scaling factor for color matching
- Example: Min=50, Max=200 for rust-red colors

### Circle Selection
- Options: All detected circles, Largest, Smallest
- Affects final corrosion ratio calculation

## Output Files

### Directory Structure
```
results/
├── processed_images/
│   ├── image1_processed.png
│   ├── image1_overlay.png
│   └── ...
├── statistics/
│   ├── Summary.xlsx
│   ├── CorrosionHeatmap.png
│   ├── CorrelationAnalysis.png
│   ├── DistributionComparison.png
│   └── analysis_log.txt
└── raw_data/
    └── corrosion_data.xlsx
```

## Requirements

- **MATLAB Version**: R2019b or later
- **Toolboxes**:
  - Image Processing Toolbox
  - Computer Vision Toolbox (recommended)
  - Statistics and Machine Learning Toolbox

## Troubleshooting

### No circles detected
- Adjust Circle Radius Min/Max values
- Check RGB range with "RGB Preview"
- Increase sensitivity

### Poor color detection
- Use "Auto-Detect RGB" for automatic calibration
- Manually adjust RGB Min/Max/Factor
- Ensure adequate image lighting

### Performance issues
- Reduce image resolution
- Process fewer images at once
- Close other applications

## Advanced Features

### Auto-Detect RGB
Analyzes selected images to automatically find optimal RGB thresholds for corrosion detection.

### RGB Preview
Shows real-time preview of color detection before processing all images.

### Heatmap Analysis
Creates visual representation of corrosion intensity across:
- Different environment groups
- Various carbon steel numbers
- Combined parameter analysis

### Correlation Analysis
Calculates correlations between:
- Steel number and corrosion ratio
- Color values and corrosion intensity
- Steel composition and environmental factors

## Tips for Best Results

1. **Image Preparation**
   - Use consistent lighting
   - Ensure adequate image resolution (min 1000x1000 pixels)
   - Clean lens before capturing images

2. **Parameter Tuning**
   - Start with default values
   - Use preview function to verify settings
   - Adjust sensitivity gradually

3. **Environment Groups**
   - Create meaningful group names
   - Document environmental conditions
   - Use consistent steel numbering

4. **Data Export**
   - Always backup original images
   - Keep analysis log for reference
   - Review statistics before publication

## Performance Metrics

- Average processing time: ~2-5 seconds per image
- Batch processing: Efficient for 50+ images
- Memory usage: ~500MB for batch operations
- Output file size: Varies with image resolution

## Data Validation

The app automatically:
- Checks image file formats
- Validates parameter ranges
- Verifies detection results
- Flags anomalous data

## Citation

If you use this tool in research, please cite:
```
Corrosion Analyzer App - Advanced Image Processing for Corrosion Analysis
MATLAB Application, [Year]
```

## Contact & Support

For issues, feature requests, or questions:
- Check the analysis log for detailed error messages
- Ensure all required toolboxes are installed
- Verify image file compatibility

## License

[Your Institution/License Information]

## Version History

### Version 1.0
- Initial release
- Core corrosion detection
- Basic statistical analysis
- Heatmap visualization

## Future Enhancements

- Machine learning-based corrosion classification
- Real-time video processing
- Multi-scale analysis
- 3D surface reconstruction
- Integration with SEM/EDX data
