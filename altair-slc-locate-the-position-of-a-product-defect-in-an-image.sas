%let pgm=altair-slc-locate-the-position-of-a-product-defect-in-an-image;

%stop_submission;

altair slc locate the position of a product defect in an image

Too long to post here, see github
https://github.com/rogerjdeangelis/altair-slc-locate-the-position-of-a-product-defect-in-an-image

PREP

  1 You need an image of a turbine blade with a common defict like a crack.
    Take an image of the tubine blade with a typical crack.
    This can be automated by mounting a camera above the blades in an assemply line.
    Note the crack just has to have a general small crack form or part of a crack,
    we use 75% confidence on identifying cracks.

  2 Crop out the crack, this can be a small image.
    This template image can be used for many turbibe blades

  3 Use python image processing to loacate cracks in mutiple turbine blades.

The 'where is waldo children game' provides good example for finding defects.

/*                   _
(_)_ __  _ __  _   _| |_ ___
| | `_ \| `_ \| | | | __/ __|
| | | | | |_) | |_| | |_\__ \
|_|_| |_| .__/ \__,_|\__|___/
        |_|
*/

Download from github

Full Image: departmentstore.jpeg(turbine blade?) image with the waldo(crack).
Crop out the crack retangle: stripes2.jpg(just waldo in the large image, does not have to be exct)

Save images in

  d:/jpg/departmentstore.jpg
  d:/jpg/stripes2.jpg

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

proc datasets lib=workx kill nodetails nolist;
run;quit;

options set=PYTHONHOME "D:\py310";
proc python;
submit;
import cv2
import numpy as np
import pandas as pd

def find_waldo_with_units(large_path, template_path, threshold=0.7):
    """Finds Waldo and explicitly states all units are pixels"""
    large = cv2.imread(large_path)
    template = cv2.imread(template_path)

    if large is None or template is None:
        print("Error loading images")
        return None

    img_height, img_width = large.shape[:2]
    t_height, t_width = template.shape[:2]

    # Template matching
    result = cv2.matchTemplate(
        cv2.cvtColor(large, cv2.COLOR_BGR2GRAY),
        cv2.cvtColor(template, cv2.COLOR_BGR2GRAY),
        cv2.TM_CCOEFF_NORMED
    )

    _, confidence, _, (x, y) = cv2.minMaxLoc(result)

    if confidence > threshold:

        # All calculations in PIXELS
        center_x = x + t_width // 2
        center_y = y + t_height // 2

        print("=" * 60)
        print("UNITS: ALL MEASUREMENTS ARE IN PIXELS (px)")
        print("=" * 60)
        print(f"IMAGE DIMENSIONS:")
        print(f"  Width:  {img_width} px")
        print(f"  Height: {img_height} px")
        print(f"  Total:  {img_width * img_height:,} px")
        print()
        print(f"WALDO TEMPLATE:")
        print(f"  Width:  {t_width} px")
        print(f"  Height: {t_height} px")
        print()
        print(f"WALDO LOCATION (in pixels from top-left):")
        print(f"  Top-left:     ({x} px, {y} px)")
        print(f"  Center:       ({center_x} px, {center_y} px)")
        print(f"  Bottom-right: ({x + t_width} px, {y + t_height} px)")
        print()
        print(f"DISTANCES FROM EDGES:")
        print(f"  From left:   {x} px")
        print(f"  From top:    {y} px")
        print(f"  From right:  {img_width - (x + t_width)} px")
        print(f"  From bottom: {img_height - (y + t_height)} px")
        print()
        print(f"RELATIVE POSITION (as percentages):")
        print(f"  Horizontal: {center_x / img_width * 100:.1f}% from left")
        print(f"  Vertical:   {center_y / img_height * 100:.1f}% from top")
        print()
        print(f"MATCH CONFIDENCE: {confidence:.1%}")
        print("=" * 60)

        # Create visualization
        marked = large.copy()

        # Draw Waldo bounding box (in pixels)
        cv2.rectangle(marked, (x, y), (x + t_width, y + t_height), (0, 0, 255), 3)

        # Add unit labels
        cv2.putText(marked, f"({x}px, {y}px)", (x, y - 10),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)

        # Draw scale reference (100 pixel bar)
        bar_length = 100
        bar_y = img_height - 30
        cv2.line(marked, (20, bar_y), (20 + bar_length, bar_y), (255, 255, 255), 3)
        cv2.putText(marked, "100 PIXELS", (20, bar_y - 10),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

        cv2.imwrite('waldo_pixels.jpg', marked)
        print(f"\nVisualization saved as 'waldo_pixels.jpg'")

        return {
    'img_width': img_width,
    'img_height': img_height,
    't_width': t_width,
    't_height': t_height,
    'x': x,
    'y': y,
    'center_x': center_x,
    'center_y': center_y,
    'confidence': confidence
}

# Then usage becomes:
result = find_waldo_with_units('d:/jpg/departmentstore.jpg', 'd:/jpg/stripes2.jpg')
result['units'] = 'pixels'  # Add units
df = pd.DataFrame([result])  # Single-row DataFrame
print(df)

endsubmit;
import data=workx.waldo python=df;

run;quit;

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

Middle Observation(1 ) of table = workx.waldo


 -- CHARACTER --
Variable        Typ    Value

UNITS            C6          pixels

 -- NUMERIC --
IMG_WIDTH        N8            1024
IMG_HEIGHT       N8             768
T_WIDTH          N8              16
T_HEIGHT         N8              48

X                N8             172
Y                N8             147

CENTER_X         N8             180  Verify
CENTER_Y         N8             171

CONFIDENCE       N8            0.75

/*              _  __
__   _____ _ __(_)/ _|_   _
\ \ / / _ \ `__| | |_| | | |
 \ V /  __/ |  | |  _| |_| |
  \_/ \___|_|  |_|_|  \__, |
                      |___/
*/

Open the original large image departmentstore.jpg

Move the cursor to the center of waldo

Look a the bottom left line and yoy should see

<| 180px, 172px  (waldo in a narrow rectangle)

This agrees vey closely to our output

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
