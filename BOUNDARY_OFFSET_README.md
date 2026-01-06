# BOUNDARY OFFSET - AutoLISP Script

## Description

This AutoLISP script creates an outer boundary polyline around selected objects with a specified offset distance of 0.6 units. The script automatically calculates the boundary without requiring user input for an internal point.

## Features

- **Automatic Boundary Detection**: No need to manually pick an internal point
- **Configurable Offset**: Creates an outer boundary with 0.6 units offset
- **Clean Output**: Automatically deletes the inner boundary, leaving only the outer offset boundary
- **Multiple Entity Support**: Works with lines, circles, arcs, polylines, and lwpolylines
- **Clear Documentation**: Well-commented code for easy understanding and modification

## Installation

1. Copy the `boundary_offset.lsp` file to your AutoCAD support file search path, or any location accessible to AutoCAD
2. Load the LISP file in AutoCAD using one of these methods:
   - Use the `APPLOAD` command in AutoCAD
   - Drag and drop the .lsp file into the AutoCAD window
   - Add it to your startup suite for automatic loading

## Usage

1. Load the script (if not already loaded)
2. Type `BOUNDARYOFFSET` at the AutoCAD command prompt
3. Select the objects you want to create a boundary around
4. Press Enter to confirm selection
5. The script will:
   - Analyze the selected objects
   - Calculate the center point automatically
   - Create an inner boundary polyline
   - Offset it outward by 0.6 units to create the outer boundary
   - Delete the inner boundary
   - Display a completion message

## How It Works

### Step-by-Step Process

1. **Object Selection**: User selects objects to create boundary around
2. **Offset Distance**: Sets offset distance to 0.6 units (can be modified in code)
3. **Automatic Point Calculation**: 
   - Calculates bounding box of all selected objects
   - Determines center point automatically
   - **No user prompt for internal point required**
4. **Inner Boundary Creation**: Creates a boundary polyline using the calculated center point
5. **Outer Boundary Creation**: Uses the OFFSET command to create outer boundary at 0.6 units distance
6. **Cleanup**: Deletes the inner boundary polyline, keeping only the outer boundary
7. **Completion**: Displays success message with offset distance

## Modifications from Original

### Original Behavior
The original code required the user to manually pick an internal point:
```lisp
(setq pt3d (getpoint "\nPick a point INSIDE the objects: "))
```

### Modified Behavior
The internal point is now calculated automatically:
- Analyzes all selected objects
- Calculates bounding box
- Uses center point of bounding box
- No user interaction required for point selection

## Configuration

To change the offset distance, modify line 31:
```lisp
(setq offset-dist 0.6)  ;; Change 0.6 to desired offset distance
```

## Requirements

- AutoCAD or AutoCAD-compatible software with AutoLISP support
- Selected objects must form a closed boundary
- Objects should be planar (2D) for best results

## Supported Entity Types

- LINE
- CIRCLE
- ARC
- POLYLINE
- LWPOLYLINE

## Error Handling

The script includes error handling for:
- No objects selected
- Failed boundary creation
- Invalid object configurations

## Example Workflow

```
Command: BOUNDARYOFFSET
Select objects to create boundary around: [Select objects]
Using offset distance: 0.60
Analyzing selected objects...
Calculated center point: 10.00,15.00
Creating inner boundary from selected objects...
Creating outer boundary with offset...
Deleting inner boundary...
Inner boundary deleted successfully.
========================================
Outer boundary polyline created successfully!
Offset distance: 0.60 units
========================================
```

## Troubleshooting

**Problem**: "Could not create inner boundary"
- **Solution**: Ensure selected objects form a closed boundary
- Check that objects are connected without gaps

**Problem**: Offset creates boundary in wrong direction
- **Solution**: The script automatically calculates offset direction based on object geometry
- Verify objects are properly closed

**Problem**: Script doesn't run
- **Solution**: Ensure the script is properly loaded using APPLOAD command
- Check AutoCAD's command line for error messages

## License

This script is provided as-is for use with AutoCAD and compatible software.

## Version History

- **v2.0**: Modified to remove internal point prompt, automatic boundary generation
- **v1.0**: Original version with internal point prompt
